import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';
import { changeDate, changeMonth, changePage, clickEvent, refreshForm, UpdateForm } from '../control/FormController'
import { setStorage, getStorage, hasStorage, deleteStorage } from '../control/StorageController'
import common from '@ohos.app.ability.common';



export interface FormInfo {
  formId: string,
  formName: string,
  formDimension: number,
  formDate: number[],
  formFolder: number,
  formPage: number
}

export default class EntryFormAbility extends FormExtensionAbility {

  onAddForm(want) {
    // Called to return a FormBindingData object.
    console.log('[EntryFormAbility] onAddForm');
    // 在入参want中可以取出卡片的唯一标识：formId
    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY];
    let formName: string = want.parameters[formInfo.FormParam.NAME_KEY];
    let formDimension: number = want.parameters[formInfo.FormParam.DIMENSION_KEY];
    let thisFormInfo:FormInfo = {
      formId: formId,
      formName: formName,
      formDimension: formDimension,
      formDate: [new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate()],
      formFolder: 0,
      formPage: 0
    };
    console.log('[EntryFormAbility] onAddForm thisFormInfo' + JSON.stringify(thisFormInfo))
    setStorage("thisFormInfo", formId, JSON.stringify(thisFormInfo), this.context).then(() => {
      UpdateForm(formId, this.context);
    });
    return null;
  }

  onCastToNormalForm(formId) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId) {
    refreshForm(formId, this.context);
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId, message) {
    console.info(`FormAbility onEvent, formId = ${formId}, message: ${JSON.stringify(message)}`);
    let obj = JSON.parse(message);
    switch (obj.type) {
      case "refresh":
        refreshForm(formId, this.context);
        break;
      case "clickEvent":
        clickEvent(formId, obj.eventId, obj.state, this.context)
        break;
      case "lastPage":
        changePage(formId, -1, this.context);
        break;
      case "nextPage":
        changePage(formId, 1, this.context);
        break;
      case "changePage":
        changePage(formId, 1, this.context);
        break;
      case "changeDate":
        changeDate(formId, obj.date, this.context);
        break;
      case "lastMonth":
        changeMonth(formId, -1, this.context);
        break;
      case "nextMonth":
        changeMonth(formId, 1, this.context);
        break;
    }
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId) {
    deleteStorage("thisFormInfo", formId, this.context);
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};