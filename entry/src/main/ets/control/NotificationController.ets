import { ShowTaskData } from '../model/ShowTaskData';
import { ShowTaskImpl } from '../dao/controller/ShowTaskImpl';
import { ShowTaskInterface } from '../dao/controller/Interface/ShowTaskInterface';
import notification from '@ohos.notification';
import featureAbility from '@ohos.ability.featureAbility';
import reminderAgent from '@ohos.reminderAgent';
import data_storage from '@ohos.data.preferences';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
//import { ShowTaskData } from '../rdbCommon/bean/ShowTaskData';
//import wantAgent from '@ohos.wantAgent';

/**
 * 检查是否获取权限
 */
async function getPermission_PUBLISH_AGENT_REMINDER(context: Context): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.PUBLISH_AGENT_REMINDER'];
  let atManager = abilityAccessCtrl.createAtManager();
  let PermissionRequestResult = await atManager.requestPermissionsFromUser(context, array);
  let authResults0 = PermissionRequestResult.authResults[0];
  console.log("====>requestData====> " + authResults0 + ' ,');
  let ret: boolean = ((authResults0 == 0))
  return ret
}

/**
 * 轻量级数据库插入数据
 * @param EventId
 * @param ReminderId
 */
async function setStorage(EventId: number, ReminderId: number, context: Context) {
  let filePath = context.filesDir
  console.log('[Reminder] 设置（' + 'Reminder' + ',' + EventId + '):' + ReminderId);
  let storage = await data_storage.getPreferences(context, filePath + '/' + 'Reminder')
  storage.put(EventId.toString(), ReminderId.toString())
  storage.flush()
}

/**
 * 轻量级数据库查询数据
 * @param EventId
 */
async function getStorage(EventId: number, context: Context): Promise<number> {
  let filePath = context.filesDir
  let storage = await data_storage.getPreferences(context, filePath + '/' + 'Reminder')
  var value = Number(storage.get(EventId.toString(), "string"))
  console.log('[Reminder] 查询（' + 'Reminder' + ',' + EventId + '):' + value);
  return value
}

/**
 * 轻量级数据库清空数据
 */
async function clearStorage(context: Context) {
  let filePath = await context.filesDir
  let storage = await data_storage.getPreferences(context, filePath + '/' + 'Reminder')
  await storage.clear()
}

/**
 * 获取通知请求信息
 * @param id
 * @param title 标题
 * @param text 内容
 * @param publishTime 发布时间
 */
async function getReminderRequest(id: number, title: string, text: string, publishTime: number[]): Promise<reminderAgent.ReminderRequest> {
  var reminderRequest: reminderAgent.ReminderRequestCalendar = {
    reminderType: reminderAgent.ReminderType.REMINDER_TYPE_CALENDAR,
    notificationId: id,
    wantAgent: {
      pkgName: "cn.biandangroup.biandanas",
      abilityName: "cn.biandangroup.biandanas.entryAbility"
    },
    title: title,
    content: text + '   ',
    dateTime: {
      year: publishTime[0],
      month: publishTime[1],
      day: publishTime[2],
      hour: publishTime[3],
      minute: publishTime[4],
    },
    slotType: notification.SlotType.SERVICE_INFORMATION
  }
  console.log("[Reminder] return successfully + " + JSON.stringify(reminderRequest))
  return reminderRequest
}

function getDateInfo(showTime: number[], thisDate: number[]): string {
  var ret = ''
  if (showTime[0] != thisDate[0]) {
    ret = ret + showTime[0] + '年' + showTime[1] + '月' + showTime[2] + '日'
  }
  else if (showTime[1] != thisDate[1] || showTime[2] != thisDate[2]) {
    ret = ret + showTime[1] + '月' + showTime[2] + '日'
  }
  return '今天'
}

function getTimeInfo(showTime: number[], thisDate: number[], timeFormat24: boolean, showDate: boolean = true): string {
  var ret = showDate ? getDateInfo(showTime, thisDate) : ''
  if (timeFormat24) {
    return ret + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
  } else {
    if (showTime[3] < 12)
      return ret + '上午' + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    else if (showTime[3] == 12)
      return ret + '下午' + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    else
      return ret + '下午' + ((showTime[3] - 12) < 10 ? '0' : '') + (showTime[3] - 12) + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
  }
}

function getValidTimeInfo(validStartTime: number[], validEndTime: number[], thisDate: number[], timeFormat24: boolean): string {
  var ret = ''
  if ((validStartTime[0] == validEndTime[0] && validStartTime[1] == validEndTime[1] && validStartTime[2] == validEndTime[2])) {
    ret = getDateInfo(validStartTime, thisDate)
    if (validStartTime[3] == 0 && validEndTime[3] == 23 && validStartTime[4] == 0 && validEndTime[4] == 59)
      return ret + '全天'
    else
      return ret + getTimeInfo(validStartTime, thisDate, timeFormat24, true) + '-' + getTimeInfo(validEndTime, thisDate, timeFormat24, false)
  }
  return getTimeInfo(validStartTime, thisDate, timeFormat24) + '-' + getTimeInfo(validEndTime, thisDate, timeFormat24)
}

PersistentStorage.PersistProp('DefaultTimeFormat', 0)

/**
 * 发布通知
 * @param id
 * @param title 通知标题
 * @param StartTimeDate 有效开始日期
 * @param ValidStartTime 有效结束日期
 * @param EndTimeDate 有效开始时间
 * @param ValidEndTime 有效结束时间
 * @param publishTime 发布时间
 */
async function publishNotification(eventId: number, title: string,
                                   StartTimeDate: number[], ValidStartTime: number[],
                                   EndTimeDate: number[], ValidEndTime: number[],
                                   publishTime: number[], context: Context) {
  console.log('[Reminder] Add Notification eventId: ' + eventId +
  ' ,title: ' + title +
  ' ,StartTimeDate: ' + StartTimeDate +
  ' ,ValidStartTime: ' + ValidStartTime +
  ' ,EndTimeDate: ' + EndTimeDate +
  ' ,ValidEndTime: ' + ValidEndTime +
  ' ,publishTime: ' + publishTime)
  let validStartTime: number[] = StartTimeDate.concat(ValidStartTime)
  let validEndTime: number[] = EndTimeDate.concat(ValidEndTime)
  let DefaultTimeFormat: number = AppStorage.Get<number>("DefaultTimeFormat")
  let validTime: string = getValidTimeInfo(validStartTime, validEndTime, [publishTime[0], publishTime[1], publishTime[2]], DefaultTimeFormat == 0)
  let timer = await getReminderRequest(eventId, title, validTime, publishTime)
  if (await getPermission_PUBLISH_AGENT_REMINDER(context)) {
    let reminderId = await reminderAgent.publishReminder(timer)
    setStorage(eventId, reminderId, context)
  }
}

/**
 * 取消通知
 * @param id
 */
async function cancelNotification(eventId: number, context: Context) {
  let id = await getStorage(eventId, context)
  await reminderAgent.cancelReminder(id)
  console.log("[Reminder] cancelReminder promise: " + id);
}

/**
 * 取消所有通知
 */
async function cancelAllNotification(context: Context) {
  clearStorage(context)
  reminderAgent.cancelAllReminders().then(() => {
    console.log("[Reminder] cancelAllNotification Successfully")
  }).catch((err) => {
    console.log("[Reminder] cancelAllNotification error: " + err);
  })
}

export async function AddNotification(id1: number, context: Context) {
  console.log("[Reminder] Add Notification id1: " + id1);
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl()
  showTaskImpl.queryRemindById1(id1, async (taskTitle: string, showTaskData: ShowTaskData[]) => {
    console.log("[Reminder] taskTitle: " + taskTitle + ' ,showTaskData: ' + showTaskData.length);
    if (showTaskData.length > 0) {
      var title: string = taskTitle
      for (let i = 0;i < showTaskData.length; i++) {
        var id2: number = showTaskData[i].id2
        var startTimeDate: number[] = showTaskData[i].getStartTimeDate()
        startTimeDate[1]++;
        var validStartTime: number[] = showTaskData[i].getValidStartTime()
        var endTimeDate: number[] = showTaskData[i].getEndTimeDate()
        endTimeDate[1]++;
        var validEndTime: number[] = showTaskData[i].getValidEndTime()
        var publishTime: number[] = showTaskData[i].getRemindDateTime()
        publishTime[1]++;
        console.log('[Reminder] Try To Add Notification id2: ' + id2 +
        ' ,title: ' + title +
        ' ,StartTimeDate: ' + startTimeDate +
        ' ,ValidStartTime: ' + validStartTime +
        ' ,EndTimeDate: ' + endTimeDate +
        ' ,ValidEndTime: ' + validEndTime +
        ' ,publishTime: ' + publishTime)
        publishNotification(id2, title, startTimeDate, validStartTime, endTimeDate, validEndTime, publishTime, context)
      }
    }
  }, context)
}

export async function DeleteNotification(id1: number, context: Context) {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl()
  await showTaskImpl.queryRemindById1(id1, async (taskTitle: string, showTaskData: ShowTaskData[]) => {
    if (showTaskData.length > 0) {
      for (let i = 0;i < showTaskData.length; i++) {
        let id2: number = showTaskData[i].id2
        await cancelNotification(id2, context)
      }
    }
  }, context)
}

export async function DeleteOneNotification(EventId: number, context: Context) {
  console.log("[Reminder] Delete One Notification: " + EventId);
  cancelNotification(EventId, context)
}

export async function RebuildNotification(context: Context) {
  console.log("[Reminder] Rebuild Notification");
  cancelAllNotification(context)
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl()
  showTaskImpl.queryRemindAll((data: Array<[string, Array<ShowTaskData>]>) => {
    if (data.length > 0) {
      for (let i = 0;i < data.length; i++) {
        let title: string = data[i][0]
        let showTaskData: Array<ShowTaskData> = data[i][1]
        for (let j = 0;j < showTaskData.length; j++) {
          let id2: number = showTaskData[j].id2
          let startTimeDate: number[] = showTaskData[j].getStartTimeDate()
          startTimeDate[1]++;
          let validStartTime: number[] = showTaskData[j].getValidStartTime()
          let endTimeDate: number[] = showTaskData[j].getEndTimeDate()
          endTimeDate[1]++;
          let validEndTime: number[] = showTaskData[j].getValidEndTime()
          let publishTime: number[] = showTaskData[j].getRemindDateTime()
          publishTime[1]++;
          publishNotification(id2, title, startTimeDate, validStartTime, endTimeDate, validEndTime, publishTime, context)
        }
      }
    }
  }, context)
  //  let id2: number
  //  let title: string
  //  let startTimeDate: number[]
  //  let validStartTime: number[]
  //  let endTimeDate: number[]
  //  let validEndTime: number[]
  //  let publishTime: number[]
  //  publishNotification(id2, title, startTimeDate, validStartTime, endTimeDate, validEndTime, publishTime)
}

export async function publishNotification_test(context: Context) {
  console.log("[Reminder] test");
  let id: number = new Date().getTime()
  let title: string = '待办事项提醒'
  let text: string = '--:-----:--'
  let dateTime = new Date()
  let date = new Date(dateTime.setMinutes(dateTime.getMinutes() + 1));
  let dateNumber: number[] = [(date.getFullYear()), (date.getMonth()) + 1, (date.getDate()), (date.getHours()), (date.getMinutes())]
  //  let date: Date = new Date(2023, 3, 30, 16, 7)
  var timer = await getReminderRequest(id, title, text, dateNumber)

  if (await getPermission_PUBLISH_AGENT_REMINDER(context))
    reminderAgent.publishReminder(timer).then((reminderId) => {
      console.log("[Reminder] promise, reminderId = " + reminderId);
    }).catch((err) => {
      console.log("[Reminder] promise, err : " + JSON.stringify(err));
    })
}