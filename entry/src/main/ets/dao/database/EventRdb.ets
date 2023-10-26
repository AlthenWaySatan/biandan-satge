import  Logger  from "../utils/log/Logger";
import { RdbCommon } from '../../model/RdbCommon';
import data_rdb from "@ohos.data.relationalStore";
import featureAbility from "@ohos.ability.featureAbility";
import common from '@ohos.app.ability.common';

export class EventRdb {
  // private rdbStore: data_rdb.RdbStore = null;
  private tableName: string;
  private sqlCreateTable: string;

  constructor(tableName: string, sqlCreateTable: string) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
  }

  async getRdbStore(context: Context):Promise<data_rdb.RdbStore> {
    return new Promise((resolve) => {
      let rdbStore: data_rdb.RdbStore;
      if (rdbStore != null) {
        Logger.info("EventRdb", "The rdbStore exists.");
        resolve(rdbStore);
        return;
      }
      data_rdb.getRdbStore(context, RdbCommon.STORE_CONFIG, (err, rdb) => {
        if (err) {
          Logger.error("EventRdb", "gerRdbStore() failed, err: " + err);
          return;
        }
        rdbStore = rdb;
        rdbStore.executeSql(this.sqlCreateTable);
        Logger.info("EventRdb", `${this.tableName}` + ": getRdbStore() finished.");
        resolve(rdbStore);
      });
    })
  }

  insertData(context: Context, data, callback) {
    this.getRdbStore(context).then((rdbStore) => {
      if (!callback || typeof callback == "undefined" || callback == undefined) {
        Logger.error("EventRdb", "insertData() has no callback!");
        callback(-2);
        return;
      }
      const valueBucket = data;
      rdbStore.insert(this.tableName, valueBucket, function (err, ret) {
        if (err) {
          Logger.error("EventRdb", "insertData() failed, status: " + err);
          callback(ret);
          return;
        }
        Logger.info("EventRdb", "insertData() finished: " + ret);
        callback(ret);
      });
    })
  }

  deleteData(context: Context, predicates, callback) {
    this.getRdbStore(context).then((rdbStore) => {
      let resFlag: boolean = false;
      if (!callback || typeof callback == "undefined" || callback == undefined) {
        Logger.error("EventRdb", "deleteDate() has no callback!");
        callback(resFlag, "未知错误")
        return;
      }
      rdbStore.delete(predicates, function (err, ret) {
        if (err) {
          Logger.error("EventRdb", "deleteLine() failed, err: " + err);
          callback(resFlag, "删除失败")
          return;
        }
        Logger.info("EventRdb", "deleteDate() finished: " + ret);
        callback(!resFlag, "删除成功")
      });
    })
  }

  async updateData(context: Context, data, predicates): Promise<any> {
    const valueBucket = data;
    let rdbStore = await this.getRdbStore(context);
    let promise = rdbStore.update(valueBucket, predicates);
    promise.then(async (ret) => {
      Logger.info("EventRdb", "updateData() row count: " + ret);
    }).catch((err) => {
      Logger.error("EventRdb", "updateData() failed, err: " + err);
    })
    return promise;
  }

  query(context: Context, sql: string, bindArgs: string[], callback) {
    if (!callback || typeof callback == "undefined" || callback == undefined) {
      Logger.error("EventRdb", "query() has no callback!");
      return;
    }

//    Logger.info("EventRdb", "----query SQL: " + sql + "-----Args: " + bindArgs.toString()+"---");
    this.getRdbStore(context).then((rdbStore) => {
      rdbStore.querySql(sql, bindArgs, function (err, resultSet) {
        if (err) {
          Logger.error("EventRdb", "query() failed, err: " + err);
          return;
        }
        //      Logger.error("EventRdb", "query() :" + err);
        Logger.info("EventRdb", "query() finished! countRows: " + resultSet.rowCount);
        callback(resultSet);
        resultSet.close();
      });
    })
  }

  async queryPromise(context: Context, sql: string, bindArgs: string[]): Promise<any> {
    let rdbStore = await this.getRdbStore(context);
    let promise = rdbStore.querySql(sql, bindArgs);
    promise.then((resultSet) => {
      Logger.info("EventRdb", "queryPromise() success, countRow: " + resultSet.rowCount);
    }).catch((err) => {
      Logger.error("EventRdb", "queryPromise() failed, err: " + err);
    });
    return promise;
  }

  async executeSqlPromise(context: Context, sql: string, bindArgs: string[]): Promise<any>{
    let rdbStore = await this.getRdbStore(context);
    let promise = rdbStore.executeSql(sql, bindArgs);
    promise.then(() => {
      Logger.info("EventRdb", "executeSqlPromise() done success" );
    }).catch((err) => {
      Logger.error("EventRdb", "executeSqlPromise() failed, err: " + err);
    });
    return promise;
  }
}