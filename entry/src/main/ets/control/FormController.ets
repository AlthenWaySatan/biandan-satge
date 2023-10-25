import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import { get_accent } from './AccentController';
import { getStartDate, getNextNDay, getNextNMonth} from './CalendarControl';
import formProvider from '@ohos.app.form.formProvider';
import { getFormFolderTitle } from './FolderController';
import EventResource from '../model/EventsResourceContact';
import { getFormResource, getFormResource_little, AddCompTime, SubCompTime } from './EventsController'
import { setStorage, getStorage, getAllStorage } from './StorageController'
import { FormInfo } from '../entryformability/EntryFormAbility'
import common from '@ohos.app.ability.common';

interface formData {
  [key: string]: any;
}

/**
 * 改变原始数据为卡片显示数据
 * @param item 原始数据
 * @param isPath 是否过期
 * @param isDone 是否已完成
 * @returns 卡片显示数据
 */
function turnIntoFormEvent(item: EventResource, isPath: boolean, isDone: boolean): object {
  let DefaultTimeFormat = AppStorage.Get<number>('DefaultTimeFormat')
  return {
    'Title': item.title,
    'Time': item.getDescription([new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate()], DefaultTimeFormat == 0),
    'isWarning': item.isImportant,
    'isHighlight': item.isCollected,
    'stateResource': item.getStateResource(),
    'isClock': item.isClock,
    'isPath': isPath,
    'isDone': isDone,
    'State': item.state,
    'eventId': item.eventId
  }
}

/**
 * 获取一周内的日历数据
 * @param date 这周开始的日期
 * @param folder 代办单id
 * @returns 这一周每天的显示数据
 */
async function getWeek(date: number[], folder: number): Promise<object[]> {
  let ret = [];
  for (let i = 0; i < 7; i++) {
    let temp = getNextNDay(date, i);
    ret.push({
      date: temp[2],
      month: temp[1],
      year: temp[0],
      haveEvent: await getFormResource_little(date[0], date[1], date[2], folder)
    })
  }
  return ret;
}

/**
 * 获取一月内的日历数据
 * @param date 当天的日期
 * @param month 当天的月份
 * @param year 当天的年份
 * @param folder 待办单id
 * @returns 这一月每天的显示数据
 */
async function getFormDate(date: number, month: number, year: number, folder: number): Promise<object[][]> {
  let startDate = getStartDate([year, month, date]);
  let ret = [
    await this.getWeek(startDate, folder),
    await this.getWeek(getNextNDay(startDate, 7), folder),
    await this.getWeek(getNextNDay(startDate, 14), folder),
    await this.getWeek(getNextNDay(startDate, 21), folder),
    await this.getWeek(getNextNDay(startDate, 28), folder)
  ];
  if (getNextNDay(startDate, 35)[1] == month)
    ret.push(await this.getWeek(getNextNDay(startDate, 35), folder));
  return ret;
}

/**
 * 获取原始数据中的某一个显示数据
 * @param Odata 原始数据
 * @param index 需要显示的数据
 * @returns 显示数据
 */
function getIndex(Odata: EventResource[][], index: number): object {
  if (index < Odata[0].length)
    return this.turnIntoFormEvent(Odata[0][index], false, false);
  index -= Odata[0].length;
  if (index < Odata[1].length)
    return this.turnIntoFormEvent(Odata[1][index], true, false);
  index -= Odata[1].length;
  if (index < Odata[2].length)
    return this.turnIntoFormEvent(Odata[2][index], false, true);
  return null;
}

/**
 * 获取某个卡片的全部数据
 * @param type 卡片类型
 * @param dimension 卡片尺寸
 * @param date 查询的日期
 * @param folder 查询的待办单
 * @param page 查询的页码
 * @returns 全部所需数据
 */
export async function getFormObject(type: string, dimension: number, date: number[], folder: number, page: number): Promise<object> {

  let day = date[2];
  let month = date[1];
  let year = date[0];

  let eventLength = 5;

  let formDate = month.toString() + "月" + day.toString() + "日";
  let formFolder = getFormFolderTitle(folder);
  let formAccentColor = get_accent();

  let temp: [number, number, EventResource[][]] = await getFormResource(year, month, day, folder);

  let formDoneNum = temp[0];
  let formAllNum = temp[1];
  let formDoneRate = formAllNum == 0 ? 0 : (formDoneNum / formAllNum);
  let formDoneStr = (formDoneNum).toString() + "/" + (formAllNum).toString();

  let event_O: EventResource[][] = temp[2];

  // let day = new Date().getDate();
  // let month = new Date().getMonth() + 1;
  // let year = new Date().getFullYear();
  // let eventLength = 5;
  // let formDate = month.toString() + "月" + day.toString() + "日";
  // let formFolder = "全部代办";
  // let formAccentColor = get_accent()
  // let formDoneNum = 3;
  // let formAllNum = 5;
  // let formDoneRate = formAllNum == 0 ? 0 : (formDoneNum / formAllNum);
  // let formDoneStr = (formDoneNum).toString() + "/" + (formAllNum).toString();

  let ret: formData = {
    Date: formDate,
    Folder: formFolder,
    accentColor: formAccentColor,
    doneNum: formDoneNum,
    allNum: formAllNum,
    doneRate: formDoneRate,
    doneStr: formDoneStr,
    pageNumber: page
  }
  switch (type) {
    case 'recommend': {
      ret['event'] = this.getIndex(event_O, page);
      if (ret['event'] === null) {
        ret['pageNumber'] = 0;
        ret['event'] = this.getIndex(event_O, 0);
      }
      break;
    }
    case 'todolist': {
      if (dimension == 4)
        eventLength = 10;
      let eventList = [];
      function getEventList(page: number): object[] {
        let eventList = [];
        for (let i = 0; i < eventLength; i++) {
          let temp = this.getIndex(event_O, page * eventLength + i);
          if (temp === null)
            break;
          eventList.push(temp);
        }
        return eventList;
      }
      eventList = getEventList(page);
      if (eventList.length == 0) {
        ret['pageNumber'] = 0;
        eventList = getEventList(0);
      }
      ret['events'] = eventList;
      ret['widthLength'] = (dimension <= 2 ? 2 : 4);
      ret['listLength'] = eventLength;
      break;
    }
    case 'fourQuadrants': {
      let eventList = [[], [], [], []];
      function getEventList(page: number): object[][] {
        let eventList = [[], [], [], []];
        let trashLength: number[];
        for (let q = 0; q < 4; q++) {
          trashLength.push(page * eventLength);
        }
        for (let i = 0; i < 3; i++) {
          let isPathTemp: boolean = (i == 2);
          let isDoneTemp: boolean = (i == 3);
          for (let j = 0;j < event_O[i].length; j++) {
            for (let q = 0; q < 4; q++) {
              if (event_O[i][j].checkQuadrant((q & 1) == 1, q > 1, date) && eventList[q].length < eventLength) {
                if (trashLength[q] == 0)
                  eventList[q].push(this.turnIntoFormEvent(event_O[i][j], isPathTemp, isDoneTemp));
                else
                  trashLength[q]--;
              }
            }
          }
        }
        return eventList;
      }
      eventList = getEventList(page);
      if (eventList[0].length == 0 && eventList[1].length == 0 && eventList[2].length == 0 && eventList[3].length == 0) {
        ret['pageNumber'] = 0;
        eventList = getEventList(0);
      }
      ret['events'] = eventList;
      break;
    }
    case 'calendar': {
      ret['thisYear'] = year;
      ret['thisMonth'] = month;
      ret['thisDate'] = day;
      let eventList = [];
      function getEventList(page: number): object[] {
        let eventList = [];
        for (let i = 0; i < eventLength; i++) {
          let temp = this.getIndex(event_O, page * eventLength + i);
          if (temp === null)
            break;
          eventList.push(temp);
        }
        return eventList;
      }
      eventList = getEventList(page);
      if (eventList.length == 0) {
        ret['pageNumber'] = 0;
        eventList = getEventList(0);
      }
      ret['Month'] = year.toString() + "年" + month.toString() + "月";
      ret['events'] = eventList;
      ret['dates'] = await this.getFormDate(day, month, year, folder);
      let FirstDayOfWeek = AppStorage.Get<number>('FirstDayOfWeek')
      ret['dateHeader'] = (FirstDayOfWeek == 1) ? ['日', '一', '二', '三', '四', '五', '六'] : ['一', '二', '三', '四', '五', '六', '日'];
      break;
    }
  }

  return ret;
}

/**
 * 根据卡片信息修改卡片
 * @param formId
 */
export async function UpdateForm(formId: string) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('updateForm thisFormInfo' + JSON.stringify(thisFormInfo))

  getFormObject(thisFormInfo.formName, thisFormInfo.formDimension, thisFormInfo.formDate, thisFormInfo.formFolder, thisFormInfo.formPage).then((obj) => {
    console.log('updateForm ', formId, JSON.stringify(obj));
    // Called to return a FormBindingData object.
    let formData = formBindingData.createFormBindingData(obj);
    console.log('updateForm formData', formId, JSON.stringify(formData));

    formProvider.updateForm(formId, formData).catch((error) => {
      console.log('updateForm formData updateForm, error:' + JSON.stringify(error));
    });
  });
}

/**
 * 刷新卡片
 * @param formId
 */
export async function refreshForm(formId: string) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('refreshForm thisFormInfo' + JSON.stringify(thisFormInfo))
  thisFormInfo.formDate = [new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate()],
  thisFormInfo.formPage = 0
  setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo));
  UpdateForm(formId);
}

/**
 * 刷新所有卡片，除了formId
 * @param formId
 */
export async function refreshAllForm(formId: string = null) {
  let formIds = await getAllStorage("thisFormInfo");
  for (let id of formIds)
    if (id !== formId)
      refreshForm(id)
}

/**
 * 改变卡片显示日期
 * @param formId
 */
export async function changeDate(formId: string, formDate: number[]) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('changeDate thisFormInfo' + JSON.stringify(thisFormInfo))
  thisFormInfo.formDate = formDate
  setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo));
  UpdateForm(formId);
}

/**
 * 改变卡片显示待办单
 * @param formId
 */
export async function changeFolder(formId: string, formFolder: number) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('changeFolder thisFormInfo' + JSON.stringify(thisFormInfo))
  thisFormInfo.formFolder = formFolder
  setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo));
  UpdateForm(formId);
}

/**
 * 改变卡片显示页码
 * @param formId
 * @param formPage 页码的变化幅度
 */
export async function changePage(formId: string, d_formPage: number) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('changePage thisFormInfo' + JSON.stringify(thisFormInfo))
  getFormObject(thisFormInfo.formName, thisFormInfo.formDimension, thisFormInfo.formDate, thisFormInfo.formFolder, thisFormInfo.formPage + d_formPage).then((obj:formData) => {
    console.log('changePage ', formId, JSON.stringify(obj));
    thisFormInfo.formPage = obj.pageNumber;
    // Called to return a FormBindingData object.
    let formData = formBindingData.createFormBindingData(obj);
    console.log('changePage formData', formId, JSON.stringify(formData));
    formProvider.updateForm(formId, formData).catch((error) => {
      console.log('changePage formData updateForm, error:' + JSON.stringify(error));
    });
    setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo));
  });
}

/**
 * 完成卡片上的某一事件
 * @param formId
 * @param eventId
 */
export async function clickEvent(formId: string, eventId: number, state: number) {
  if (state == 2) {
    SubCompTime(eventId);
  } else {
    AddCompTime(eventId);
  }
  UpdateForm(formId);
  refreshAllForm(formId);
}

/**
 * 切换月份
 * @param formId
 * @param d_Month
 */
export async function changeMonth(formId: string, d_Month: number) {
  let thisFormInfo: FormInfo = JSON.parse(await getStorage("thisFormInfo", formId));
  console.log('changeFolder thisFormInfo' + JSON.stringify(thisFormInfo))
  thisFormInfo.formDate = getNextNMonth(thisFormInfo.formDate, d_Month)
  setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo));
  UpdateForm(formId);
}