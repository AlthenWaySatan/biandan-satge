import router from '@ohos.router'
import {
  LocationBackUpPage,
  TerminalsSyncPage,
  DefaultClockTimePage,
  DefaultUrgentTimePage,
  AccentColorPage,
  DefineCycleLengthPage,
  FolderEditPage
} from './element/SettingSpecificElement';
import { FolderAddPanel } from './view/FolderAddPanel';

@Entry
@Component
struct ProgressExample {
  private statusBarHeightVp: number = router.getParams()['statusBarHeightVp'];
  // private statusBarHeightVp: number = 0;
  @StorageLink('settingNum') settingNum: number = 0
  // @StorageLink('settingNum') settingNum: number = 4

  @StorageLink('settingTitle') settingTitle: string | Resource = $r('app.string.back')
  private columnNum: number = 4;
  private offsetNum: number = 0;
  @State versionName: string = '0.0.0'
  @State name: Resource = $r('app.string.MainAbility_label')
  //屏幕类型
  @StorageLink('screenType') @Watch("onChanged") screenType: string = ''
  // @StorageLink('screenType') @Watch("onChanged") screenType: string = 'sm'
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  @StorageLink('isKeyBoardShow') isKeyBoardShow: boolean = false

  aboutToAppear() {
    if (this.screenType == 'sm') {
      this.columnNum = 4;
      this.offsetNum = 0;
    } else {
      this.columnNum = 8;
      this.offsetNum = 1;
    }
  }

  onChanged() {
    if (this.screenType == 'lg')
      router.back();
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.ic_setting_back'))
            .height(24)
            .width(24)
            .margin({ right: 16 })
            .onClick(() => {
              this.settingNum = 0
              router.back();
            })
          Text(this.settingTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize(20)
            .fontColor($r('app.color.text_level1'))
        }
        .margin({ top: this.statusBarHeightVp })
        .padding({ left: 24, right: 24 })
        .height(56)
        .width('100%')

        GridContainer({ columns: this.columnNum, margin: 12, gutter: 12 }) {
          Column() {
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
                DefaultClockTimePage({
                  outPut: () => {
                    router.back();
                    this.settingNum = 0;
                  }
                })
              else if (this.settingNum == 15)
                DefaultUrgentTimePage({
                  outPut: () => {
                    router.back();
                    this.settingNum = 0;
                  }
                })
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
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

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background'))
  }

  onBackPress() {

    if (this.showFolderAddPanel) {
      this.isKeyBoardShow = false
      this.showFolderAddPanel = false
      return true
    }

    this.settingNum = 0
  }
}