import featureAbility from '@ohos.ability.featureAbility';
import router from '@ohos.router';
import bundle from '@ohos.bundle.bundleManager';
import { get_accent } from '../control/AccentController';

@Entry
@Component
struct ProgressExample {
  private statusBarHeightVp: number = router.getParams()['statusBarHeightVp'];
  // private statusBarHeightVp: number = 0;
  @State versionName: string = '1.1.15'
  @State name: Resource = $r('app.string.MainAbility_label')
  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  // @StorageLink('screenType') screenType: string = 'lg'
  @StorageLink('settingNum') settingNum: number = 0

  aboutToAppear() {
    let bundleFlags = 0xFFFF0000;
    bundle.getBundleInfoForSelf(bundleFlags, (err, data) => {
      if (err) {
        console.error('Operation failed. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Operation successful. Data:' + JSON.stringify(data));
      this.versionName = data.versionName
    });
  }

  aboutToDisappear() {
    this.settingNum = 0
  }

  @Builder listItem($$:{title: string | Resource, showDivider: boolean}) {
    Column() {
      Row() {
        Column() {
          Text($$.title)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_arrow_right'))
          .width(12)
          .height(24)
          .margin({ left: 4 })
      }
      .height(48)
      .width('100%')

      if ($$.showDivider)
      Column() {
        Divider().width('100%').color($r('app.color.divider'))
      }
    }
    .padding({ left: 12, right: 12 })
    .height(48)
    .width('100%')
  }

  @Builder listItem2($$:{title: string | Resource, subTitle: string | Resource, showDivider: boolean}) {
    Column() {
      Row() {
        Column() {
          Text($$.title)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
          Text($$.subTitle)
            .fontColor($r('app.color.text_level2'))
            .fontSize(14)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_arrow_right'))
          .width(12)
          .height(24)
          .margin({ left: 4 })
      }
      .height(64)
      .width('100%')

      if ($$.showDivider)
      Column() {
        Divider().width('100%').color($r('app.color.divider'))
      }
    }
    .padding({ left: 12, right: 12 })
    .height(64)
    .width('100%')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_setting_back'))
          .height(24)
          .width(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back();
          })
        Text($r('app.string.about'))
          .fontWeight(FontWeight.Medium)
          .fontSize(20)
          .fontColor($r('app.color.text_level1'))
      }
      .margin({ top: this.statusBarHeightVp })
      .padding({ left: 24, right: 24 })
      .height(56)
      .width('100%')

      Column() {
        Image($r('app.media.icon'))
          .height(72)
          .width(72)
          .borderRadius(15.47)
        Text(this.name)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_level1'))
          .fontSize(16)
          .margin({ top: 16 })
        Text($r('app.string.version', this.versionName))
          .fontColor($r('app.color.text_level2'))
          .fontSize(14)
          .margin({ top: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .width('100%')

      Column() {
        GridContainer({ gutter: 12, margin: 12 }) {
          Scroll() {
            Column() {
              Column(){
                  this.listItem2({title: $r('app.string.ourWebsite'), subTitle: 'www.biandangroup.cn', showDivider: true})
                }.onClick(() => {
                featureAbility.startAbility({
                  want: {
                    action: 'ohos.want.action.viewData',
                    entities: ['entity.system.browsable'],
                    uri: 'https://www.biandangroup.cn' }
                });
              })
              Column(){
                  this.listItem2({title: $r('app.string.contactUs'), subTitle: 'althenwaysatan@outlook.com', showDivider: true})
                }.onClick(() => {
                featureAbility.startAbility({
                  want: {
                    action: 'ohos.want.action.sendSms',
                    uri: 'mailto:althenwaysatan@outlook.com'
                  }
                });
              })
              Column(){
                  this.listItem2({title: "QQ交流群", subTitle: '798942683', showDivider: true})
                }.onClick(() => {
                featureAbility.startAbility({
                  want: {
                    bundleName: 'com.tencent.mobileqq',
                    uri: 'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=9N6Fe8pZEnGiJP9MAzC_Bu6NiH_Z1acU&authKey=dLi9PtvnwUK%2FzJD%2BdboFLbPVR8q9oHlRZk9%2Fd6evNjsLyn7KiTkoNKkbQalQvwzP&noverify=0&group_code=798942683' }
                });
              })
              // Column() {
              //   this.listItem('检查更新')
              // }.onClick(() => {
              //   featureAbility.startAbility({
              //     want: { bundleName: 'com.huawei.appmarket', uri: 'market://details?id=cn.biandangroup.biandan' }
              //   });
              // })
              Column() {
                this.listItem({title: '打开引导界面', showDivider: false})
              }.onClick(() => {
                router.replace({
                  url: 'pages/guide'
                })
              })
            }
            .width('100%')
            .borderRadius(16)
            .backgroundColor($r('app.color.foreground'))
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .useSizeType({
            sm: { span: 4, offset: 0 },
            md: { span: 6, offset: 1 },
            lg: { span: 8, offset: 2 }
          })
        }
        .layoutWeight(1)

        Column() {
          Row() {
            Text($r('app.string.userAgreement'))
              .fontSize(12)
              .fontColor(get_accent())
            Text($r('app.string._and_'))
              .fontSize(12)
              .fontColor($r('app.color.text_level3'))
            Text($r('app.string.privacyStatement'))
              .fontSize(12)
              .fontColor(get_accent())
          }
          .onClick(() => {
            router.push({
              url: 'pages/illustrate'
            })
          })

          Text($r('app.string.copyright'))
            .fontSize(12)
            .fontColor($r('app.color.text_level3'))
          Text($r('app.string.technicalSupport'))
            .fontSize(12)
            .fontColor($r('app.color.text_level3'))
        }
        .height(48)
        .margin({bottom: 24 })
      }
      .height(this.screenType == 'lg' ? '50%' : '60%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background'))
  }
}