import  Logger  from "../utils/log/Logger";
import { RdbCommon } from '../../model/RdbCommon';
import data_rdb from "@ohos.data.relationalStore";
import featureAbility from "@ohos.ability.featureAbility";
import common from '@ohos.app.ability.common';

export class EventRdb {
  private rdbStore: any = null;
  private tableName: string;
  private sqlCreateTable: string;

  constructor(tableName: string, sqlCreateTable: string) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
  }

  getRdbStore(callback) {
    if (!callback || typeof callback == "undefined" || callback == undefined) {
      Logger.error("EventRdb", "getRdbStore() has no callback!");
      return;
    }
    if (this.rdbStore != null) {
      Logger.info("EventRdb", "The rdbStore exists.");
      callback();
      return;
    }
    let context: Context = getContext(this) as common.Context;
    data_rdb.getRdbStore(context, RdbCommon.STORE_CONFIG, (err, rdb) => {
      if (err) {
        Logger.error("EventRdb", "gerRdbStore() failed, err: " + err);
        return;
      }
      this.rdbStore = rdb;
      this.rdbStore.executeSql(this.sqlCreateTable);
      Logger.info("EventRdb", `${this.tableName}` + ": getRdbStore() finished.");
      callback();
    });
  }

  insertData(data, callback) {
    if (!callback || typeof callback == "undefined" || callback == undefined) {
      Logger.error("EventRdb", "insertData() has no callback!");
      callback(-2);
      return;
    }
    const valueBucket = data;
    this.rdbStore.insert(this.tableName, valueBucket, function (err, ret) {
      if (err) {
        Logger.error("EventRdb", "insertData() failed, status: " + err);
        callback(ret);
        return;
      }
      Logger.info("EventRdb", "insertData() finished: " + ret);
      callback(ret);
    });
  }

  deleteData(predicates, callback) {
    let resFlag: boolean = false;
    if (!callback || typeof callback == "undefined" || callback == undefined) {
      Logger.error("EventRdb", "deleteDate() has no callback!");
      callback(resFlag, "未知错误")
      return;
    }
    this.rdbStore.delete(predicates, function (err, ret) {
      if (err) {
        Logger.error("EventRdb", "deleteLine() failed, err: " + err);
        callback(resFlag, "删除失败")
        return;
      }
      Logger.info("EventRdb", "deleteDate() finished: " + ret);
      callback(!resFlag, "删除成功")
    });
  }

  updateData(data, predicates): Promise<any> {
    const valueBucket = data;
    let promise = this.rdbStore.update(valueBucket, predicates);
    promise.then(async (ret) => {
      Logger.info("EventRdb", "updateData() row count: " + ret);
    }).catch((err) => {
      Logger.error("EventRdb", "updateData() failed, err: " + err);
    })
    return promise;
  }

  query(sql: string, bindArgs: string[], callback) {
    if (!callback || typeof callback == "undefined" || callback == undefined) {
      Logger.error("EventRdb", "query() has no callback!");
      return;
    }

//    Logger.info("EventRdb", "----query SQL: " + sql + "-----Args: " + bindArgs.toString()+"---");

    this.rdbStore.querySql(sql, bindArgs, function (err, resultSet) {
      if (err) {
        Logger.error("EventRdb", "query() failed, err: " + err);
        return;
      }

//      Logger.error("EventRdb", "query() :" + err);

      Logger.info("EventRdb", "query() finished! countRows: " + resultSet.rowCount);
      callback(resultSet);
      resultSet.close();
    });
  }

  queryPromise(sql: string, bindArgs: string[]): Promise<any> {
    let promise = this.rdbStore.querySql(sql, bindArgs);
    promise.then((resultSet) => {
      Logger.info("EventRdb", "queryPromise() success, countRow: " + resultSet.rowCount);
    }).catch((err) => {
      Logger.error("EventRdb", "queryPromise() failed, err: " + err);
    });
    return promise;
  }

  executeSqlPromise(sql: string, bindArgs: string[]): Promise<any>{
    let promise = this.rdbStore.executeSql(sql, bindArgs);
    promise.then(() => {
      Logger.info("EventRdb", "executeSqlPromise() done success" );
    }).catch((err) => {
      Logger.error("EventRdb", "executeSqlPromise() failed, err: " + err);
    });
    return promise;
  }
}