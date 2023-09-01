import {
  LocationBackUpPage,
  TerminalsSyncPage,
  DefaultClockTimePage,
  DefaultUrgentTimePage,
  AccentColorPage,
  DefineCycleLengthPage,
  FolderEditPage
} from '../element/SettingSpecificElement';

@Component
export struct SettingSpecific {
  @StorageLink('settingNum') settingNum: number = 0
  @StorageLink('settingTitle') settingTitle: string | Resource = $r('app.string.back')
  @State chooseFolder: number = 0

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''

  private columnNum: number
  private offsetNum: number

  build() {
    Row() {
      if (this.screenType == 'lg') {
        Column().height('100%').width(1).backgroundColor($r('app.color.divider'))
      }
      Column() {
        GridContainer({ columns: this.columnNum, margin: 12, gutter: 12 }) {
          Column() {
            Row() {
              Row() {
                if (this.screenType != 'lg') {
                  Image($r('app.media.ic_setting_back'))
                    .height(24)
                    .width(24)
                    .margin({ right: 16 })
                }
                Text(this.settingTitle)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(20)
                  .fontColor($r('app.color.text_level1'))
              }
              .height(56)
              .onClick(() => {
                if (this.screenType == 'lg')
                  return
                  this.settingNum = 0
                this.settingTitle = $r('app.string.back')
              })
            }
            //          .padding({ left: 24, right: 24 })
            .height(56)
            .width('100%')
            Scroll() {
              if (this.settingNum == 3)
                LocationBackUpPage()
              else if (this.settingNum == 4)
                TerminalsSyncPage()
              else if (this.settingNum == 5)
                FolderEditPage()
              else if (this.settingNum == 6)
                AccentColorPage()
              else if (this.settingNum == 7)
                DefineCycleLengthPage()
              else if (this.settingNum == 8)
                DefaultClockTimePage()
              else if (this.settingNum == 15)
                DefaultUrgentTimePage()
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .layoutWeight(1)
          }
          .width('100%')
          .useSizeType({
            xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
            sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
            md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
            lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
          })
        }
        .layoutWeight(1)
      }
      .height('100%')
      .width('100%')
    }
    .onClick(() => {
    })
    .backgroundColor($r('app.color.background'))
    .height('100%')
    .width('100%')
  }
}