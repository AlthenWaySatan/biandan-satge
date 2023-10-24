import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import { get_accent } from '../control/AccentController';
import { getStartDate, getNextNDay, getNextNMonth} from '../control/CalendarControl';
import formProvider from '@ohos.app.form.formProvider';

export default class EntryFormAbility extends FormExtensionAbility {

  // @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0

  private turnIntoFormEvent(): object {
    return {
      'Title': "Text Text",
      'Time': "Time Time",
      'isWarning': true,
      'isHighlight': true,
      'stateResource': $r('app.media.ic_todo_wait_black'),
      'isClock': true,
      'isPath': false,
      'isDone': false,
      'State': 0,
      'eventId': 0
    }
  }

  private getWeek(date: number[]) {
    let ret = [];
    for (let i = 0; i < 7; i++) {
      let temp = getNextNDay(date, i);
      ret.push({
        date: temp[2],
        month: temp[1],
        year: temp[0],
        haveEvent: false
      })
    }
    return ret;
  }

  private getFormDate(date: number, month: number, year: number) {
    let startDate = getStartDate([year, month, date]);
    let ret = [
      this.getWeek(startDate),
      this.getWeek(getNextNDay(startDate, 7)),
      this.getWeek(getNextNDay(startDate, 14)),
      this.getWeek(getNextNDay(startDate, 21)),
      this.getWeek(getNextNDay(startDate, 28))
    ];
    if (getNextNDay(startDate, 35)[1] == month)
      ret.push(this.getWeek(getNextNDay(startDate, 35)));
    return ret;
  }

  private getFormObject(type: string, dimension: number) : object {

    let day = new Date().getDate();
    let month = new Date().getMonth() + 1;
    let year = new Date().getFullYear();

    let eventLength = 5;

    let formDate = month.toString() + "月" + day.toString() + "日";
    let formFolder = "全部代办";
    let formAccentColor = get_accent()
    let formDoneNum = 3;
    let formAllNum = 5;
    let formDoneRate = formAllNum == 0 ? 0 : (formDoneNum / formAllNum);
    let formDoneStr = (formDoneNum).toString() + "/" + (formAllNum).toString();

    interface formData {
      [key: string]: any;
    }

    let ret: formData = {
      Date: formDate,
      Folder: formFolder,
      accentColor: formAccentColor,
      doneNum: formDoneNum,
      allNum: formAllNum,
      doneRate: formDoneRate,
      doneStr: formDoneStr,
      pageNumber: 0
    }
    switch (type) {
      case 'recommend': {
        ret['event'] = this.turnIntoFormEvent()
        break;
      }
      case 'todolist': {
        if (dimension == 4)
          eventLength = 10;
        let eventList = [];
        for (let i = 0; i < eventLength; i++)
          eventList.push(this.turnIntoFormEvent());
        ret['events'] = eventList;
        ret['widthLength'] = (dimension <= 2 ? 2 : 4);
        ret['listLength'] = eventLength;
        break;
      }
      case 'fourQuadrants': {
        let eventList = [[], [], [], []];
        for (let i = 0; i < eventLength; i++)
          eventList[0].push(this.turnIntoFormEvent());
        for (let i = 0; i < eventLength; i++)
          eventList[1].push(this.turnIntoFormEvent());
        for (let i = 0; i < eventLength; i++)
          eventList[2].push(this.turnIntoFormEvent());
        for (let i = 0; i < eventLength; i++)
          eventList[3].push(this.turnIntoFormEvent());
        ret['events'] = eventList;
        break;
      }
      case 'calendar': {
        ret['thisYear'] = year;
        ret['thisMonth'] = month;
        ret['thisDate'] = day;
        let eventList = [];
        for (let i = 0; i < eventLength; i++)
          eventList.push(this.turnIntoFormEvent());
        ret['Month'] = year.toString() + "年" + month.toString() + "月";
        ret['events'] = eventList;
        ret['dates'] = this.getFormDate(day, month, year);
        let FirstDayOfWeek = AppStorage.Get<number>('FirstDayOfWeek')
        ret['dateHeader'] = (FirstDayOfWeek == 1) ? ['日', '一', '二', '三', '四', '五', '六'] : ['一', '二', '三', '四', '五', '六', '日'];
        break;
      }
    }

    return ret;
  }

  onAddForm(want) {
    // Called to return a FormBindingData object.
    console.log('[EntryFormAbility] onAddForm');
    // 在入参want中可以取出卡片的唯一标识：formId
    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY];
    let formName: string = want.parameters[formInfo.FormParam.NAME_KEY];
    let formDimension: number = want.parameters[formInfo.FormParam.DIMENSION_KEY];
    let thisFormInfo = {
      formId: formId,
      formName: formName,
      formDimension: formDimension
    };
    let obj = this.getFormObject(thisFormInfo.formName, thisFormInfo.formDimension);
    console.log('[EntryFormAbility] onAddForm ' + JSON.stringify(thisFormInfo))
    console.log('[EntryFormAbility] onAddForm ', thisFormInfo.formId, JSON.stringify(obj));
    // Called to return a FormBindingData object.
    let formData = formBindingData.createFormBindingData(obj);
    console.log('[EntryFormAbility] onAddForm formData', thisFormInfo.formId, JSON.stringify(formData));
    return formData;
  }

  onCastToNormalForm(formId) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId) {
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId, message) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};