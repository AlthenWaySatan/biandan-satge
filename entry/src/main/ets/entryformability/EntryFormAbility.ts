import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';

export default class EntryFormAbility extends FormExtensionAbility {
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
    console.log('[EntryFormAbility] onAddForm ' + JSON.stringify(thisFormInfo))
    let obj = {};
    // Called to return a FormBindingData object.
    let formData = formBindingData.createFormBindingData(obj);
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