import { initTable } from './InitAndTable';
import TaskImpl from './TaskImpl';
import Logger from '../utils/log/Logger';
import { TaskInterface } from './Interface/TaskInterface';
import { RdbCommon } from "../../model/RdbCommon";
import { FavoritesData } from "../../model/FavoritesData";
import { FavoritesInterface } from "./Interface/FavoritesInterface";

export class FavoritesImpl implements FavoritesInterface {
  private taskImpl: TaskInterface = new TaskImpl();

  constructor() {
    initTable.favoritesTable.getRdbStore();
  }

  /**
   * 向favorites表中插入一项
   * @param favoritesData
   * @param callback(id3,flag,reason)
   */
  insert(favoritesData: FavoritesData, callback: Function) {
    initTable.favoritesTable.insertData(favoritesData, (id3, flag, reason) => {
      if (flag) {
        favoritesData.id3 = id3;
        Logger.info("FavoritesImpl", " insert newFavoritesData success:" + JSON.stringify(favoritesData));
      }
      callback(id3, flag, reason);
    });
  }

  /**
   * 删除分类并删除相关事件和显示事件
   * @param id3
   * @param callback(flag,reason)
   */
  deleteFavorites(id3: number, callback: Function) {
    let favoritesId3: number = id3;
    this.queryAllId1ById3(favoritesId3, (id1Array: Array<number>) => {
      if (id1Array != null) {
        //删除相关
        for (let i = 0;i < id1Array.length; i++) {
          this.taskImpl.deleteTask(id1Array[i], (flag: boolean, reason: string) => {
            if (!flag) {
              callback(flag, "删除事项失败")
              return;
            }
          })
        }
      }
    })
    //删除favorites表中的一行
    initTable.favoritesTable.deleteDate(id3, (flag, reason) => {
      if (flag) {
        Logger.info("FavoritesImpl", "delete favorites success! id3:" + id3);
      }
      callback(flag, "全部删除成功")
    })
  }

  /**
   * 根据id3删除待办单并移动内容到未分类id3=1
   * @param id3
   * @param callback(flag,reason)
   */
  deleteFavoritesAndMove(id3: number, callback: Function) {
    let favoritesId3: number = id3;
    if (favoritesId3 <= 1) {
      callback(false, "默认分类不可删除！");
      return;
    }
    this.taskImpl.queryById3(favoritesId3, (flag: boolean) => {
      if (flag == false) {
        callback(false, "该分类不存在!")
        return;
      }
      this.queryAllId1ById3(favoritesId3, (id1Array: Array<number>) => {
        if (id1Array != null) {
          //事件移动到默认
          for (let i = 0;i < id1Array.length; i++) {
            this.taskImpl.changeFavorites(id1Array[i], 1, (flag: boolean, reason: string) => {
              if (!flag) {
                callback(flag, "移动事项失败")
                return;
              }
            })
          }
        }
      })
    })
    //删除favorites表中的一行
    initTable.favoritesTable.deleteDate(id3, (flag, reason) => {
      if (flag) {
        Logger.info("FavoritesImpl", "deleteFavoritesAndMove-delete favorites success! id3:" + id3);
      }
      callback(flag, "删除并移动成功");
    })

  }

  /**
   * 更改分类的名称/颜色
   * @param id3
   * @param name
   * @param color
   * @param callback(flag,reason)
   */
  changeFavorites(id3: number, name: string, color: string, callback: Function) {
    let newFavorites: FavoritesData = new FavoritesData(id3, name, color)
    if (id3 <= 1) {
      callback(false, "默认分类不可删除！")
      return;
    }
    this.taskImpl.queryById3(id3, (flag: boolean) => {
      if (flag == false) {
        callback(false, "分类不存在!");
        return;
      }
      let promise = initTable.favoritesTable.update(newFavorites);
      promise.then((ret) => {
        Logger.info("FavoritesImpl", "changeFavorites success id3: " + id3 + " -> rowCount:" + ret);
        callback(true, " ");
      }).catch((err) => {
        Logger.error("FavoritesImpl", "changeFavorites() failed, err: " + err);
        callback(false, "更改失败！");
      })
    })

  }

  /**
   * 查询全部待办单的信息和内容数量
   * return(Promise<Array<FavoritesData>>) FavoritesData：[id3,name,color,count]
   */
  async queryAllAndNumber(): Promise<Array<FavoritesData>> {
    let dataArray: Array<FavoritesData> = [];

    let resultData = await initTable.favoritesTable.promiseQueryContext(RdbCommon.QUERY_FAVORITES_ALL, "0");
    let countRow = resultData.rowCount;
    if (countRow > 0) {
      resultData.goToFirstRow();
      for (let i = 0;i < countRow; i++) {
        let tmp: FavoritesData = new FavoritesData(0, " ", " ");
        tmp.count = 0;
        tmp.id3 = resultData.getDouble(resultData.getColumnIndex("id3"));
        tmp.favoritesName = resultData.getString(resultData.getColumnIndex("favoritesName"));
        tmp.favoritesColor = resultData.getString(resultData.getColumnIndex("favoritesColor"));

        let resultNumber = await initTable.favoritesTable.promiseQueryContext(RdbCommon.QUERY_TASK_NUMBER_1 + RdbCommon.QUERY_TASK_default, tmp.id3.toString());
        resultNumber.goToFirstRow();
        tmp.count = resultNumber.getDouble(resultNumber.getColumnIndex("EventNumber"));

        dataArray.push(tmp);
        Logger.info("FavoritesImpl", "queryAllAndNumber-" + i + ": " + JSON.stringify(dataArray[i]));
        resultData.goToNextRow();
      }
    }
    return dataArray;
  }

  /**
   * 根据id3获取所有task的id1
   * @param id3
   * @param callback(Array<number>)
   */
  queryAllId1ById3(id3: number, callback: Function) {
    let id1Array: Array<number> = [];
    initTable.taskTable.queryContext(RdbCommon.QUERY_ALL_id1_byId3, (resultSet, countRow) => {
      if (countRow > 0) {
        resultSet.goToFirstRow();
        for (let i = 0;i < countRow; i++) {
          let id1: number = resultSet.getDouble(resultSet.getColumnIndex("id1"));

          id1Array.push(id1);
          Logger.info("TaskImpl", "queryAllId1ById3-" + id3 + " -> id1: " + JSON.stringify(id1Array[i]));
          resultSet.goToNextRow();
        }
        callback(id1Array);
      } else {
        callback(null);
      }
    }, id3.toString())
  }
}
