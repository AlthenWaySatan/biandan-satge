import router from '@ohos.router'
import common from '@ohos.app.ability.common';
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';
import { setStorage } from '../../control/StorageController';
//import {client_id, redirect_uri} from '../../model/HMSContact';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)
PersistentStorage.PersistProp('DefaultTimeFormat', 0)
PersistentStorage.PersistProp('AccentColor0', 0)
PersistentStorage.PersistProp('AccentColor1', '')
PersistentStorage.PersistProp('DefaultClockTime0', 10)
PersistentStorage.PersistProp('DefaultClockTime1', 30)
PersistentStorage.PersistProp('DefaultUrgentTime0', 22)
PersistentStorage.PersistProp('DefaultUrgentTime1', 0)
PersistentStorage.PersistProp('DefineCycleLength', 90)
PersistentStorage.PersistProp('IsCloudBackup', false)
PersistentStorage.PersistProp('IsCalendarSync', false)


@Component
export struct SettingTable {
  @StorageLink('settingNum') settingNum: number = 0
  @StorageLink('settingTitle') settingTitle: string | Resource = '返回'
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('AccentColor0') AccentColor0: number = 0
  @StorageLink('AccentColor1') AccentColo1r: string = ''
  @StorageLink('DefaultClockTime0') DefaultClockTime0: number = 10
  @StorageLink('DefaultClockTime1') DefaultClockTime1: number = 30
  @StorageLink('DefaultUrgentTime0') DefaultUrgentTime0: number = 22
  @StorageLink('DefaultUrgentTime1') DefaultUrgentTime1: number = 0
  @StorageLink('DefineCycleLength') DefineCycleLength: number = 90 //默认重复时间长度
  @StorageLink('accentColorArray') accentColorArray: [string, string][] = [
    ['便单黄', ''],
    ['宇宙蓝', '_blue'],
    ['燃力红', '_red'],
    ['宝石绿', '_green'],
    ['魔法紫', '_purple'],
    ['樱花粉', '_pink']
  ]
  @StorageLink('IsCloudBackup') IsCloudBackup: boolean = false
  @StorageLink('IsCalendarSync') IsCalendarSync: boolean = false

  //屏幕类型
  @StorageLink('screenType') @Watch("onChanged") screenType: string = ''
  @StorageLink('selectPos') selectPos: number = 3;
  private statusBarHeightVp: number
  private versionName: string

  //  private logWithHMS(value: boolean){
  //    let url:string = 'https://oauth-login.cloud.huawei.com/oauth2/v3/authorize?' +
  //    'response_type=code&access_type=offline' +
  //    '&state=state_parameter_passthrough_value' +
  //    '&client_id=' + client_id +
  //    '&redirect_uri=' + redirect_uri +
  //    '&scope=openid+profile'
  //  }

  onChanged() {
    if (this.screenType == 'md' && this.settingNum != 0 && this.selectPos == 3 && this.settingNum <= 10)
      this.intoNextPage()
  }

  aboutToDisappear() {
    this.settingNum = 0
    this.settingTitle = '返回'
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .margin({ bottom: 12 })
    .borderRadius(16)
  }

  private getTimeInfo(showTime: number[], timeFormat24: boolean): string {
    if (timeFormat24) {
      return (showTime[0] < 10 ? '0' : '') + showTime[0] + ':' + (showTime[1] < 10 ? '0' : '') + showTime[1]
    } else {
      if (showTime[0] < 12)
        return '上午' + (showTime[0] < 10 ? '0' : '') + showTime[0] + ':' + (showTime[1] < 10 ? '0' : '') + showTime[1]
      else if (showTime[0] == 12)
        return '下午' + showTime[0] + ':' + (showTime[1] < 10 ? '0' : '') + showTime[1]
      else
        return '下午' + ((showTime[0] - 12) < 10 ? '0' : '') + (showTime[0] - 12) + ':' + (showTime[1] < 10 ? '0' : '') + showTime[1]
    }
  }

  private intoNextPage() {
    if (this.screenType != 'lg') {
      router.push({
        url: 'pages/setting',
        params: {
          statusBarHeightVp: this.statusBarHeightVp,
        },
      });
    }
  }

  @Builder settingItem($$:{settingId: number, icon: Resource, title: string | Resource, showDivider: boolean}) {
    Stack() {
      if ($$.settingId == this.settingNum) {
        Column() {
          Column()
            .backgroundColor(get_translucentSaturation_accent())
            .height('100%')
            .width('100%')
            .borderRadius(16)
        }
        .height('100%')
        .width('100%')
        .padding(3)
      }

      Column() {
        Row() {
          Image($$.icon)
            .height(24)
            .width(24)
          Text($$.title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
        }
        .height(56)

        if ($$.showDivider) {
          Column() {
            Divider().width('100%').color($r('app.color.divider'))
          }.padding({ left: 40 })
        }
      }
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .height(56)
    .width('100%')
  }

  @Builder settingSubTitle($$:{text: string}) {
    Row() {
      Text($$.text)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_level2'))
        .fontSize(14)
      Image($r('app.media.ic_arrow_right'))
        .width(12)
        .height(24)
        .margin({ left: 4 })
    }
    .padding({ right: 12 })
    .justifyContent(FlexAlign.End)
  }

  @Builder selectMenu($$:{thisResource: [string | Resource, number][], outPut: (value: number) => number}) {
    Column() {
      Column() {
        ForEach($$.thisResource, (item: [string | Resource, number], index: number) => {
          Column() {
            Column() {
              Text(item[0])
                .fontColor(item[1] == $$.outPut(-1) ? get_accent() : $r('app.color.text_level1'))
                .fontSize(14)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ bottom: 12, top: 12 })
            .onTouch(() => {
              $$.outPut(item[1])
              console.info($$.outPut(-1).toString())
            })

            if (index != $$.thisResource.length - 1)
              Divider().color($r('app.color.divider'))
          }
          .width('100%')
        })
      }
      .padding({ left: 12, right: 12 })
    }
    .width(112)
    .justifyContent(FlexAlign.Start)
  }

  @Builder settingSelect($$:{thisResource: [string | Resource, number][], outPut: (value: number) => number}) {
    Row() {
      Text($$.thisResource[$$.outPut(-1)][0])
        .fontColor($r('app.color.text_level1'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Image($r('app.media.ic_spinner_level1'))
        .width(24)
        .height(24)
    }
    .bindMenu(this.selectMenu({thisResource: $$.thisResource, outPut: $$.outPut}))
    .padding({ right: 12 })
    .justifyContent(FlexAlign.End)
  }

  @Builder settingSwitch(value: boolean, outPut: (value: boolean) => void) {
    Row() {
      Toggle({ type: ToggleType.Switch, isOn: value })
        .height(24)
        .selectedColor(get_accent())
        .onChange((isOn: boolean) => {
          outPut(isOn ? true : false)
        })
    }
    .padding({ right: 6 })
    .justifyContent(FlexAlign.End)
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          //          Stack({ alignContent: Alignment.End }) {
          //            this.settingItem(1, $r('app.media.ic_setting_cloudBackup'), '华为云备份')
          //            this.settingSwitch(this.IsCloudBackup, (value: boolean) => {
          //              this.IsCloudBackup = value
          //              this.logWithHMS(value)
          //            })
          //          }.height(56).width('100%')

          // Column() {
          //   if (this.IsCloudBackup)
          //   Stack({ alignContent: Alignment.End }) {
          //     this.settingItem(2, $r('app.media.ic_setting_cloudResume'), '从云备份恢复')
          //     this.settingSubTitle()
          //   }.height(56).width('100%')
          // }.height(this.IsCloudBackup ? 56 : 0).width('100%')
          // .animation({
          //   duration: 200, // 动画时长
          //   curve: Curve.EaseOut, // 动画曲线
          // })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 3, icon: $r('app.media.ic_setting_storage'), title: '本地备份', showDivider: true})
            this.settingSubTitle({text: ' '})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 3
            this.settingTitle = '本地备份'
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 4, icon: $r('app.media.ic_setting_synchronous'), title: '多端同步', showDivider: false})
            this.settingSubTitle({text: ''})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 4
            this.settingTitle = '多端同步'
            this.intoNextPage()
          })

          //          Stack({ alignContent: Alignment.End }) {
          //            this.settingItem(4, $r('app.media.ic_setting_calendar'), '同步系统日历', false)
          //            this.settingSwitch(this.IsCalendarSync, (value: boolean) => {
          //              this.IsCalendarSync = value
          //            })
          //          }.height(56).width('100%')
        }
        .Card()

        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 5, icon: $r('app.media.ic_folder'), title: $r('app.string.Edit_folder'), showDivider:false})
            this.settingSubTitle({text: ''})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 5
            this.settingTitle = $r('app.string.Edit_folder')
            this.intoNextPage()
          })
        }
        .Card()

        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 6, icon: $r('app.media.ic_setting_maincolor'), title: $r('app.string.accentColor'), showDivider: false})
            this.settingSubTitle({text: this.accentColorArray[this.AccentColor0][0]})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 6
            this.settingTitle = $r('app.string.accentColor')
            this.intoNextPage()
          })
        }
        .Card()

        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 7, icon: $r('app.media.ic_setting_enovate'), title: $r('app.string.defineCycleLength'), showDivider: true})
            this.settingSubTitle({text: this.DefineCycleLength.toString() + '天'})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 7
            this.settingTitle = $r('app.string.defineCycleLength')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 8, icon: $r('app.media.ic_setting_clock'), title: $r('app.string.defaultClockTime'), showDivider: true})
            this.settingSubTitle({text: this.getTimeInfo([this.DefaultClockTime0, this.DefaultClockTime1], this.DefaultTimeFormat == 0)})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 8
            this.settingTitle = $r('app.string.defaultClockTime')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 15, icon: $r('app.media.ic_new_effectiveTime'), title: $r('app.string.defaultUrgentTime'), showDivider: true})
            this.settingSubTitle({text: this.getTimeInfo([this.DefaultUrgentTime0, this.DefaultUrgentTime1], this.DefaultTimeFormat == 0)})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 15
            this.settingTitle = $r('app.string.defaultUrgentTime')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 9, icon: $r('app.media.ic_setting_calendarSet'), title: $r('app.string.firstDayOfWeek'), showDivider: true})
            this.settingSelect({thisResource: [
              [$r('app.string.Monday'), 0],
              [$r('app.string.Sunday'), 1]
            ], outPut: (value: number) => {
              if (value > -1) {
                this.FirstDayOfWeek = value
                let context: Context = getContext(this) as common.Context
                setStorage("setting", "FirstDayOfWeek", value.toString(), context)
              }
              return this.FirstDayOfWeek
            }})
          }.height(56).width('100%')

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 10, icon: $r('app.media.ic_setting_time'), title: $r('app.string.defaultTimeFormat'), showDivider: false})
            this.settingSelect({thisResource: [
              [$r('app.string.24TimeFormat'), 0],
              [$r('app.string.12TimeFormat'), 1]
            ], outPut: (value: number) => {
              if (value > -1) {
                this.DefaultTimeFormat = value
                let context: Context = getContext(this) as common.Context
                setStorage("setting", "DefaultTimeFormat", value.toString(), context)
              }
              return this.DefaultTimeFormat
            }})
          }.height(56).width('100%')
        }
        .Card()

        Column() {
          //          Stack({ alignContent: Alignment.End }) {
          //            this.settingItem(11, $r('app.media.ic_setting_update'), $r('app.string.checkForUpdates'))
          //            this.settingSubTitle(this.versionName)
          //          }.height(56).width('100%')

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 14, icon: $r('app.media.ic_setting_help'), title: '常见问题', showDivider: true})
            this.settingSubTitle({text: ''})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 14
            this.settingTitle = ''
            router.push({
              url: 'pages/help'
            })
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 12, icon: $r('app.media.ic_setting_secure'), title: '用户协议与隐私声明', showDivider: true})
            this.settingSubTitle({text: ''})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 12
            this.settingTitle = ''
            router.push({
              url: 'pages/illustrate'
            })
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem({settingId: 13, icon: $r('app.media.ic_setting_about'), title: $r('app.string.about'), showDivider: false})
            this.settingSubTitle({text: ''})
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 13
            this.settingTitle = ''
            router.push({
              url: 'pages/about',
              params: {
                statusBarHeightVp: this.statusBarHeightVp,
              },
            });
          })
        }
        .Card()
      }
      .width('100%')
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }
}