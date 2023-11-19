import { RebuildNotification } from './NotificationController';
import { getNewAndImportData } from './TerminalsSyncController';
import { UpdateVersionNumber } from './TerminalsSyncController';
import { AddNotification, DeleteNotification, DeleteOneNotification } from './NotificationController';
import { getEventResource } from './RdbController';
import TaskImpl from '../dao/controller/TaskImpl';
import { getFolderResource } from './FolderController';
import { TaskData } from '../model/TaskData';
import { EventInfo } from '../model/EventInfo';
import { ShowTaskImpl } from '../dao/controller/ShowTaskImpl';
import { ShowTaskInterface } from '../dao/controller/Interface/ShowTaskInterface';
import { TaskInterface } from '../dao/controller/Interface/TaskInterface';
import EventResource from '../model/EventsResourceContact';
import CreateResource from '../model/CreateResourceContact';
import { getFolderClassify, addFolderCounter } from './FolderController';
import prompt from '@ohos.prompt'
import common from '@ohos.app.ability.common';

PersistentStorage.PersistProp('eventsShowResource', JSON.stringify([[], [], []]))

function getDateTime(yearNum: number, monthNum: number, dayNum: number): number[] {
  let date: number[] = [yearNum, monthNum, dayNum]
  let y = new Date().getFullYear()
  let m = new Date().getMonth() + 1
  let d = new Date().getDate()
  if (yearNum != y) {
    if (yearNum < y) date.push(23, 59)
    else date.push(0, 0)
  } else if (monthNum != m) {
    if (monthNum < m) date.push(23, 59)
    else date.push(0, 0)
  } else if (dayNum != d) {
    if (dayNum < d) date.push(23, 59)
    else date.push(0, 0)
  } else {
    date.push((new Date().getHours()), (new Date().getMinutes()));
  }
  return date
}

const userCyclePeriod: string[] = ['天', '周', '月', '年']
const weekResource: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
PersistentStorage.PersistProp('FirstDayOfWeek', 0)

function getUserCycleData(cycleBaseNumber: number, cycleUnit: number, cycleDate: string[]): string {
  var ret = '每' + userCyclePeriod[cycleUnit - 1] + '的'
  if (cycleBaseNumber > 1) {
    ret = '每 ' + cycleBaseNumber + ' ' + userCyclePeriod[cycleUnit - 1] + '的'
  }
  if (cycleDate.length == 0) {
    ret = ret + '...'
  }
  if (cycleUnit == 1) {
    return '每 ' + cycleBaseNumber + ' ' + userCyclePeriod[cycleUnit - 1]
  } else if (cycleUnit == 2) {
    let count = cycleDate.length
    console.log('count ' + count.toString())
    let FirstDayOfWeek: number = AppStorage.Get<number>('FirstDayOfWeek')
    for (let i = FirstDayOfWeek == 1 ? 0 : 1;i < 7; i++) {
      if (cycleDate.indexOf(i.toString()) != -1) {
        ret = ret + weekResource[i];
        if (-- count != 0)
          ret = ret + '，'
      }
    }
    if (FirstDayOfWeek != 1) {
      if (cycleDate.indexOf('0') != -1) {
        ret = ret + weekResource[0];
        if (-- count != 0)
          ret = ret + '，'
      }
    }
  } else if (cycleUnit == 3) {
    if (cycleDate.length != 0) {
      ret = ret + '第'
      let count = cycleDate.length
      for (let i = 1;i <= 31; i++) {
        if (cycleDate.indexOf(i.toString()) != -1) {
          ret = ret + i.toString();
          if (-- count != 0)
            ret = ret + '，'
        }
      }
      ret = ret + '天'
    }
  } else {
    for (let i = 0;i < cycleDate.length; i++) {
      ret = ret + cycleDate[i];
      if (i != cycleDate.length - 1)
        ret = ret + '，'
    }
  }
  return ret
}

function getCycleInfo(cycleState: number, loopBaseNumber: number, loopUnit: number, loopDate: string[]): string {
  switch (cycleState) {
    case 0:
      return '仅一次'
    case 2:
      return '每个非周末'
    case 3:
      return '每个周末'
    case 4:
      return '每天'
    case 5:
      return '艾宾浩斯'
    default:
      return getUserCycleData(loopBaseNumber, loopUnit, loopDate)
  }
}

function eventInfoToEventResource(eventInfo: EventInfo): EventResource {
  console.log('event: ' + JSON.stringify(eventInfo))

  let validStartTime: number[] = eventInfo.getStartTimeDate().concat(eventInfo.getValidStartTime())
  let validEndTime: number[] = eventInfo.getEndTimeDate().concat(eventInfo.getValidEndTime())

  validStartTime[1] += 1
  validEndTime[1] += 1

  return new EventResource(
  eventInfo.id2, //eventId
  eventInfo.id3, //folderId
  eventInfo.eventState, //state
  eventInfo.favoritesColor, //classify
  eventInfo.title, //title
  eventInfo.isImportant, //isImportant
  eventInfo.isCollectible, //isCollected
  eventInfo.isRemind, //isClock
    validStartTime,
    validEndTime,
  getCycleInfo(eventInfo.loopSet, eventInfo.loopBaseNumber, eventInfo.loopUnit, eventInfo.loopDate), //cyclicInfo
      (eventInfo.completedCount < eventInfo.unitTimeNumber) ? [] : eventInfo.getRecentFinishedTime(), //doneTime
  eventInfo.isLoop, //isCyclic
  eventInfo.completedCount, //doneTimes
  eventInfo.unitTimeNumber //allTimes
  )
}

/**
 * 获取资源文件
 * @param yearNum 查询的时间-年
 * @param monthNum 查询的时间-月
 * @param dayNum 查询的时间-日
 * @param folderId 查询的待办单号
 */
export async function getResource(yearNum: number, monthNum: number, dayNum: number, folderId: number, context: Context) {
  let doneNum = AppStorage.Get<number>("doneNum");
  let todoNum = AppStorage.Get<number>("todoNum");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  let obj = await getEventResource([yearNum, monthNum, dayNum], folderId, context)

  doneNum = obj[0]
  todoNum = obj[1]
  eventsShowResource = [[], [], []]

  for (let i = 0;i < obj[2].length; i++)
    eventsShowResource[0].push(eventInfoToEventResource(obj[2][i]))
  for (let i = 0;i < obj[3].length; i++)
    eventsShowResource[1].push(eventInfoToEventResource(obj[3][i]))
  for (let i = 0;i < obj[4].length; i++)
    eventsShowResource[2].push(eventInfoToEventResource(obj[4][i]))

  AppStorage.Set<number>("doneNum", doneNum)
  AppStorage.Set<number>("todoNum", todoNum)
  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/**
 * 获取资源文件
 * @param yearNum 查询的时间-年
 * @param monthNum 查询的时间-月
 * @param dayNum 查询的时间-日
 * @param folderId 查询的待办单号
 */
export async function getFormResource(yearNum: number, monthNum: number, dayNum: number, folderId: number, context: Context): Promise<[number, number, EventResource[][]]>{

  let obj = await getEventResource([yearNum, monthNum, dayNum], folderId, context)

  let doneNum = obj[0]
  let todoNum = obj[1]
  let eventsShowResource:EventResource[][] = [[], [], []]

  for (let i = 0;i < obj[2].length; i++)
    eventsShowResource[0].push(eventInfoToEventResource(obj[2][i]))
  for (let i = 0;i < obj[3].length; i++)
    eventsShowResource[1].push(eventInfoToEventResource(obj[3][i]))
  for (let i = 0;i < obj[4].length; i++)
    eventsShowResource[2].push(eventInfoToEventResource(obj[4][i]))

  return [doneNum, todoNum, eventsShowResource];
}

export async function refreshResource(context: Context) {
  await getNewAndImportData(context, false)
  let showDate = AppStorage.Get<number[]>('showDate');
  let folderId = AppStorage.Get<number>('folderId');
  getFolderResource(context);
  await getResource(showDate[0], showDate[1], showDate[2], folderId, context);
}

/**
 * 获取背景颜色
 * @param classify
 */
function getBackgroundColor(classify: string): Resource {
  switch (classify) {
    case 'red':
      return $r('app.color.translucentSaturation_red')
    case 'orange':
      return $r('app.color.translucentSaturation_orange')
    case 'yellow':
      return $r('app.color.translucentSaturation_yellow')
    case 'green':
      return $r('app.color.translucentSaturation_green')
    case 'lakeBlue':
      return $r('app.color.translucentSaturation_lakeBlue')
    case 'lightBlue':
      return $r('app.color.translucentSaturation_lightBlue')
    case 'darkBlue':
      return $r('app.color.translucentSaturation_darkBlue')
    case 'purple':
      return $r('app.color.translucentSaturation_purple')
    default:
      return $r('app.color.foreground')
  }
}

/**
 * 获取资源文件
 * @param yearNum 查询的时间-年
 * @param monthNum 查询的时间-月
 * @param dayNum 查询的时间-日
 * @param folderId 查询的待办单号
 */
export async function getResource_little(yearNum: number, monthNum: number, dayNum: number, folderId: number, context: Context): Promise<[number, number, [string, Resource, number][]]> {

  let dateTime: number[] = getDateTime(yearNum, monthNum, dayNum)
  var doneNum = 0
  var todoNum = 0
  var eventsShowResource: [string, Resource, number][] = []

  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();

  return new Promise((resolve) => {
    showTaskImpl.queryDisplayTaskContext(new Date(dateTime[0], dateTime[1] - 1, dateTime[2], dateTime[3], dateTime[4]), folderId, (
      finishedCount: number, notFinishedCount: number, TodoArray: EventInfo[], PassArray: EventInfo[], DoneArray: EventInfo[]
    ) => {
      console.log('1-2.事件内容：{事件分类:' + folderId + ',日期:' + dateTime[0] + '年' + dateTime[1] + '月' + dateTime[2] + '日' + dateTime[3] + '时' + dateTime[4] + '分}');

      doneNum = finishedCount
      todoNum = notFinishedCount

      if (TodoArray == null) TodoArray = []
      if (PassArray == null) PassArray = []
      if (DoneArray == null) DoneArray = []

      console.log('   ==> 1-2.事件内容(number)：' + finishedCount + ', ' + notFinishedCount);
      console.log('   ==> 1-2.事件内容(length)：' + TodoArray.length + ', ' + PassArray.length + ', ' + DoneArray.length);

      for (let i = 0;i < TodoArray.length; i++)
        eventsShowResource.push([TodoArray[i].title, getBackgroundColor(TodoArray[i].favoritesColor), 0])
      for (let i = 0;i < PassArray.length; i++)
        eventsShowResource.push([PassArray[i].title, getBackgroundColor(PassArray[i].favoritesColor), 1])
      for (let i = 0;i < DoneArray.length; i++)
        eventsShowResource.push([DoneArray[i].title, getBackgroundColor(DoneArray[i].favoritesColor), 2])

      resolve([doneNum, todoNum, eventsShowResource])
    }, context)
  })
}

/**
 * 获取是否有事项
 */
export async function getFormResource_little(yearNum: number, monthNum: number, dayNum: number, folderId: number, context: Context): Promise<boolean> {
  let obj = await getEventResource([yearNum, monthNum, dayNum], folderId, context);
  return new Promise((resolve) => {
      resolve((obj[0] + obj[1] > 0));
  })
}

/**
 * 获取完成比率
 */
export function getDoneRate(): number {
  let doneNum = AppStorage.Get<number>("doneNum");
  let todoNum = AppStorage.Get<number>("todoNum");
  if ((todoNum + doneNum) == 0)
    return 0
  else
    return (doneNum) / (todoNum + doneNum)
}

/**
 * 获取选择数
 * @param type 事件类型
 */
export function getOneCounter(type: number): number {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));
  var ret: number = 0;
  for (let i = 0;i < eventsShowResource[type].length; i++) {
    if (eventsShowResource[type][i].isChecked)
      ret++;
  }
  return ret;
}

/**
 * 获取选择总数
 */
export function getCounter(): number {
  let isHidden = AppStorage.Get<boolean[]>("isHidden")
  var ret: number = 0;
  for (let i = 0;i < 3; i++) {
    if (!isHidden[i])
      ret += getOneCounter(i);
  }
  return ret;
}
/*------------------------------------------------------完成-------------------------------------------------------*/
/**
 * 提交完成事项
 * @param id 事件的ID
 * @param thisTime 完成的时间
 */
//function CompEvent(id: number, thisTime: number[]): boolean {
//  prompt.showToast({
//    message: '1-3.完成一次事项: {事件的ID:' + id + ',完成的时间:' + thisTime[0] + '年' + thisTime[1] + '月' + thisTime[2] + '日' + thisTime[3] + '时' + thisTime[4] + '分' + thisTime[5] + '秒}',
//    duration: 5000,
//  });
//  return true
//}

/**
 * 完成一次事项
 * @param eventId 事件的ID
 */
export async function AddCompTime(eventId: number, context: Context):Promise<void> {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();

  return new Promise((resolve) => {
    showTaskImpl.addCompleteCount(eventId, new Date(), (flag: boolean, reason: string) => {
      console.log('1-3.完成一次事项: {事件的ID:' + eventId + ',完成的时间:' + new Date().getFullYear() + '年' +
      (new Date().getMonth() + 1) + '月' + new Date().getDate() + '日' + new Date().getHours() + '时' +
      new Date().getMinutes() + '分' + new Date().getSeconds() + '秒}',);
      if (flag) {
        refreshResource(context)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '完成事项失败，' + reason,
          duration: 1000,
        });
      }
      resolve()
    }, context)
  })
}


/**
 * 取消完成一次事项
 * @param eventId 事件的ID
 */
export async function SubCompTime(eventId: number, context: Context):Promise<void> {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  return new Promise((resolve) => {
    showTaskImpl.cancelCompleteCount(eventId, (flag: boolean, reason: string) => {
      console.log('1-4.取消完成一次事项: {事件的ID:' + eventId + '}')
      if (flag) {
        refreshResource(context)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '取消完成事项失败，' + reason,
          duration: 1000,
        });
      }
      resolve();
    }, context)
  })
}

/*------------------------------------------------------选择-------------------------------------------------------*/
/**
 * 获取是否全选
 */
export function getIsAllChecked(): boolean {
  let isHidden = AppStorage.Get<boolean[]>("isHidden")
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));
  for (let i = 0;i < 3; i++) {
    if (!isHidden[i] && (getOneCounter(i) != eventsShowResource[i].length))
      return false;
  }
  if (!isHidden[0] || !isHidden[1] || !isHidden[2])
    return true;
  else
    return false;
}

/**
 * 修改所有的的事件
 * @param value 是否被选择
 */
export function changeAllChoice(value: boolean): void {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (var i = 0; i < 3; i++) {
    for (var j = 0;j < eventsShowResource[i].length; j++) {
      eventsShowResource[i][j].isChecked = value;
    }
  }

  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/**
 * 选择事件
 * @param state 选择状态
 * @param type 事件分类
 * @param thingsId 事件ID
 */
export function checkEvents(state: boolean, eventId: number): void {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (let i = 0;i < 3; i++) {
    var id = eventsShowResource[i].findIndex((item) => item.eventId == eventId)
    if (id >= 0)
      eventsShowResource[i][id].isChecked = state;
  }

  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/*------------------------------------------------------移动-------------------------------------------------------*/

/**
 * 改动某个事件的待办单分类
 * @param id 事件的ID
 * @param folderId 改动的待办单目标
 */
async function setFolder(id: number, folderId: number, context: Context): Promise<[boolean, string]> {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  const taskImpl: TaskInterface = new TaskImpl();
  console.log('1-10.移动一个事项: {事件的ID:' + id + ',移动的目标:' + folderId + '}')

  return new Promise((resolve) => {
    showTaskImpl.queryID1ByID2(id, (id1: number, isLoop: boolean, unitTimeNumber: number) => {
      taskImpl.changeFavorites(id1, folderId, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    }, context)
  });

}

/**
 * 改动所有所选事件的待办单分类
 * @param folderId 改动的待办单目标ID
 */
export async function setAllFolder(folderId: number, context: Context) {
  let isHidden = AppStorage.Get<boolean[]>("isHidden");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  let classify = getFolderClassify(folderId)

  console.info(folderId.toString() + ' ' + classify)

  for (let i = 0;i < 3; i++)
    if (!isHidden[i])
      for (let j = 0;j < eventsShowResource[i].length; j++)
        if (eventsShowResource[i][j].isChecked) {
          let ret: [boolean, string] = await setFolder(eventsShowResource[i][j].eventId, folderId, context)
          if (ret[0]) {
            addFolderCounter(eventsShowResource[i][j].folderId, -1)
            addFolderCounter(folderId, 1)
            eventsShowResource[i][j].folderId = folderId
            eventsShowResource[i][j].classify = classify
            UpdateVersionNumber()
          } else {
            prompt.showToast({
              message: '移动待办单失败，' + ret[1],
              duration: 1000,
            });
          }
        }

  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/**
 * 改动所有所选事件的待办单分类
 * @param folderId 需要改动的待办单ID
 */
export function setAllFolderByFolder(folderId: number) {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (let i = 0;i < 3; i++)
    for (let j = 0;j < eventsShowResource[i].length; j++)
      if (eventsShowResource[i][j].folderId == folderId) {
        addFolderCounter(eventsShowResource[i][j].folderId, -1)
        addFolderCounter(-1, 1)
        eventsShowResource[i][j].folderId = -1
        eventsShowResource[i][j].classify = ''
      }

  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/*------------------------------------------------------删除-------------------------------------------------------*/
/**
 * 选项中是否有重复事件
 */
export function isCyclic(): boolean {
  let isHidden = AppStorage.Get<boolean[]>("isHidden");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (let i = 0;i < 3; i++) {
    if (!isHidden[i]) {
      for (let j = 0;j < eventsShowResource[i].length; j++) {
        if (eventsShowResource[i][j].isChecked && eventsShowResource[i][j].isCyclic)
          return true;
      }
    }
  }
  return false;
}

/**
 * 删除某个事项
 * @param id 删除的事项ID
 * @param isWhole 是否删除整个重复
 */
async function deleteEach(id: number, isWhole: boolean, context: Context): Promise<[boolean, string]> {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();

  if (isWhole) {
    console.log('1-7.删除整个事项: {事件的ID:' + id.toString() + '}',)
    return new Promise((resolve) => {
      showTaskImpl.deleteAll(id, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    });
  } else {
    console.log('1-6.删除一个事项: {事件的ID:' + id.toString() + '}',)
    return new Promise((resolve) => {
      showTaskImpl.deleteSingleShow(id, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    });
  }
}

/**
 * 删除所有所选的事项
 * @param isWhole 是否删除整个重复
 */
export async function deleteAll(isWhole: boolean, context: Context) {
  let doneNum = AppStorage.Get<number>("doneNum");
  let todoNum = AppStorage.Get<number>("todoNum");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  var thingsId: number[] = []
  for (let i = 0;i < 3; i++)
    for (let j = 0;j < eventsShowResource[i].length; j++)
      if (eventsShowResource[i][j].isChecked) {
        let ret: [boolean, string] = await deleteEach(eventsShowResource[i][j].eventId, isWhole, context)
        if (ret[0]) {
          if (isWhole || !eventsShowResource[i][j].isCyclic) {
            addFolderCounter(eventsShowResource[i][j].folderId, -1)
            addFolderCounter(0, -1)
            if (eventsShowResource[i][j].isCollected)
              addFolderCounter(-2, -1)
            if (eventsShowResource[i][j].isImportant)
              addFolderCounter(-3, -1)
          }
          thingsId.push(eventsShowResource[i][j].eventId)
          if (eventsShowResource[i][j].state == 2) doneNum--
          else todoNum--
          if (isWhole) {
            DeleteNotification(eventsShowResource[i][j].eventId, context)
          } else {
            DeleteOneNotification(eventsShowResource[i][j].eventId, context)
          }
          UpdateVersionNumber()
        } else {
          prompt.showToast({
            message: '删除待办事项失败，' + ret[1],
            duration: 1000,
          });
        }
      }

  for (let i = 0;i < thingsId.length; i++) {
    for (let j = 0; j < 3; j++) {
      eventsShowResource[j] = eventsShowResource[j].filter(item => item.eventId != thingsId[i])
    }
  }

  AppStorage.Set<number>("doneNum", doneNum)
  AppStorage.Set<number>("todoNum", todoNum)
  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))

  refreshResource(context);
}

/*------------------------------------------------------收藏-------------------------------------------------------*/
/**
 * 获取是否全部收藏
 */
export function getIsAllCollect(): boolean {
  let isHidden = AppStorage.Get<boolean[]>("isHidden");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (let i = 0;i < 3; i++) {
    if (!isHidden[i]) {
      for (let j = 0;j < eventsShowResource[i].length; j++) {
        if (eventsShowResource[i][j].isChecked && !eventsShowResource[i][j].isCollected)
          return false;
      }
    }
  }
  return true;
}

/**
 * 设置单个是否收藏
 * @param value 是否收藏
 * @param id 事项的ID
 */
async function setCollect(value: boolean, id: number, context: Context): Promise<[boolean, string]> {
  console.log('1.7/8 收藏一个事项（整个重复）: id: ' + id + ' ,value:' + value)

  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  const taskImpl: TaskInterface = new TaskImpl();

  return new Promise((resolve) => {
    showTaskImpl.queryID1ByID2(id, (id1: number, isLoop: boolean, unitTimeNumber: number) => {
      taskImpl.changeCollectible(id1, value, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    }, context)
  });

}

/**
 * 设置所有所选的是否收藏
 * @param value 是否收藏
 */
export async function setAllCollect(value: boolean, context: Context) {
  let isHidden = AppStorage.Get<boolean[]>("isHidden");
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  for (let i = 0;i < 3; i++)
    if (!isHidden[i])
      for (let j = 0;j < eventsShowResource[i].length; j++)
        if (eventsShowResource[i][j].isChecked && eventsShowResource[i][j].isCollected != value) {

          let ret: [boolean, string] = await setCollect(value, eventsShowResource[i][j].eventId, context)
          if (ret[0]) {
            if (eventsShowResource[i][j].isCollected != value)
              addFolderCounter(-2, value ? 1 : -1)
            eventsShowResource[i][j].isCollected = value
            console.log("collect? " + eventsShowResource[i][j].eventId + ':' + eventsShowResource[i][j].isCollected)
            AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
            UpdateVersionNumber()
          } else {
            prompt.showToast({
              message: '修改是否收藏失败，' + ret[1],
              duration: 1000,
            });
          }
        }

  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

/**
 * 创建新事项
 * @param newCreator
 */
export function createEvent(newCreator: CreateResource, context: Context) {
  console.log('2-2.创建一个事件: ' + JSON.stringify(newCreator))
  let taskData: TaskData = newCreator.toTaskData()
  console.log('2-2.创建一个事件: ' + JSON.stringify(taskData))

  const taskImpl: TaskInterface = new TaskImpl();

  taskImpl.insert(taskData, async (id1: number, flag: boolean, reason: string) => {
    console.log('2-2.创建一个事件: ' + flag)

    if (flag) {
      //      var newEvent: EventResource = newCreator.toEventResource(id1)
      addFolderCounter(0, 1)
      addFolderCounter(newCreator.thisFolderId, 1)
      if (newCreator.isCollect)
        addFolderCounter(-2, 1)
      if (newCreator.isImportant)
        addFolderCounter(-3, 1)
      refreshResource(context);
      await AddNotification(id1, context)
      UpdateVersionNumber()
    } else {
      prompt.showToast({
        message: '添加待办事项失败，' + reason,
        duration: 1000,
      });
    }
  }, context)
}


function funToPromise(taskData: TaskData, changedCycle: boolean, context: Context) {
  const taskImpl: TaskInterface = new TaskImpl();
  return new Promise((resolve) => {
    if (changedCycle) {
      taskImpl.updateLoopTask(taskData, (flag: boolean, reason: string) => {
        console.log(JSON.stringify(taskData))
        console.log('flag: ' + flag + ' ,reason: ' + reason);
        if (flag) {
          refreshResource(context)
          UpdateVersionNumber()
          resolve([flag, reason])
        } else {
          prompt.showToast({
            message: '修改待办事项失败，' + reason,
            duration: 1000,
          });
          resolve([flag, reason])
        }
      }, context)
    } else {
      taskImpl.updateNotLoopTask(taskData, (flag: boolean, reason: string) => {
        console.log(JSON.stringify(taskData))
        if (flag) {
          refreshResource(context)
          UpdateVersionNumber()
          resolve([flag, reason])
        } else {
          prompt.showToast({
            message: '修改待办事项失败，' + reason,
            duration: 1000,
          });
          resolve([flag, reason])
        }
      }, context)
    }
  })
}
/**
 * 编辑事件
 * @param id1
 * @param newCreator
 * @param changedCycle 是否修改了循环模式
 */
export async function editThisEvent(id1: number, newCreator: CreateResource, changedCycle: boolean, context: Context) {
  await DeleteNotification(id1, context)

  let taskData: TaskData = newCreator.toTaskData()

  await funToPromise(taskData, changedCycle, context)

  await AddNotification(id1, context)

  // if (changedCycle) {
  //   console.log('3-3.编辑重复事项信息: ' + JSON.stringify(newCreator))
  //   taskImpl.updateLoopTask(taskData, (flag: boolean, reason: string) => {
  //     console.log(JSON.stringify(taskData))
  //     console.log('flag: ' + flag + ' ,reason: ' + reason);
  //     if (flag) {
  //       refreshResource()
  //       UpdateVersionNumber()
  //     } else {
  //       prompt.showToast({
  //         message: '修改待办事项失败，' + reason,
  //         duration: 1000,
  //       });
  //     }
  //   })
  // } else {
  //   console.log('3-2.编辑非重复事项信息: ' + JSON.stringify(newCreator))
  //   taskImpl.updateNotLoopTask(taskData, (flag: boolean, reason: string) => {
  //     console.log(JSON.stringify(taskData))
  //     if (flag) {
  //       refreshResource()
  //       UpdateVersionNumber()
  //     } else {
  //       prompt.showToast({
  //         message: '修改待办事项失败，' + reason,
  //         duration: 1000,
  //       });
  //     }
  //   })
  // }
}

/**
 * 顺延事件请求
 * @param eventId 顺延事件的ID
 * @param startTime 新的开始时间
 * @param endTime 新的结束时间
 * @param isToday 是否是今天的时间（如果是则覆盖后两个，否则覆盖前三个）
 */
async function putOffEvent(eventId: number, isToday: boolean, context: Context): Promise<[boolean, string]> {
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  let newEndDate: Date = new Date((new Date().getFullYear()), (new Date().getMonth()), (new Date().getDate()), 23, 59)
  if (isToday) {
    console.log('2-2.顺延事件（当天）:{ 事件ID：' + eventId +
    ' 新有效结束时间： ' + newEndDate.getHours() + ':' + newEndDate.getMinutes() + '}')
    return new Promise((resolve) => {
      showTaskImpl.deferredTaskToday(eventId, newEndDate, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    });
  } else {
    console.log('2-3.顺延事件（当天以前）:{ 事件ID：' + eventId +
    ' 新有效结束时间： ' + newEndDate.getFullYear() + '-' + (newEndDate.getMonth() + 1) + '-' + newEndDate.getDate() + '}')
    return new Promise((resolve) => {
      showTaskImpl.deferredTaskBefore(eventId, newEndDate, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    });
  }
}

/**
 * 顺延一个事件
 * @param eventId 顺延事件的ID
 */
export async function putOff(eventId: number, context: Context) {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  let showDate = AppStorage.Get<number[]>("showDate");
  let isToday: boolean = ((showDate[0] == (new Date().getFullYear())) && (showDate[1] == (new Date().getMonth() + 1)) && (showDate[2] == (new Date().getDate())))

  let id = eventsShowResource[1].findIndex((item) => item.eventId == eventId)

  if (id == -1) return;

  let ret = await putOffEvent(eventId, isToday, context)

  if (ret[0]) {
    eventsShowResource[1][id].state = 0
    let temp: EventResource = eventsShowResource[1][id]
    eventsShowResource[1] = eventsShowResource[1].filter(item => item.eventId != eventId)
    if (isToday) {
      temp.validEndTime = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), 23, 59] //有效结束时间
      eventsShowResource[0].push(temp)
    } else {
      let todoNum = AppStorage.Get<number>("todoNum");
      todoNum--
      AppStorage.Set<number>("todoNum", todoNum)
    }
    AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
    UpdateVersionNumber()
  } else {
    prompt.showToast({
      message: '顺延失败，' + ret[1],
      duration: 1000,
    });
  }

}

/**
 * 顺延所有事件
 */
export async function putOffAll(context: Context) {
  let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));

  let showDate = AppStorage.Get<number[]>("showDate");
  let isToday: boolean = ((showDate[0] == (new Date().getFullYear())) && (showDate[1] == (new Date().getMonth() + 1)) && (showDate[2] == (new Date().getDate())))


  for (let i = 0;i < eventsShowResource[1].length; i++) {
    let ret = await putOffEvent(eventsShowResource[1][i].eventId, isToday, context)

    if (ret[0]) {
      eventsShowResource[1][i].state = 0
      let temp: EventResource = eventsShowResource[1][i]

      if (isToday) {
        temp.validEndTime = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), 23, 59]
        eventsShowResource[0].push(temp)
      } else {
        let todoNum = AppStorage.Get<number>("todoNum");
        todoNum--
        AppStorage.Set<number>("todoNum", todoNum)
      }
      UpdateVersionNumber()
    } else {
      prompt.showToast({
        message: '顺延失败，' + ret[1],
        duration: 1000,
      });
    }

  }
  eventsShowResource[1] = []
  AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
}

function stringToNumberArr(tmp: string[]): number[] {
  let ret: number[] = []
  for (let i = 0;i < tmp.length; i++)
    ret.push(parseInt(tmp[i]))
  if (ret == [null]) {
    ret = []
  }
  return ret
}

function taskDataToCreateResource(taskData: TaskData): CreateResource {

  let startTimeDate: number[] = taskData.getStartTimeDate()
  let endTimeDate: number[] = taskData.getEndTimeDate()
  let remindDate: number[] = taskData.getRemindDate()

  startTimeDate[1]++
  endTimeDate[1]++
  remindDate[1]++

  let ret: CreateResource = new CreateResource(
    endTimeDate, //cycleEndDate
  taskData.taskTitle, //name
  taskData.id3, //thisFolderId
  taskData.isCollectible, //isCollect
  taskData.isImportant, //isImportant
    startTimeDate, //thisDate
  taskData.taskContent, //comment
    taskData.isRemind ? 2 : 0, //clockState
  remindDate.concat(taskData.getRemindTime()), //clockTime
    [0, 0], //clockTimeLong
  taskData.loopSet, //cycleState
    startTimeDate, //cycleStartDate
  taskData.loopBaseNumber, //cycleBaseNumber
  taskData.loopUnit, //cycleUnit
      taskData.loopSet != 4 ? stringToNumberArr(taskData.loopDate) : [], //cycleDate
    [1, 1], //tempDate
      taskData.loopSet == 4 ? taskData.loopDate : [], //cycleDateYear
    false, //cycleYearShow
  taskData.duration, //cycleDateLimit
  startTimeDate.concat(taskData.getValidStartTime()), //validStartTime
  endTimeDate.concat(taskData.getValidEndTime()), //validEndTime
  )
  ret.id1 = taskData.id1
  ret.countNumber = taskData.unitTimeNumber
  console.log(JSON.stringify(ret));
  return ret
}

export function queryCreateResource(id2: number, context: Context) {
  let thisEvent = AppStorage.Get<CreateResource>("thisEvent")
  // let editEvent = AppStorage.Get<boolean>("editEvent")

  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  const taskImpl: TaskInterface = new TaskImpl();

  showTaskImpl.queryID1ByID2(id2, (id1: number, isLoop: boolean, unitTimeNumber: number) => {
    taskImpl.queryTask((id1), (taskData: TaskData) => {
      console.log("query id1:" + id1)
      if (taskData != null) {
        thisEvent = taskDataToCreateResource(taskData)
        // editEvent = true
        // AppStorage.Set<boolean>("editEvent", editEvent)
        AppStorage.Set<CreateResource>("thisEvent", thisEvent)
        console.log("set done :" + AppStorage.Get<boolean>("editEvent"))
      }
    }, context)
  }, context)
}

/**
 * 修改事项象限
 * @param id2
 * @param isImportant
 * @param newValidEndTime
 */
export function changeQuadrant(id2: number, newIsImportant: boolean, newValidEndTime: number[], context: Context) {
  console.log(JSON.stringify(newValidEndTime));
  const showTaskImpl: ShowTaskInterface = new ShowTaskImpl();
  const taskImpl: TaskInterface = new TaskImpl();
  showTaskImpl.queryID1ByID2(id2, (id1: number, isLoop: boolean, unitTimeNumber: number) => {
    taskImpl.queryTask((id1), (taskData: TaskData) => {
      console.log("query id1:" + id1)
      if (taskData != null) {
        let thisEvent:CreateResource = taskDataToCreateResource(taskData);
        thisEvent.isImportant = newIsImportant;
        thisEvent.validEndTime = newValidEndTime;
        console.log(JSON.stringify(thisEvent));
        editThisEvent(thisEvent.id1, thisEvent, false, context);
        console.log("set done :" + AppStorage.Get<boolean>("editEvent"))
      }
    }, context)
  }, context)
}