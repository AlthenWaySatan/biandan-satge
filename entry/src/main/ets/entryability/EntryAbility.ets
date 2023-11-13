import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { setBackgroundTask } from '../control/BackgroundTaskController';
import { ExportNewVersion } from '../control/TerminalsSyncController';
import { backupFile } from '../control/FileioController';

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
    let windowClass = null;
    windowStage.getMainWindow((err, data) => {
      if (err.code) {
        console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass = data;
      console.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

      // 2.实现沉浸式效果。方式一：设置导航栏、状态栏不显示。
      let names = ["status", "navigation"]; // 需全部显示，该参数设置为["status", "navigation"]；不设置，则默认不显示。
      windowClass.setWindowSystemBarEnable(names, (err) => {
        if (err.code) {
          console.error('Failed to set the system bar to be visible. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in setting the system bar to be visible.');
      });
      // 2.实现沉浸式效果。方式二：设置窗口为全屏布局，配合设置导航栏、状态栏的透明度、背景/文字颜色及高亮图标等属性，与主窗口显示保持协调一致。
      // let isLayoutFullScreen = true;
      // windowClass.setWindowLayoutFullScreen(isLayoutFullScreen, (err) => {
      //   if (err.code) {
      //     console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      //     return;
      //   }
      //   console.info('Succeeded in setting the window layout to full-screen mode.');
      // });
      // let sysBarProps = {
      //   // statusBarColor: '#ff00ff',
      //   // navigationBarColor: '#00ff00',
      //   // // 以下两个属性从API Version 8开始支持
      //   // statusBarContentColor: '#ffffff',
      //   // navigationBarContentColor: '#ffffff'
      //   statusBarColor: $r('app.color.background'),
      //   isStatusBarLightIcon: true,
      //   navigationBarColor: $r('app.color.background'),
      //   isNavigationBarLightIcon: true
      // };
      // windowClass.setWindowSystemBarProperties(sysBarProps, (err) => {
      //   if (err.code) {
      //     console.error('Failed to set the system bar properties. Cause: ' + JSON.stringify(err));
      //     return;
      //   }
      //   console.info('Succeeded in setting the system bar properties.');
      // });
    })
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
    // refreshAllForm(this.context);
    // let reason: string = "";
    // // let reason: string = "刷新卡片";
    // let tasks: Function[] = [];
    // // tasks.push(refreshAllForm);
    // if ( AppStorage.Get<number>('AutoBackUpSwitch') != 0) {
    //   tasks.push(backupFile);
    //   reason += "，自动备份";
    // }
    // if (AppStorage.Get<number>('AutoTerminalsSyncSwitch') != 0) {
    //   tasks.push(ExportNewVersion);
    //   reason += "，同步新版本";
    // }
    // setBackgroundTask(reason, tasks, this.context);
  }
}
