import Logger from '../../utils/log/Logger';
import { RdbCommon } from "../../../model/RdbCommon";
import data_rdb from "@ohos.data.rdb";
import { EventRdb } from "../EventRdb";
import { TaskData } from "../../../model/TaskData";

export default class TaskTable {
  private taskTable = new EventRdb(RdbCommon.TASK_TABLE.tableName, RdbCommon.TASK_TABLE.sqlCreate);

  constructor(context, callback: Function=() => {
  }) {
    this.taskTable.getRdbStore(context, callback);
  }

  getRdbStore(context, callback: Function=() => {
  }) {
    this.taskTable.getRdbStore(context, callback);
  }

  insertData(taskData: TaskData, callback: Function) {
    let valueBucket = generateBucket(taskData);
    this.taskTable.insertData(valueBucket, (ret) => {
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

  deleteDate(taskId1: number, callback: Function) {
    Logger.info("TaskTable", "delete task start");
    let predicates = new data_rdb.RdbPredicates(RdbCommon.TASK_TABLE.tableName);
    predicates.equalTo("id1", taskId1);
    this.taskTable.deleteData(predicates, callback);
  }

  update(taskData: TaskData): Promise<any> {
    const valueBucket = generateBucket(taskData);
    let predicates = new data_rdb.RdbPredicates(RdbCommon.TASK_TABLE.tableName);
    predicates.equalTo("id1", taskData.id1);
    let promise = this.taskTable.updateData(valueBucket, predicates);

    Logger.info("TaskTable", "update finished:" + JSON.stringify(valueBucket));
    return promise;
  }

  promiseQueryContext(sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("TaskTable", "promiseQueryContext SQL: " + sql + "-----Args: " + bindArgs.toString());
    let promise = this.taskTable.queryPromise(sql,bindArgs);
    return promise;
  }

  queryContext(sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("TaskTable", "queryContext SQL:" + sql + "-----Args: " + bindArgs.toString());
    this.taskTable.query(sql, bindArgs, function (resultSet) {
      if (resultSet.rowCount <= 0) {
        Logger.error("TaskTable", "queryContext query no results");
        callback([], 0);
      } else {
        callback(resultSet, resultSet.rowCount);
      }
    });
  }

  queryNumber(sql: string, callback: Function, ...bindArgs: string[]) {
    Logger.info("TaskTable", "queryNumber SQL:" + sql + "-----Args: " + bindArgs.toString());
    this.taskTable.query(sql, bindArgs, function (resultSet) {
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

  executeSql(sql: string, ...bindArgs: string[]):Promise<any>{
    Logger.info("TaskTable", "executeSql SQL: " + sql + "-----Args: " + bindArgs.toString());
    let promise = this.taskTable.executeSqlPromise(sql,bindArgs);
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
