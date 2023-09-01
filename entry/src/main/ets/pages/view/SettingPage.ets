import bundle from '@ohos.bundle';
import { TitleOne_middle, TitleOne_large } from '../element/Title';
import { SettingTable } from '../element/SettingTable';
import { SettingSpecific } from '../element/SettingSpecific';

@Component
export struct SettingPage {
  @StorageLink('settingNum') settingNum: number = 0

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  //状态栏高度
  private statusBarHeightVp: number
  //应用信息
  @State versionName: string = '0.0.0'

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  aboutToAppear() {
    let bundleName = "cn.biandangroup.biandan";
    let bundleFlags = 0xFFFF0000;
    let options = {
      "userId": 0
    };
    bundle.getBundleInfo(bundleName, bundleFlags, options, (err, data) => {
      if (err) {
        console.error('Operation failed. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Operation successful. Data:' + JSON.stringify(data));
      this.versionName = data.versionName
    })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        Row() {
          Column() {
            Column() {
              if (this.screenType == 'sm') {
                TitleOne_large({
                  mainTitle: $r('app.string.Setting'),
                  columnNum: 4,
                  offsetNum: 0
                })
              } else if (this.screenType == 'md') {
                TitleOne_large({
                  mainTitle: $r('app.string.Setting'),
                  columnNum: 8,
                  offsetNum: 1
                })
              } else {
                TitleOne_middle({
                  mainTitle: $r('app.string.Setting'),
                  columnNum: 4,
                  offsetNum: 0
                })
              }

              Column() {
                if (this.screenType == 'lg') {
                  Column() {
                    SettingTable({
                      versionName: this.versionName,
                      statusBarHeightVp: this.statusBarHeightVp
                    })
                  }
                  .padding({ left: 12, right: 12 })
                } else {
                  GridContainer({ columns: this.screenType == 'md' ? 8 : 4, gutter: 12, margin: 12 }) {
                    Column() {
                      SettingTable({
                        versionName: this.versionName,
                        statusBarHeightVp: this.statusBarHeightVp
                      })
                    }
                    .useSizeType({
                      xs: { span: this.screenType == 'md' ? 6 : 4, offset: this.screenType == 'md' ? 1 : 0 },
                      sm: { span: this.screenType == 'md' ? 6 : 4, offset: this.screenType == 'md' ? 1 : 0 },
                      md: { span: this.screenType == 'md' ? 6 : 4, offset: this.screenType == 'md' ? 1 : 0 },
                      lg: { span: this.screenType == 'md' ? 6 : 4, offset: this.screenType == 'md' ? 1 : 0 }
                    })
                  }
                }
              }
              .width('100%')
              .layoutWeight(1)
            }
            .height('100%')
            .width('100%')
          }
          .width((this.screenType == 'lg' ? '40%' : '100%'))
          .margin({ top: this.statusBarHeightVp })

          if (this.screenType == 'lg') {
            Column().height('100%').width(1).backgroundColor($r('app.color.divider'))
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .height('100%')
      .width('100%')

      if (this.screenType == 'lg') {
        Column() {
          SettingSpecific({
            columnNum: 8,
            offsetNum: 1,
          })
        }
        .padding({ top: this.statusBarHeightVp })
        .height('100%')
        .width('60%')
        .offset({
          x: this.settingNum == 0 ? '60%' : '0%',
          y: 0
        })
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}