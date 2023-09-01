import Logger from '../../utils/log/Logger';
import { FavoritesData } from "../../../model/FavoritesData";
import { RdbCommon } from "../../../model/RdbCommon";
import data_rdb from "@ohos.data.rdb";
import { EventRdb } from "../EventRdb";

export default class FavoritesTable {
  private favoritesTable = new EventRdb(RdbCommon.FAVORITES_TABLE.tableName,
  RdbCommon.FAVORITES_TABLE.sqlCreate);

  constructor(callback: Function=() => {
  }) {
    this.favoritesTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function=() => {
  }) {
    this.favoritesTable.getRdbStore(callback);
  }

  insertData(favoritesData: {}, callback: Function) {
    const valueBucket = generateBucket(favoritesData);
    this.favoritesTable.insertData(valueBucket, (ret) => {
      if (ret < 0 || ret == null || typeof ret == "undefined") {
        Logger.error("FavoritesTable", "insertData favoritesData failed:"+ JSON.stringify(valueBucket));
        callback(ret, false, "创建失败！");
        return;
      } else {
        Logger.info("FavoritesTable", "Insert favoritesData success:" + JSON.stringify(valueBucket));
        callback(ret, true, "创建成功");
      }
    });
//    Logger.info("FavoritesTable", "Insert favoritesData :" + JSON.stringify(valueBucket) + "finished.");
  }

  deleteDate(favoritesId3: number, callback: Function) {
    Logger.info("FavoritesTable", "delete favorites start");
    let predicates = new data_rdb.RdbPredicates(RdbCommon.FAVORITES_TABLE.tableName);
    predicates.equalTo("id3", favoritesId3);
    this.favoritesTable.deleteData(predicates, callback);
  }

  update(favoritesData: FavoritesData): Promise<any> {
    const valueBucket = generateBucket(favoritesData);
    let predicates = new data_rdb.RdbPredicates(RdbCommon.FAVORITES_TABLE.tableName);
    predicates.equalTo("id3", favoritesData.id3);
    let promise =  this.favoritesTable.updateData(valueBucket, predicates);

    Logger.info("FavoritesTable", "update finished:" + JSON.stringify(valueBucket));
    return promise;
  }

  queryContext(sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("FavoritesTable", "queryContext SQL: " + sql + "-----Args: " + bindArgs.toString());
    this.favoritesTable.query(sql, bindArgs, function (resultSet) {
      let countRow: number = -1;
      countRow = resultSet.rowCount;
      if (countRow <= -1) {
        Logger.error("FavoritesTable", "queryContext query no results");
      }
      callback(resultSet, countRow);
    });
  }

  promiseQueryContext(sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("FavoritesTable", "promiseQueryContext SQL: " + sql + "-----Args: " + bindArgs.toString());
    let promise = this.favoritesTable.queryPromise(sql,bindArgs);
    return promise;
  }

  queryNumber(sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("FavoritesTable", "queryNumber SQL:" + sql + "-----Args: " + bindArgs.toString());
    this.favoritesTable.query(sql, bindArgs, function (resultSet) {
      let countRow = resultSet.rowCount;
      if (countRow <= 0) {
        Logger.error("FavoritesTable", "queryNumber query no results");
        callback(0);
      } else {
        resultSet.goToFirstRow();
        let count: number = resultSet.getDouble(resultSet.getColumnIndex("EventNumber"));
        callback(count);
      }
    });
  }

  executeSql(sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("FavoritesTable", "executeSql SQL: " + sql + "-----Args: " + bindArgs.toString());
    let promise = this.favoritesTable.executeSqlPromise(sql,bindArgs);
    return promise;
  }

}

function generateBucket(favoritesData: {}) {
  let obj = {};
  RdbCommon.FAVORITES_TABLE.columns.forEach((item) => {
    if (item != "id3") {
      obj[item] = favoritesData[item];
    }
  });
  return obj;
}