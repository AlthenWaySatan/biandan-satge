/*
数据库结构、sql语句
 */
import relationalStore from '@ohos.data.relationalStore';
export class RdbCommon {
  /**
   * Rdb database config.
   */
  static readonly STORE_CONFIG = {
    name: "taskDatabase.db",
    securityLevel: relationalStore.SecurityLevel.S2
  };

  /**
   * Task table config.
   */
  static readonly TASK_TABLE = {
    tableName: "Task",
    sqlCreate: "CREATE TABLE IF NOT EXISTS Task (" +
    "id1            INTEGER  PRIMARY KEY AUTOINCREMENT," +
    "taskTitle      STRING   NOT NULL," +
    "taskContent    STRING, " +
    "id3            INTEGER  REFERENCES favorites (id3) NOT NULL," +
    "isCollectible  BOOLEAN  DEFAULT (false) NOT NULL , " +
    "isImportant    BOOLEAN  DEFAULT (false) NOT NULL ," +
    "startTime      DATE     NOT NULL," +
    "endTime        DATE     NOT NULL, " +
    "isLoop         BOOLEAN  DEFAULT (false) NOT NULL, " +
    "unitTimeNumber INTEGER  DEFAULT (1) NOT NULL, " +
    "validStartTime TIME     DEFAULT [00:00:00] NOT NULL," +
    "validEndTime   TIME     DEFAULT [23:59:59] NOT NULL," +
    "loopSet        INTEGER  DEFAULT (0), loopBaseNumber INTEGER, " +
    "loopUnit       INTEGER, " +
    "loopDate       STRING," +
    "duration       INTEGER  DEFAULT (0) NOT NULL, " +
    "isRemind       BOOLEAN  DEFAULT (false) NOT NULL," +
    "remindDate     DATE," +
    "remindTime     TIME," +
    "isFinish       BOOLEAN  DEFAULT (false) NOT NULL )",
    columns: ["id1", "taskTitle", "taskContent", "id3", "isCollectible", "isImportant", "startTime", "endTime",
      "isLoop", "unitTimeNumber", "validStartTime", "validEndTime", "loopSet", "loopBaseNumber", "loopUnit", "loopDate",
      "duration", "isRemind", "remindDate", "remindTime", "isFinish"]
  }

  /**
   * 根据id1查询task的全部信息
   */
  static readonly QUERY_TASK_INFORMATION_3 = "SELECT * FROM Task WHERE id1=?"

  /**
   * 根据id3获取所有task的id1
   */
  static readonly QUERY_ALL_id1_byId3 = "SELECT id1 FROM Task WHERE id3=?"

  /**
   * 查询全部待办数量、默认待办数量（某分类的待办数量）、收藏的数量、重要待办数量
   */
  static readonly QUERY_TASK_NUMBER_1 = "SELECT COUNT(*) AS 'EventNumber' FROM Task "
  static readonly QUERY_TASK_NOTNULL = " WHERE id1 != ?"
  static readonly QUERY_TASK_default = " WHERE id3 = ?"
  static readonly QUERY_TASK_isCollectable = " WHERE isCollectible = ?"
  static readonly QUERY_TASK_isImportant = " WHERE isImportant = ?"


  /**
   * showTask table config.
   */
  static readonly SHOW_TASK_TABLE = {
    tableName: "showTask",
    sqlCreate: "CREATE TABLE IF NOT EXISTS showTask (" +
    "id2                INTEGER  PRIMARY KEY AUTOINCREMENT," +
    "startTime          DATE     NOT NULL," +
    "endTime            DATE     NOT NULL," +
    "validStartTime     TIME     DEFAULT [00:00:00] NOT NULL," +
    "validEndTime       TIME     DEFAULT [23:59:59] NOT NULL," +
    "completedCount     INTEGER  DEFAULT (0) NOT NULL," +
    "recentFinishedTime DATETIME," +
    "id1                INTEGER  REFERENCES Task (id1) NOT NULL," +
    "isFinish           BOOLEAN  DEFAULT (false) NOT NULL)",
    columns: ["id2", "startTime", "endTime", "validStartTime", "validEndTime",
      "completedCount", "recentFinishedTime", "id1", "isFinish"]
  }

  /**
   * 根据id2查询id1、isLoop、unitTimeNumber
   */
  static readonly QUERY_ID1_BY_ID2 = "SELECT Task.id1,Task.isLoop,Task.unitTimeNumber" +
  "  FROM Task JOIN showTask USING(id1) WHERE showTask.id2 =?"

  /**
   * 根据id2查询显示事项
   */
  static readonly QUERY_showTask_BY_ID2 = "SELECT * FROM showTask WHERE id2 =?"

  /**
   * 根据id1查询所有相关的显示事项
   */
  static readonly QUERY_All_showTask_BY_ID1 = "SELECT * FROM showTask WHERE id1 =?"

  /**
   * 根据id2完成一次事项（单次）,更新最近完成时间
   */
  static readonly UPDATE_ADD_completedCount="UPDATE showTask SET completedCount=completedCount+1,recentFinishedTime=? WHERE id2=?"

  /**
   * 判断并更新showTask是否已完成
   */
  static readonly UPDATE_JUDGE_isFinish="UPDATE showTask SET isFinish=true " +
  "WHERE id2=? AND completedCount >= (SELECT unitTimeNumber FROM Task WHERE Task.id1=showTask.id1)"

  /**
   * 根据日期（年，月，日，时，分）
   * 和分类（0:全部；-1:默认；-2:我的收藏；-3:重要；其他整数：待办id3）
   * 查询未完成、已完成的事件数量
   */
  static readonly QUERY_COUNT_BY_DateClassify = "SELECT COUNT(*) AS 'EventNumber'" +
  " FROM Task JOIN showTask USING(id1) "
  static readonly WHERE_CONDITION_showTask_isFinish = " WHERE showTask.isFinish =? "
  static readonly AND_CONDITION_showTask_Date = " AND showTask.startTime <=? AND showTask.endTime >=? "
  static readonly AND_CONDITION_all = " AND showTask.id2 !=? "
  static readonly AND_CONDITION_id3 = " AND Task.id3 =? "
  static readonly AND_CONDITION_isCollectible = " AND Task.isCollectible =? "
  static readonly AND_CONDITION_isImportant = " AND Task.isImportant =? "

  /**
   * 根据日期（年，月，日，时，分）
   * 和分类（0:全部；-1:默认；-2:我的收藏；-3:重要；其他整数：待办id3）
   * 查询未完成、已过期、已完成事件的详细
   */
  static readonly QUERY_EventInfo_BY_DateClassify = "SELECT showTask.id2,showTask.isFinish," +
  "Task.taskTitle,Task.isCollectible,Task.isImportant,showTask.startTime,showTask.endTime,Task.unitTimeNumber," +
  "Task.isLoop,Task.loopSet,Task.loopBaseNumber,Task.loopUnit,Task.loopDate,Task.isRemind," +
  "favorites.id3,favorites.favoritesColor,showTask.completedCount,showTask.validStartTime,showTask.validEndTime," +
  "showTask.recentFinishedTime " +
  " FROM showTask JOIN Task JOIN favorites ON favorites.id3 = Task.id3 AND Task.id1 = showTask.id1 "
  //未过期与此时此刻比较
  static readonly AND_CONDITION_Valid = " AND ( showTask.endTime > ? " +
  "OR (showTask.endTime = ? AND showTask.validEndTime > ?)) "
  //已过期与此时此刻比较
  static readonly AND_CONDITION_OutEndTime = " AND (showTask.endTime <? " +
  "OR (showTask.endTime =? AND showTask.validEndTime <=?)) "
  //根据事件开始时间和有效结束时间升序排序
  static readonly ORDER_BY_TIME_asc=" order by showTask.startTime asc, showTask.validEndTime asc"

  /**
   * favorites table config.
   */
  static readonly FAVORITES_TABLE = {
    tableName: "favorites",
    sqlCreate: "CREATE TABLE IF NOT EXISTS favorites (" +
    "id3            INTEGER  PRIMARY KEY AUTOINCREMENT," +
    "favoritesName  STRING   NOT NULL," +
    "favoritesColor STRING   NOT NULL)",
    columns: ["id3", "favoritesName", "favoritesColor"]
  }

  /**
   *查询所有分类及其待办数量
   */
  static readonly QUERY_FAVORITES_ALL = "SELECT * FROM favorites WHERE id3 != ?"

  /**
   * 根据id3查询分类信息
   */
  static readonly QUERY_FAVORITES_byId3 = "SELECT * FROM favorites WHERE id3 = ?"

  /**
   * 查询三个表中的所有数据,id != 0
   */
  static readonly QUERY_FAVORITES_All = "SELECT * FROM favorites WHERE id3 != ?"
  static readonly QUERY_TASK_All = "SELECT * FROM Task WHERE id1 != ?"
  static readonly QUERY_ShowTASK_All = "SELECT * FROM showTask WHERE id2 != ?"

  /**
   * 清空三个表中的所有数据,id != 0
   */
  static readonly DELETE_FAVORITES_All = "DELETE FROM favorites WHERE id3 != ?"
  static readonly DELETE_TASK_All = "DELETE FROM Task WHERE id1 != ?"
  static readonly DELETE_ShowTASK_All = "DELETE FROM showTask WHERE id2 != ?"

  /**
   * 向表中插入一行完整数据（包含id）
   * 3/21/9参数
   */
  static readonly INSERT_FAVORITES_DATA = "INSERT INTO favorites(id3,favoritesName,favoritesColor) VALUES(?,?,?)"
  static readonly INSERT_TASK_DATA = "INSERT INTO Task " +
  "(id1,taskTitle,taskContent,id3,isImportant,isCollectible,startTime,endTime,isLoop,unitTimeNumber, " +
  "validStartTime,validEndTime,loopSet,loopBaseNumber,loopUnit,loopDate,duration," +
  "isRemind,remindDate,remindTime,isFinish)"+
  " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
  static readonly INSERT_ShowTASK_DATA = "INSERT INTO showTask" +
  "(id2,startTime,endTime,validStartTime,validEndTime,completedCount,recentFinishedTime,id1,isFinish) VALUES (?,?,?,?,?,?,?,?,?)"

}