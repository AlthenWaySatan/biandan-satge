import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { refreshAllForm } from '../control/FormController'
import Want from '@ohos.app.ability.Want';
import { getResource } from '../control/EventsController';
import common from '@ohos.app.ability.common';

function getFormFolder() {
  let showDate = AppStorage.Get<number[]>("showDate")
  let folderId = AppStorage.Get<number>("folderId")
  // let context: Context = getContext(this) as common.Context
  // getResource(showDate[0], showDate[1], showDate[2], folderId, context);
}

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    AppStorage.SetOrCreate("showDate", [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())])
    AppStorage.SetOrCreate("folderId", 0)

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    if (want.parameters.params !== undefined) {
      let params = JSON.parse(want.parameters.params);
      console.info("onCreate router targetPage:" + JSON.stringify(params));
      if (params.message == 'addEvent') {
        AppStorage.SetOrCreate("showEventAddPanel", true)
        if (params.year != null)
          AppStorage.SetOrCreate("showDate", [params.year, params.month, params.day])
        getFormFolder()
      }
      else if (params.message == 'todoList' || params.message == 'recommend') {
        getFormFolder()
      } else if (params.message == 'calendar') {
        AppStorage.SetOrCreate("showDate", [params.year, params.month, params.day])
        getFormFolder()
        AppStorage.SetOrCreate("selectPos", 1)
      } else if (params.message == 'fourQuadrants') {
        getFormFolder()
        AppStorage.SetOrCreate("selectPos", 2)
      }
    }

  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    refreshAllForm(this.context);
  }
}
