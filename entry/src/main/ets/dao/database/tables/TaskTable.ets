import Logger from '../../utils/log/Logger';
import { RdbCommon } from "../../../model/RdbCommon";
import data_rdb from "@ohos.data.rdb";
import { EventRdb } from "../EventRdb";
import { TaskData } from "../../../model/TaskData";

export default class TaskTable {
  constructor() {}

  insertData(context: Context, taskData: TaskData, callback: Function) {
    let valueBucket = generateBucket(taskData);
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    taskTable.insertData(context, valueBucket, (ret) => {
      if (ret < 0 || ret == null || typeof ret == "undefined") {
        Logger.error("TaskTable", "Insert taskData failed:"+ JSON.stringify(valueBucket));
        callback(ret, false, "创建失败！");
      } else {
        Logger.info("TaskTable", "Insert taskData success:" + JSON.stringify(valueBucket));
        callback(ret, true, "创建成功");
      }
    });
//    Logger.info("TaskTable", "Insert taskData :" + JSON.stringify(valueBucket) + "finished.");
  }

  deleteDate(context: Context, taskId1: number, callback: Function) {
    Logger.info("TaskTable", "delete task start");
    let predicates = new data_rdb.RdbPredicates(RdbCommon.TASK_TABLE.tableName);
    predicates.equalTo("id1", taskId1);
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    taskTable.deleteData(context, predicates, callback);
  }

  update(context: Context, taskData: TaskData): Promise<any> {
    const valueBucket = generateBucket(taskData);
    let predicates = new data_rdb.RdbPredicates(RdbCommon.TASK_TABLE.tableName);
    predicates.equalTo("id1", taskData.id1);
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    let promise = taskTable.updateData(context, valueBucket, predicates);

    Logger.info("TaskTable", "update finished:" + JSON.stringify(valueBucket));
    return promise;
  }

  promiseQueryContext(context: Context, sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("TaskTable", "promiseQueryContext SQL: " + sql + "-----Args: " + bindArgs.toString());
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    let promise = taskTable.queryPromise(context, sql,bindArgs);
    return promise;
  }

  queryContext(context: Context, sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("TaskTable", "queryContext SQL:" + sql + "-----Args: " + bindArgs.toString());
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    taskTable.query(context, sql, bindArgs, function (resultSet) {
      if (resultSet.rowCount <= 0) {
        Logger.error("TaskTable", "queryContext query no results");
        callback([], 0);
      } else {
        callback(resultSet, resultSet.rowCount);
      }
    });
  }

  queryNumber(context: Context, sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("TaskTable", "queryNumber SQL:" + sql + "-----Args: " + bindArgs.toString());
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    taskTable.query(context, sql, bindArgs, function (resultSet) {
      let countRow: number = resultSet.rowCount;
      if (countRow <= 0) {
        Logger.error("TaskTable", "queryNumber query no results");
        callback(0);
      } else {
        resultSet.goToFirstRow();
        let count: number = resultSet.getDouble(resultSet.getColumnIndex("EventNumber"));
        callback(count);
      }
    });
  }

  executeSql(context: Context, sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("TaskTable", "executeSql SQL: " + sql + "-----Args: " + bindArgs.toString());
    const taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);
    let promise = taskTable.executeSqlPromise(context, sql,bindArgs);
    return promise;
  }
}

function generateBucket(taskData: TaskData) {
  let obj = {};
  RdbCommon.TASK_TABLE.columns.forEach((item) => {
    if (item != "id1") {
      if (item == "loopDate") {
        obj[item] = taskData[item].toString();
      }else {
        obj[item] = taskData[item];
      }
    }
  });
  return obj;
}
