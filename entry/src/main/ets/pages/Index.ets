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
import common from '@ohos.app.ability.common';
import { SiderFolder } from './element/SiderFolder';
import { EditTitleOne, TitleOne, TitleTwo } from './element/Title';
import { AddEventButton } from './element/AddEventButton';
import { ToolBar } from './element/ToolBar';

PersistentStorage.PersistProp('IsFirstIn_', 0)
PersistentStorage.PersistProp('AutoBackUpSwitch', 0)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', 0)

@Entry
@Component
struct Index {
  // private implTable: ImplTable = new ImplTable()
  /**
   * 媒体监听器
   */
  /*-------------------------------------------------------------------------------------------------------------------*/
  smListener = mediaquery.matchMediaSync('(width < ' + 520 + 'vp)');
  mdListener = mediaquery.matchMediaSync('(width >= ' + 520 + 'vp) and (width <= ' + 840 + 'vp)');
  lgListener = mediaquery.matchMediaSync('(width > ' + 840 + 'vp)');
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

  public onPortraitDarkMode(mediaQueryResult) {
    console.info('darkmode? ' + mediaQueryResult.matches)
    let context: Context = getContext(this) as common.Context
    window.getLastWindow(context, (err, data) => {
      var windowClass = data;
      if (mediaQueryResult.matches) {
        console.info('set darkmode dark');
        windowClass.setWindowSystemBarProperties({
          statusBarColor: '#000000',
          isStatusBarLightIcon: true,
          navigationBarColor: '#000000',
          isNavigationBarLightIcon: true
        }, () => {
        });
      } else {
        console.info('set darkmode light');
        windowClass.setWindowSystemBarProperties({
          statusBarColor: '#F1F2F3',
          isStatusBarLightIcon: false,
          navigationBarColor: '#F1F2F3',
          isNavigationBarLightIcon: false
        }, () => {
        });
      }
    });
  }
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('settingNum') settingNum: number = 0

  /**
   * 页签栏函数，资源，样式
   */
  /*-------------------------------------------------------------------------------------------------------------------*/
  @StorageLink('selectPos') selectPos: number = 0;
  @StorageLink('barResource') barResource: BarResource[] = get_barResource()

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
  @StorageLink('showDate') showDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  @StorageLink('folderId') folderId: number = 0

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
  @StorageLink('eventsShowResource') eventsShowResource: string = JSON.stringify([[], [], []])

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

  //状态栏高度
  private statusBarHeightVp: number
  //今日日期
  private todayDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]

  /**
   * 获取日期
   */
  private getShowDate() {
    if (this.todayDate[0] == this.showDate[0]) {
      if (this.todayDate[1] == this.showDate[1] && this.todayDate[2] == this.showDate[2])
        return '今天';
      else
        return this.showDate[1] + '月' + this.showDate[2] + '日';
    }
    else
      return this.showDate[0] + '年' + this.showDate[1] + '月' + this.showDate[2] + '日';
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  /**
   * 获取当前待办单标题
   */
  private getFolderTitle() {
    if (this.folderId <= 0)
      return this.systemFolderResource[-this.folderId].title;
    else {
      let id = this.userFolderResource.findIndex((item) => item.id == this.folderId)
      return this.userFolderResource[id].title;
    }
  }

  @StorageLink('IsFirstIn_') IsFirstIn: number = 0;
  @State showDateToSon: string = '今天'

  private RefreshShowDate() {
    this.showDateToSon = this.getShowDate();
  }

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
    this.RefreshShowDate();
    this.portraitFuncDarkmode = this.onPortraitDarkMode.bind(this)
    this.darkmodeListener.on('change', this.portraitFuncDarkmode)

    this.barResource = get_barResource()

    let context: Context = getContext(this) as common.Context
    refreshResource(context);

    setTimeout(() => {
      // let IsFirstIn = AppStorage.Get<number>('IsFirstIn_')
      if (this.IsFirstIn < 1) {
        let implTable: ImplTable = new ImplTable()
        implTable.initTable(context)
        this.IsFirstIn += 1;
        //        publishNotification_test()
        router.replace({
          url: 'pages/guide'
        })
        // 'IsFirstIn_'
      }
      // else {
      this.readyToShow = true
      // }
    }, 200)
  }

  @StorageLink('AutoBackUpSwitch') AutoBackUpSwitch: number = 0
  @StorageLink('AutoTerminalsSyncSwitch') AutoTerminalsSyncSwitch: number = 0

  async onPageHide() {
    let context: Context = getContext(this) as common.Context
    if (this.AutoBackUpSwitch != 0)
      await backupFile(context)
    if (this.AutoTerminalsSyncSwitch != 0)
      await ExportNewVersion(context)
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
            lgBar()
          }

          if (this.screenType != '') {
            Column() {
              Column() {
                Row() {
                  if (this.screenType == 'lg') {
                    SiderFolder({
                      statusBarHeightVp: this.statusBarHeight / this.screenDensity,
                    })
                  }
                  Column() {
                    //标题
                    if (this.isEdit) {
                      EditTitleOne({
                        columnNum: this.screenType == 'sm' ? 4 : 8,
                        offsetNum: this.screenType == 'sm' ? 0 : 1
                      })
                    } else {
                      if (this.screenType == 'sm') {
                        TitleTwo({
                          mainTitle: $showDateToSon,
                          subTitle: this.getFolderTitle(),
                          columnNum: 4,
                          offsetNum: 0
                        })
                      } else if (this.screenType == 'md') {
                        TitleTwo({
                          mainTitle: $showDateToSon,
                          subTitle: this.getFolderTitle(),
                          columnNum: 8,
                          offsetNum: 1
                        })
                      } else {
                        TitleOne({
                          showDate: $showDate,
                          mainTitle: $showDateToSon,
                          columnNum: 8,
                          offsetNum: 1
                        })
                      }
                    }

                    //数据区
                    Column() {
                      //列表展示区
                      GridContainer({ columns: this.screenType == 'sm' ? 4 : 8, gutter: 12, margin: 12 }) {
                        Column() {
                          Stack() {
                            Column() {
                              //todoList
                              TodoPage()

                              //Calendar
                              CalendarPage()

                              //FourQuadrant
                              FourQuadrantPage()
                            }
                            .width('100%')
                            .height('100%')

                            AddEventButton()
                          }
                          .alignContent(Alignment.BottomEnd)

                        }
                        .useSizeType({
                          xs: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
                          sm: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
                          md: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
                          lg: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
                        })
                      }
                      .layoutWeight(1)
                    }
                    .layoutWeight(1)


                    ToolBar({
                      isHidden: $isEdit,
                    })
                  }
                  .width((this.screenType == 'lg' ? '60%' : '100%'))
                  .margin({ top: this.statusBarHeight / this.screenDensity })
                }
              }
              .width('100%')
              .height('100%')
              .visibility(this.selectPos != 3 ? Visibility.Visible : Visibility.None)
              .opacity(this.selectPos != 3 ? 1 : 0)
              .animation({
                delay: 0,
                duration: 200, // 动画时长
                curve: Curve.EaseInOut, // 动画曲线
              })

              Column() {
                SettingPage({
                  statusBarHeightVp: this.statusBarHeight / this.screenDensity
                })
              }
              .width('100%')
              .height('100%')
              .visibility(this.selectPos == 3 ? Visibility.Visible : Visibility.None)
              .opacity(this.selectPos == 3 ? 1 : 0)
              .animation({
                delay: 0,
                duration: 200, // 动画时长
                curve: Curve.EaseInOut, // 动画曲线
              })
            }
          }

          /**
           * sm和md页签栏
           */
          if (this.screenType == 'sm' && !this.isEdit) {
            smBar()
          }
          if (this.screenType == 'md' && !this.isEdit) {
            mdBar()
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.background'))
      }

      Column() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(() => {
            this.showEventAddPanel = false
          })
          .opacity(this.showEventAddPanel ? 1 : 0)
          .animation({
            delay: 0,
            duration: 200, // 动画时长
            curve: Curve.EaseInOut, // 动画曲线
          })
      }
      .width('100%')
      .height('100%')
      .visibility(this.showEventAddPanel ? Visibility.Visible : Visibility.None)

      if (this.showEventAddPanel) {
        Column() {
          EventAddPanel()
        }.padding({ top: this.statusBarHeight / this.screenDensity })
      }


      Column() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(() => {
            this.showFolderAddPanel = false
          })
          .opacity(this.showFolderAddPanel ? 1 : 0)
          .animation({
            delay: 0,
            duration: 200, // 动画时长
            curve: Curve.EaseInOut, // 动画曲线
          })
      }
      .width('100%')
      .height('100%')
      .visibility(this.showFolderAddPanel ? Visibility.Visible : Visibility.None)

      if (this.showFolderAddPanel) {
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
      // let context: Context = getContext(this) as common.Context
      // refreshAllForm(context);
      return false
    }
  }
}