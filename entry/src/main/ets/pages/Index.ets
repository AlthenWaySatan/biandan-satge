// import { ExportNewVersion_form } from '../../FormAbility/controller/formSyncController';
import { ExportNewVersion } from '../control/TerminalsSyncController';
import { ImplTable } from '../dao/controller/InitAndTable';
import { backupFile } from '../control/FileioController';
import device from '@ohos.deviceInfo';
import router from '@ohos.router'
import mediaquery from '@ohos.mediaquery'

import { lgBar, mdBar, smBar } from './element/Bar';
import { TodoPage } from './view/TodoPage';
import { CalendarPage } from './view/CalendarPage';
import { FourQuadrantPage } from './view/FourQuadrantPage';
import { SettingPage } from './view/SettingPage';
import { FolderAddPanel } from './view/FolderAddPanel'
import { EventAddPanel } from './view/EventAddPanel'

import { refreshResource, changeAllChoice, getResource } from '../control/EventsController';
import { get_barResource } from '../control/AccentController';

import BarResource from '../model/BarResourceContact';
import EventResource from '../model/EventsResourceContact';
import FolderResource from '../model/FolderResourceContact';

PersistentStorage.PersistProp('IsFirstIn', true)
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
  @StorageLink('screenType') screenType: string = 'sm'

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
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('settingNum') settingNum: number = 0

  /**
   * 页签栏函数，资源，样式
   */
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('selectPos') selectPos: number = 0;
  private barResource: BarResource[] = [
    new BarResource($r('app.media.ic_todo_on'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
    new BarResource($r('app.media.ic_calendar_on'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
    new BarResource($r('app.media.ic_4quadrant_on'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
    new BarResource($r('app.media.ic_setting_on'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
  ]

  /**
   * 内容资源
   */
  /*-------------------------------------------------------------------------------------------------------------------*/

  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = [
    new FolderResource(0, $r('app.media.ic_folder'), '', $r('app.string.AllTodo'), 0),
    new FolderResource(-1, $r('app.media.ic_folder_filled'), '', $r('app.string.No_folder'), 0),
    new FolderResource(-2, $r('app.media.ic_collect'), '', $r('app.string.My_favorite'), 0),
    new FolderResource(-3, $r('app.media.ic_important'), '', $r('app.string.Important_things'), 0)
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
  @StorageLink('eventsShowResource') eventsShowResource: EventResource[][] = [[]]

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

  aboutToAppear() {
    this.smListener = mediaquery.matchMediaSync('(width <= ' + 672 * 2 + ')');
    this.mdListener = mediaquery.matchMediaSync('(width > ' + 672 * 2 + ') and (width <= ' + 1250 * 2 + ')');
    this.lgListener = mediaquery.matchMediaSync('(width > ' + 1250 * 2 + ')');
    this.darkmodeListener = mediaquery.matchMediaSync('screen and (dark-mode: true)');
    this.portraitFuncSm = this.onPortraitSm.bind(this)
    this.smListener.on('change', this.portraitFuncSm)
    this.portraitFuncMd = this.onPortraitMd.bind(this)
    this.mdListener.on('change', this.portraitFuncMd)
    this.portraitFuncLg = this.onPortraitLg.bind(this)
    this.lgListener.on('change', this.portraitFuncLg)

    this.barResource = get_barResource()

    let showDate = AppStorage.Get<number[]>("showDate")
    let folderId = AppStorage.Get<number>("folderId")
    getResource(showDate[0], showDate[1], showDate[2], folderId);

    refreshResource();

    setTimeout(() => {
      let IsFirstIn = AppStorage.Get<boolean>('IsFirstIn')
      if (IsFirstIn) {
        this.implTable.initTable()
        // router.replaceUrl({
        //   url: 'pages/guide'
        // })
      } else {
        this.readyToShow = true
      }
      this.readyToShow = true
    }, 200)
  }
//
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
    // Row() {
    //   Column() {
    //     Text('2222')
    //       .fontSize(50)
    //       .fontWeight(FontWeight.Bold)
    //   }
    //   .width('100%')
    // }
    // .height('100%')
    Stack() {
        // Row() {
        //   Column() {
        //     Text('2222' + this.readyToShow)
        //       .fontSize(50)
        //       .fontWeight(FontWeight.Bold)
        //   }
        //   .width('100%')
        // }
        // .height('100%')
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
      // this.quitEdit()
      return true
    }
    else {
      return false
    }
  }
}