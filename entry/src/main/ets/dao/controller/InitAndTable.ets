import { resultToSTArray } from '../../model/ShowTaskData';
import { resultToTArray } from '../../model/TaskData';
import { resultToFArray } from '../../model/FavoritesData';
import { ShowTaskData } from '../../model/ShowTaskData';
import { RdbCommon } from '../../model/RdbCommon';
import { ShowTaskImpl } from './ShowTaskImpl';
import { ShowTaskInterface } from './Interface/ShowTaskInterface';
import ShowTaskTable from '../database/tables/ShowTaskTable';
import Logger from '../utils/log/Logger';
import { TaskData } from '../../model/TaskData';
import { FavoritesData } from '../../model/FavoritesData';
import { TaskInterface } from './Interface/TaskInterface';
import { FavoritesInterface } from './Interface/FavoritesInterface';
import { FavoritesImpl } from './FavoritesImpl';
import FavoritesTable from '../database/tables/FavoritesTable';
import TaskImpl from './TaskImpl';
import TaskTable from '../database/tables/TaskTable';
import common from '@ohos.app.ability.common';

// export const initTable = new InitTable();

export class ImplTable {
    // private favoritesImpl: FavoritesImpl;

    constructor() {
        // this.favoritesImpl = new FavoritesImpl(context);
    }

    initTable(context: Context) {
        let favoritesImpl = new FavoritesImpl();
        favoritesImpl.insert(new FavoritesData(0, "默认", "white"), (id3, flag, reason) => {
            Logger.info("ImplTable", "id3: " + id3);
            Logger.info("ImplTable", "flag: " + flag);
            Logger.info("ImplTable", "reason: " + reason);
        }, context);
    }
}

export class Backup {
    constructor() {
    }

    exportData(callback: Function, context: Context) {
        let favoritesArray: Array<[number, string, string]> = [];
        let taskArray: Array<[number, string, string, number, boolean, boolean, string, string, boolean, number, string, string, number, number, number, string[], number, boolean, string, string, boolean]> = []
        let showTaskArray: Array<[number, string, string, string, string, number, string, number, boolean]> = []

        const favoritesTable = new FavoritesTable();
        const taskTable = new TaskTable();

        favoritesTable.queryContext(context, RdbCommon.QUERY_FAVORITES_All, (resultSet1, countRow1) => {
            if (countRow1 > 0) {
                favoritesArray = resultToFArray(resultSet1);
            }

            taskTable.queryContext(context, RdbCommon.QUERY_TASK_All, (resultSet2, countRow2) => {
                if (countRow2 > 0) {
                    taskArray = resultToTArray(resultSet2);
                }
                const showTaskTable = new ShowTaskTable();
                showTaskTable.queryContext(context, RdbCommon.QUERY_ShowTASK_All, (resultSet3, countRow3) => {
                    if (countRow3 > 0) {
                        showTaskArray = resultToSTArray(resultSet3);
                    }

                    let allData: object = {
                        "favoritesDataArray": favoritesArray,
                        "taskDataArray": taskArray,
                        "showTaskDataArray": showTaskArray
                    }

                    callback(allData)
                }, "0")
            }, "0")
        }, "0")
    }

    /**
     * 将数据导入数据库
     * @param allData{"favoritesDataArray": [], "taskDataArray": [], "showTaskDataArray": []}
     * @param callback(flag,reason)
     */
    async importData(allData, callback: Function, context: Context) {
        Logger.info("Backup", "----> enter importData <----");
        if (allData.favoritesDataArray.length <= 0 && allData.taskDataArray.length <= 0 && allData.showTaskDataArray.length <= 0) {
            callback(false, "数据缺失")
            return;
        }
        //先清空数据库各表中的内容
        try {
            const favoritesTable = new FavoritesTable();
            const taskTable = new TaskTable();
            const showTaskTable = new ShowTaskTable();
            let promise1 = await favoritesTable.executeSql(context, RdbCommon.DELETE_FAVORITES_All, "0")
            let promise2 = await taskTable.executeSql(context, RdbCommon.DELETE_TASK_All, "0")
            let promise3 = await showTaskTable.executeSql(context, RdbCommon.DELETE_ShowTASK_All, "0")
        } catch (err) {
            callback(false, "部分原始数据删除失败")
        }

        let favoritesArray: Array<FavoritesData> = []
        let taskArray: Array<TaskData> = []
        let showTaskArray: Array<ShowTaskData> = []
        for (let i = 0;i < allData.favoritesDataArray.length; i++) {
            let tmp: FavoritesData = new FavoritesData(0, "", "")
            tmp.id3 = allData.favoritesDataArray[i][0];
            tmp.favoritesName = allData.favoritesDataArray[i][1];
            tmp.favoritesColor = allData.favoritesDataArray[i][2];

            Logger.info("Backup", "importData favoritesArray: " + i + ": " + JSON.stringify(tmp));
            favoritesArray.push(tmp);

            const favoritesTable = new FavoritesTable();
            let promise = favoritesTable.executeSql(context, RdbCommon.INSERT_FAVORITES_DATA,
            tmp.id3.toString(), tmp.favoritesName, tmp.favoritesColor);
            promise.catch((err) => {
                callback(false, "分类数据缺失")
            })
        }

        for (let i = 0;i < allData.taskDataArray.length; i++) {
            let tmp: TaskData = new TaskData(0, "", "", 1, false, false,
                new Date(), new Date(), false, 1, new Date(), new Date(),
                0, 0, 0, [""], 1, false, new Date(), new Date(), false)
            //            Logger.info("Backup", "*****importData***** allData.taskDataArray: " + i + ": " + JSON.stringify(allData.taskDataArray));
            tmp.id1 = allData.taskDataArray[i][0];
            tmp.taskTitle = allData.taskDataArray[i][1];
            tmp.taskContent = allData.taskDataArray[i][2];
            tmp.id3 = allData.taskDataArray[i][3];
            if (tmp.id3 <= 1) {
                tmp.id3 = 1;
            }
            tmp.isImportant = allData.taskDataArray[i][4]
            tmp.isCollectible = allData.taskDataArray[i][5]
            tmp.startTime = allData.taskDataArray[i][6];
            tmp.endTime = allData.taskDataArray[i][7];
            tmp.isLoop = allData.taskDataArray[i][8]
            tmp.unitTimeNumber = allData.taskDataArray[i][9];
            if (tmp.unitTimeNumber <= 0) {
                tmp.unitTimeNumber = 1;
            }
            tmp.validStartTime = allData.taskDataArray[i][10];
            tmp.validEndTime = allData.taskDataArray[i][11];
            tmp.loopSet = allData.taskDataArray[i][12];
            tmp.loopBaseNumber = allData.taskDataArray[i][13];
            tmp.loopUnit = allData.taskDataArray[i][14];
            //            Logger.info("Backup", "importData taskDataArray: " + i + " loopUnit: " + tmp.loopUnit);
            tmp.loopDate = allData.taskDataArray[i][15];
            tmp.duration = allData.taskDataArray[i][16];
            tmp.isRemind = allData.taskDataArray[i][17]
            tmp.remindDate = allData.taskDataArray[i][18]
            tmp.remindTime = allData.taskDataArray[i][19]
            tmp.isFinish = allData.taskDataArray[i][20]

            Logger.info("Backup", "importData taskDataArray: " + i + ": " + JSON.stringify(tmp));
            taskArray.push(tmp);

            const taskTable = new TaskTable();
            let promise = taskTable.executeSql(context, RdbCommon.INSERT_TASK_DATA,
            tmp.id1.toString(), tmp.taskTitle, tmp.taskContent, tmp.id3.toString(), (tmp.isImportant ? 1 : 0).toString(), (tmp.isCollectible ? 1 : 0).toString(),
            tmp.startTime, tmp.endTime, (tmp.isLoop ? 1 : 0).toString(), tmp.unitTimeNumber.toString(),
            tmp.validStartTime, tmp.validEndTime, tmp.loopSet.toString(), tmp.loopBaseNumber.toString(), tmp.loopUnit.toString(),
            tmp.loopDate.toString(), tmp.duration.toString(), (tmp.isRemind ? 1 : 0).toString(), tmp.remindDate, tmp.remindTime,
            (tmp.isFinish ? 1 : 0).toString());
            promise.catch((err) => {
                callback(false, "事项数据缺失")
            })
        }


        for (let i = 0;i < allData.showTaskDataArray.length; i++) {
            let tmp: ShowTaskData = new ShowTaskData(0, new Date(), new Date(),
                new Date(), new Date(), 0, new Date(), 0, false);

            //            Logger.info("Backup", "*****importData***** allData.showTaskDataArray: " + i + ": " + JSON.stringify(allData.showTaskDataArray));
            tmp.id2 = allData.showTaskDataArray[i][0];
            tmp.startTime = allData.showTaskDataArray[i][1];
            tmp.endTime = allData.showTaskDataArray[i][2];
            tmp.validStartTime = allData.showTaskDataArray[i][3];
            tmp.validEndTime = allData.showTaskDataArray[i][4];
            tmp.completedCount = allData.showTaskDataArray[i][5];
            tmp.recentFinishedTime = allData.showTaskDataArray[i][6];
            tmp.id1 = allData.showTaskDataArray[i][7];
            tmp.isFinish = allData.showTaskDataArray[i][8]

            Logger.info("Backup", "importData showTaskArray: " + i + ": " + JSON.stringify(tmp));
            showTaskArray.push(tmp);

            const showTaskTable = new ShowTaskTable();
            let promise = showTaskTable.executeSql(context, RdbCommon.INSERT_ShowTASK_DATA,
            tmp.id2.toString(), tmp.startTime, tmp.endTime, tmp.validStartTime, tmp.validEndTime,
            tmp.completedCount.toString(), tmp.recentFinishedTime, tmp.id1.toString(), (tmp.isFinish ? 1 : 0).toString());
            promise.catch((err) => {
                callback(false, "显示数据缺失")
            })
        }

        callback(true, "导入数据成功")

    }
}

