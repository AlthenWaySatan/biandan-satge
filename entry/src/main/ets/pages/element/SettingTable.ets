import router from '@ohos.router'
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';
// import { setStorage } from '../../FormAbility/controller/storageController';
//import {client_id, redirect_uri} from '../../model/HMSContact';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)
PersistentStorage.PersistProp('DefaultTimeFormat', 0)
PersistentStorage.PersistProp('AccentColor', [0, ''])
PersistentStorage.PersistProp('DefaultClockTime', [10, 30])
PersistentStorage.PersistProp('DefaultUrgentTime', [22, 0])
PersistentStorage.PersistProp('DefineCycleLength', 90)
PersistentStorage.PersistProp('IsCloudBackup', false)
PersistentStorage.PersistProp('IsCalendarSync', false)

@Component
export struct SettingTable {
  @StorageLink('settingNum') settingNum: number = 0
  @StorageLink('settingTitle') settingTitle: string | Resource = '返回'
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('AccentColor') AccentColor: [number, string] = [0, '']
  @StorageLink('DefaultClockTime') DefaultClockTime: [number, number] = [10, 30]
  @StorageLink('DefaultUrgentTime') DefaultUrgentTime: [number, number] = [22, 0]
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

  @Builder settingItem(settingId: number, icon: Resource, title: string | Resource, showDivider: boolean = true) {
    Stack() {
      if (settingId == this.settingNum) {
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
          Image(icon)
            .height(24)
            .width(24)
          Text(title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
        }
        .height(56)

        if (showDivider) {
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

  @Builder settingSubTitle(text: string = '') {
    Row() {
      Text(text)
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

  @Builder selectMenu(thisResource: [string | Resource, number][], outPut: (value: number) => number) {
    Column() {
      Column() {
        ForEach(thisResource, (item: [string | Resource, number], index: number) => {
          Column() {
            Column() {
              Text(item[0])
                .fontColor(item[1] == outPut(-1) ? get_accent() : $r('app.color.text_level1'))
                .fontSize(14)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ bottom: 12, top: 12 })
            .onTouch(() => {
              outPut(item[1])
              console.info(outPut(-1).toString())
            })

            if (index != thisResource.length - 1)
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

  @Builder settingSelect(thisResource: [string | Resource, number][], outPut: (value: number) => number) {
    Row() {
      Text(thisResource[outPut(-1)][0])
        .fontColor($r('app.color.text_level1'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Image($r('app.media.ic_spinner_level1'))
        .width(24)
        .height(24)
    }
    .bindMenu(this.selectMenu(thisResource, outPut))
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
            this.settingItem(3, $r('app.media.ic_setting_storage'), '本地备份')
            this.settingSubTitle()
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 3
            this.settingTitle = '本地备份'
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(4, $r('app.media.ic_setting_synchronous'), '多端同步', false)
            this.settingSubTitle()
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
            this.settingItem(5, $r('app.media.ic_folder'), $r('app.string.Edit_folder'), false)
            this.settingSubTitle()
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
            this.settingItem(6, $r('app.media.ic_setting_maincolor'), $r('app.string.accentColor'), false)
            this.settingSubTitle()
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
            this.settingItem(7, $r('app.media.ic_setting_enovate'), $r('app.string.defineCycleLength'))
            this.settingSubTitle(this.DefineCycleLength.toString() + '天')
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 7
            this.settingTitle = $r('app.string.defineCycleLength')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(8, $r('app.media.ic_setting_clock'), $r('app.string.defaultClockTime'))
            this.settingSubTitle(this.getTimeInfo(this.DefaultClockTime, this.DefaultTimeFormat == 0))
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 8
            this.settingTitle = $r('app.string.defaultClockTime')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(15, $r('app.media.ic_new_effectiveTime'), $r('app.string.defaultUrgentTime'))
            this.settingSubTitle(this.getTimeInfo(this.DefaultUrgentTime, this.DefaultTimeFormat == 0))
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 15
            this.settingTitle = $r('app.string.defaultUrgentTime')
            this.intoNextPage()
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(9, $r('app.media.ic_setting_calendarSet'), $r('app.string.firstDayOfWeek'))
            this.settingSelect([
              [$r('app.string.Monday'), 0],
              [$r('app.string.Sunday'), 1]
            ], (value: number) => {
              if (value > -1) {
                this.FirstDayOfWeek = value
                // setStorage("appStorage", "FirstDayOfWeek", value.toString())
              }
              return this.FirstDayOfWeek
            })
          }.height(56).width('100%')

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(10, $r('app.media.ic_setting_time'), $r('app.string.defaultTimeFormat'), false)
            this.settingSelect([
              [$r('app.string.24TimeFormat'), 0],
              [$r('app.string.12TimeFormat'), 1]
            ], (value: number) => {
              if (value > -1) {
                this.DefaultTimeFormat = value
                // setStorage("appStorage", "DefaultTimeFormat", value.toString())
              }
              return this.DefaultTimeFormat
            })
          }.height(56).width('100%')
        }
        .Card()

        Column() {
          //          Stack({ alignContent: Alignment.End }) {
          //            this.settingItem(11, $r('app.media.ic_setting_update'), $r('app.string.checkForUpdates'))
          //            this.settingSubTitle(this.versionName)
          //          }.height(56).width('100%')

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(14, $r('app.media.ic_setting_help'), '常见问题')
            this.settingSubTitle()
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 14
            this.settingTitle = ''
            router.push({
              url: 'pages/help'
            })
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(12, $r('app.media.ic_setting_secure'), '用户协议与隐私声明')
            this.settingSubTitle()
          }.height(56).width('100%')
          .onClick(() => {
            this.settingNum = 12
            this.settingTitle = ''
            router.push({
              url: 'pages/illustrate'
            })
          })

          Stack({ alignContent: Alignment.End }) {
            this.settingItem(13, $r('app.media.ic_setting_about'), $r('app.string.about'), false)
            this.settingSubTitle()
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