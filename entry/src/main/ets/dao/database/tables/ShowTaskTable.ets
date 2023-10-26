import Logger from '../../utils/log/Logger';
import { RdbCommon } from '../../../model/RdbCommon';
import data_rdb from '@ohos.data.rdb';
import { EventRdb } from '../EventRdb';
import { ShowTaskData } from '../../../model/ShowTaskData';

export default class ShowTaskTable {

    constructor() {}

    insertData(context: Context, showTaskData: ShowTaskData, callback: Function) {
        const valueBucket = generateBucket(showTaskData);
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        showTaskTable.insertData(context, valueBucket, (ret) => {
            if (ret < 0 || ret == null || typeof ret == "undefined") {
                Logger.error("ShowTaskTable", "Insert showTaskData failed:" + JSON.stringify(valueBucket));
                callback(ret, false, "创建失败！");
            } else {
                Logger.info("ShowTaskTable", "Insert showTaskData success:" + JSON.stringify(valueBucket));
                callback(ret, true, "创建成功");
            }
        });
        //    Logger.info("ShowTaskTable", "Insert showTaskData :" + JSON.stringify(valueBucket) + "finished.");
    }

    deleteDate(context: Context, showTaskId2: number, callback: Function, taskId1?) {
        Logger.info("ShowTaskTable", "delete showTaskData start");
        let predicates = new data_rdb.RdbPredicates(RdbCommon.SHOW_TASK_TABLE.tableName);
        if (!taskId1 || typeof taskId1 == "undefined" || taskId1 == undefined) {
            predicates.equalTo('id2', showTaskId2);
        } else {
            predicates.equalTo('id1', taskId1);
        }
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        showTaskTable.deleteData(context, predicates, callback);
    }

    update(context: Context, showTaskData: ShowTaskData): Promise<any> {
        const valueBucket = generateBucket(showTaskData);
        let predicates = new data_rdb.RdbPredicates(RdbCommon.SHOW_TASK_TABLE.tableName);
        predicates.equalTo("id2", showTaskData.id2);
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        let promise = showTaskTable.updateData(context, valueBucket, predicates);

        Logger.info("ShowTaskTable", "update finished:" + JSON.stringify(valueBucket));
        return promise;
    }

    queryContext(context: Context, sql: string, callback: Function, ...bindArgs: string[]) {
        Logger.info("ShowTaskTable", "queryContext SQL: " + sql + "-----Args: " + bindArgs.toString());
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        showTaskTable.query(context, sql, bindArgs, function (resultSet) {
            if (resultSet.rowCount <= 0) {
                Logger.error("ShowTaskTable", "queryContext query no results");
                callback(resultSet, resultSet.rowCount);
                return;
            }
            callback(resultSet, resultSet.rowCount);
        });
    }

    queryNumber(context: Context, sql: string, callback: Function, ...bindArgs: string[]) {
        Logger.info("ShowTaskTable", "queryNumber SQL:" + sql + "-----Args: " + bindArgs.toString());
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        showTaskTable.query(context, sql, bindArgs, function (resultSet) {
            let countRow = resultSet.rowCount;
            if (countRow <= 0) {
                Logger.error("ShowTaskTable", "queryNumber query no results");
                callback(0);
            } else {
                resultSet.goToFirstRow();
                let count: number = resultSet.getDouble(resultSet.getColumnIndex("EventNumber"));
                callback(count);
            }
        });
    }

    executeSql(context: Context, sql: string, ...bindArgs: string[]): Promise<any> {
        Logger.info("ShowTaskTable", "executeSql SQL: " + sql + "-----Args: " + bindArgs.toString());
        const showTaskTable = new EventRdb(RdbCommon.SHOW_TASK_TABLE.tableName, RdbCommon.SHOW_TASK_TABLE.sqlCreate);
        let promise = showTaskTable.executeSqlPromise(context, sql, bindArgs);
        return promise;
    }
}

function generateBucket(showTaskData: {}) {
    let obj = {};
    RdbCommon.SHOW_TASK_TABLE.columns.forEach((item) => {
        if (item != 'id2') {
            obj[item] = showTaskData[item];
        }
    });
    return obj;
}