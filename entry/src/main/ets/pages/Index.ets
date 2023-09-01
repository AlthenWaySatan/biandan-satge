// import { ExportNewVersion_form } from '../../FormAbility/controller/formSyncController';
import { ExportNewVersion } from '../control/TerminalsSyncController';
import { publishNotification_test } from '../control/NotificationController';
import { ImplTable } from '../dao/controller/InitAndTable';
import { backupFile } from '../control/FileioController';
import device from '@system.device';
import featureAbility from '@ohos.ability.featureAbility'
import window from '@ohos.window';
import router from '@ohos.router'
import mediaquery from '@ohos.mediaquery'

import { lgBar, mdBar, smBar } from './element/Bar';
import { TodoPage } from './view/TodoPage';
import { CalendarPage } from './view/CalendarPage';
import { FourQuadrantPage } from './view/FourQuadrantPage';
import { SettingPage } from './view/SettingPage';
import { FolderAddPanel } from './view/FolderAddPanel'
import { EventAddPanel } from './view/EventAddPanel'

import { refreshResource, changeAllChoice } from '../control/EventsController';
import { get_barResource } from '../control/AccentController';

import BarResource from '../model/BarResourceContact';
import EventResource from '../model/EventsResourceContact';
import FolderResource from '../model/FolderResourceContact';

PersistentStorage.PersistProp('IsFirstIn_', 0)
PersistentStorage.PersistProp('AutoBackUpSwitch', false)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', false)

@Entry
@Component
struct Index {
  private implTable: ImplTable = new ImplTable()
  /**
   * 媒体监听器
   */
  /*-------------------------------------------------------------------------------------------------------------------*/
  smListener = mediaquery.matchMediaSync('(width < ' + 1500 + ')');
  mdListener = mediaquery.matchMediaSync('(width >= ' + 1500 + ') and (width <= ' + 2500 + ')');
  lgListener = mediaquery.matchMediaSync('(width > ' + 2500 + ')');
  darkmodeListener = mediaquery.matchMediaSync('screen and (dark-mode: true)');
  portraitFuncSm = null;
  portraitFuncMd = null;
  portraitFuncLg = null;
  portraitFuncDarkmode = null;
  @StorageLink('screenType') screenType: string = ''

  public onPortraitSm(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.screenType = 'sm'
      console.info('sm')
    }
  }

  public onPortraitMd(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.screenType = 'md'
      console.info('md')
    }
  }

  public onPortraitLg(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.screenType = 'lg'
      console.info('lg')
    }
  }

  // public onPortraitDarkMode(mediaQueryResult) {
  //   console.info('darkmode? ' + mediaQueryResult.matches)
  //   window.getTopWindow((err, data) => {
  //     var windowClass = data;
  //     if (mediaQueryResult.matches) {
  //       console.info('set darkmode dark');
  //       windowClass.setSystemBarProperties({
  //         statusBarColor: '#000000',
  //         isStatusBarLightIcon: true,
  //         navigationBarColor: '#000000',
  //         isNavigationBarLightIcon: true
  //       }, () => {
  //       });
  //     } else {
  //       console.info('set darkmode light');
  //       windowClass.setSystemBarProperties({
  //         statusBarColor: '#F1F2F3',
  //         isStatusBarLightIcon: false,
  //         navigationBarColor: '#F1F2F3',
  //         isNavigationBarLightIcon: false
  //       }, () => {
  //       });
  //     }
  //   });
  // }
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('settingNum') settingNum: number = 0

  /**
   * 页签栏函数，资源，样式
   */
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('selectPos') selectPos: number = 0;
  private barResource: BarResource[] = get_barResource()

  /**
   * 内容资源
   */
  /*-------------------------------------------------------------------------------------------------------------------*/

  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = [
    new FolderResource(0, $r('app.media.ic_folder'), '', '全部待办', 0),
    new FolderResource(-1, $r('app.media.ic_folder_filled'), '', '未分类', 0),
    new FolderResource(-2, $r('app.media.ic_collect'), '', '我的收藏', 0),
    new FolderResource(-3, $r('app.media.ic_important'), '', '重要待办', 0)
  ]
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []

  /**
   * 当前时间和分类
   */
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = null

  /**
   * 任务栏和键盘高度
   */
  @State statusBarHeight: number = 0
  @State screenDensity: number = 2

  /**
   * 完成比率
   */
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0

  /**
   * 展示资源
   */
  @StorageLink('eventsShowResource') eventsShowResource: EventResource[][] = [[], [], []]

  /**
   * 是否展示添加面板
   */
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false

  /*-------------------------------------------------------------------------------------------------------------------*/
  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false
  @StorageLink('showAddMore') showAddMore: boolean = false
  @State readyToShow: boolean = false

  private quitEdit() {
    this.isEdit = false
    changeAllChoice(false)
  }

  /*-------------------------------------------------------------------------------------------------------------------*/

  @StorageLink('IsFirstIn_') IsFirstIn: number = 0;

  aboutToAppear() {
    var that = this;
    device.getInfo({
      success: function (data) {
        console.info("Device information obtained successfully. Device screenDensity: %{private}d", data.screenDensity);
        that.screenDensity = data.screenDensity;
      },
      fail: function (code) {
        console.info("Failed to obtain device information. Error code: %{private}d", code);
      },
    });
    this.smListener = mediaquery.matchMediaSync('(width <= ' + 672 * that.screenDensity + ')');
    this.mdListener = mediaquery.matchMediaSync('(width > ' + 672 * that.screenDensity + ') and (width <= ' + 1250 * that.screenDensity + ')');
    this.lgListener = mediaquery.matchMediaSync('(width > ' + 1250 * that.screenDensity + ')');
    this.darkmodeListener = mediaquery.matchMediaSync('screen and (dark-mode: true)');
    this.portraitFuncSm = this.onPortraitSm.bind(this)
    this.smListener.on('change', this.portraitFuncSm)
    this.portraitFuncMd = this.onPortraitMd.bind(this)
    this.mdListener.on('change', this.portraitFuncMd)
    this.portraitFuncLg = this.onPortraitLg.bind(this)
    this.lgListener.on('change', this.portraitFuncLg)
    // this.portraitFuncDarkmode = this.onPortraitDarkMode.bind(this)
    // this.darkmodeListener.on('change', this.portraitFuncDarkmode)

    this.barResource = get_barResource()

    refreshResource();

    setTimeout(() => {
      // let IsFirstIn = AppStorage.Get<number>('IsFirstIn_')
      if (this.IsFirstIn < 1) {
        this.implTable.initTable()
        //        publishNotification_test()
        // router.replace({
        //   url: 'pages/guide'
        // })
        // 'IsFirstIn_'
        this.IsFirstIn += 1;
      }
      // else {
      this.readyToShow = true
      // }
    }, 200)
  }

  @StorageLink('AutoBackUpSwitch') AutoBackUpSwitch: boolean = false
  @StorageLink('AutoTerminalsSyncSwitch') AutoTerminalsSyncSwitch: boolean = false

  async onPageHide() {
    if (this.AutoBackUpSwitch)
      await backupFile()
    if (this.AutoTerminalsSyncSwitch)
      await ExportNewVersion()
    // await ExportNewVersion_form()
  }

  build() {
    Stack() {
      if (this.readyToShow) {
        Flex({
          direction: (this.screenType == 'lg' ? FlexDirection.Row : FlexDirection.Column),
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          /**
           * lg页签栏
           */
          if (this.screenType == 'lg') {
            lgBar({ barResource: this.barResource })
          }

          if (this.screenType != '') {
            Column() {
              if (this.selectPos == 0)
                TodoPage({
                  statusBarHeightVp: this.statusBarHeight / this.screenDensity
                })

              if (this.selectPos == 1)
                CalendarPage({
                  statusBarHeightVp: this.statusBarHeight / this.screenDensity
                })

              if (this.selectPos == 2)
                FourQuadrantPage({
                  statusBarHeightVp: this.statusBarHeight / this.screenDensity
                })

              if (this.selectPos == 3)
                SettingPage({
                  statusBarHeightVp: this.statusBarHeight / this.screenDensity
                })
            }
          }

          /**
           * sm和md页签栏
           */
          if (this.screenType == 'sm' && !this.isEdit) {
            smBar({ barResource: this.barResource })
          }
          if (this.screenType == 'md' && !this.isEdit) {
            mdBar({ barResource: this.barResource })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.background'))
      }

      if (this.showEventAddPanel) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(() => {
            this.showEventAddPanel = false
          })
        Column() {
          EventAddPanel()
        }.padding({ top: this.statusBarHeight / this.screenDensity })
      }


      if (this.showFolderAddPanel) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(() => {
            this.showFolderAddPanel = false
          })
        Column() {
          FolderAddPanel()
        }.padding({ top: this.statusBarHeight / this.screenDensity })
      }

    }
    .width('100%')
    .height('100%')
  }

  onBackPress() {
    //    await featureAbility.startAbility({
    //      want: {
    //        bundleName: BUNDLE,
    //        abilityName: ABILITY,
    //        deviceId: this.state.distributedDevice,
    //        parameters: {
    //          isFA: 'EXIT'
    //        }
    //      }
    //    })
    //    RdbModel.offDataChange()

    //    app.terminate();
    if (this.showAddMore) {
      this.showAddMore = false
      return true
    }
    if (this.showFolderAddPanel) {
      this.showFolderAddPanel = false
      return true
    }
    if (this.showEventAddPanel) {
      this.showEventAddPanel = false
      return true
    }
    if (this.isEdit) {
      this.quitEdit()
      return true
    }
    else {
      return false
    }
  }
}