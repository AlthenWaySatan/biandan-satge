import { TaskData } from '../../../model/TaskData';
import { ShowTaskData } from '../../../model/ShowTaskData';

export interface ShowTaskInterface {
  /**
   * Task表每插入一项，若不重复事件，则插入一项即可；若是重复事件，需转化插入多项
   * @param taskData
   * @param callback(flag)
   */
  transformAndInsert(taskData: TaskData, callback: Function)

  /**
   * 向showTask表中插入一项显示事项
   * @param showTaskData
   * @para callback(id2,flag,reason)
   */
  insert(showTaskData: ShowTaskData, callback: Function): void

  /**
   * 删除一个事项,若其是个不重复事项，则创建表也删除;若是个重复事项，则只删除显示事项
   * @para id2
   * @para callback(flag,reason)
   */
  deleteSingleShow(id2: number, callback: Function)

  /**
   * 删除整个重复事项
   * @para id2
   * @para callback(flag,reason)
   */
  deleteAll(id2: number, callback: Function): void

  /*
  * 更新showTask中的信息
  * 完成次数+1
  * 需判断这个显示事件是否已完成
  * @param recentFinishedTime 'xxxx-xx-xx xx:xx:xx' 单引号 年-月-日 时:分:秒
  * @para callback(flag,reason)
   */
  addCompleteCount(id2: number, recentFinishedTime: Date, callback: Function): void

  /*
  * 更新showTask中的信息
  * 取消完成 完成次数-1
  * 修改这个显示事件为未完成
  * @para callback(flag,reason)
   */
  cancelCompleteCount(id2: number, callback: Function): void


  /**
   * 顺延当天显示事项
   * @param id2
   * @param endTime 用于转化为validEndTime(hh:mm:00)
   * @para callback(flag,reason)
   */
  deferredTaskToday(id2: number, endTime: Date, callback: Function): void

  /**
   * 顺延以前的显示事件
   * @param id2
   * @param endTime 用于转化为endTime(yyyy-mm-dd)
   * @para callback(flag,reason)
   */
  deferredTaskBefore(id2: number,  endTime: Date, callback: Function): void

  /**
   * 根据id2查询showTask详细信息
   * callback(showTaskData/null)
   */
  queryShowTaskById2(id2: number, callback: Function)

  /**
   * 根据id1查询所有相关showTask详细信息
   * callback(Array<showTaskData>/null)
   */
  queryAllShowTaskById1(id1: number, callback: Function)

  /**
   * 根据id1获取其标题、全部对应显示事项的各个时间与提醒
   * @param id1
   * @param callback(taskTitle,Array<ShowTaskData>)
   * remindDateTime如果是非循环事件，那么应该由TaskData的remindDate和remindTime拼接；
   * 如果是循环事件，那么应该由ShowTaskData的startTime和TaskData的remindTime拼接；
   */
  queryRemindById1(id1: number, callback: Function)

  /**
   * 查询所有,获取其标题、全部对应显示事项的各个时间与提醒
   * @param callback(Array<[taskTitle,Array<ShowTaskData>]>)
   * remindDateTime如果是非循环事件，那么应该由TaskData的remindDate和remindTime拼接；
   * 如果是循环事件，那么应该由ShowTaskData的startTime和TaskData的remindTime拼接；
   */
  queryRemindAll(callback: Function)

  /**
   * 查询id2对应的id1/isLoop/unitTimeNumber
   * @param 1d2
   * @para callback(id1,isLoop,unitTimeNumber)
   */
  queryID1ByID2(id2: number, callback: Function)

  /**
   * 根据日期（年，月，日，时，分）
   * 和分类（0:全部；-1:默认；-2:我的收藏；-3:重要；整数：待办id3）查询待办内容
   * @param date(year,month,day,hour,minutes)
   * @param classify(0/-1/-2/-3/id3)
   * @param callback(finishedCount,notFinishedCount,
   *                 Array<EventInfo>,Array<EventInfo>,Array<EventInfo>)
   */
  queryDisplayTaskContext( date: Date, classify: number, callback: Function)

}