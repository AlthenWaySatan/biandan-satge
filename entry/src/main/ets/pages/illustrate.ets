import featureAbility from '@ohos.ability.featureAbility';
import { content as content0 } from '../model/UserAgreement';
import { content as content1 } from '../model/PrivacyStatement';
import router from '@ohos.router';

@Entry
@Component
struct Illustrate {
  @State message: string = 'Hello World'
  @StorageLink('settingNum') settingNum: number = 0

  aboutToDisappear() {
    this.settingNum = 0
  }

  private checkIsUrl(temp: string): boolean {
    return (
      (temp == "www.biandangroup.cn") ||
      (temp == "althenwaysatan@outlook.com") ||
      (temp == "798942683") ||
      temp.includes('http') ||
      temp.includes('www') ||
      temp.includes('com')
    );
  }

  @Builder textLink(text: string) {
    Text(text)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.accent'))
      .fontSize(16)
      .onClick(() => {
        if(text == "althenwaysatan@outlook.com") {
          featureAbility.startAbility({
            want: {
              action: 'ohos.want.action.sendSms',
              uri: 'mailto:althenwaysatan@outlook.com'
            }
          });
          return;
        }
        else if(text == "www.biandangroup.cn") {
          featureAbility.startAbility({
            want: {
              action: 'ohos.want.action.viewData',
              entities: ['entity.system.browsable'],
              uri: 'https://www.biandangroup.cn' }
          });
          return;
        }
        else if(text == "798942683") {
          featureAbility.startAbility({
            want: {
              bundleName: 'com.tencent.mobileqq',
              uri: 'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=9N6Fe8pZEnGiJP9MAzC_Bu6NiH_Z1acU&authKey=dLi9PtvnwUK%2FzJD%2BdboFLbPVR8q9oHlRZk9%2Fd6evNjsLyn7KiTkoNKkbQalQvwzP&noverify=0&group_code=798942683' }
          });
          return;
        }
      })
  }

  @Builder fileTitle(icon: Resource, title: string | Resource, updateTime: string | Resource) {
    Column() {
      Image(icon)
        .height(36)
        .width(36)
        .margin({ top: 16 })
      Column() {
        Text(title)
          .fontColor($r('app.color.text_level1'))
          .fontWeight(FontWeight.Bold)
          .fontSize(18)
      }
      .justifyContent(FlexAlign.Center)
      .height(25)
      .width('100%')
      .margin({ top: 16 })

      Column() {
        Text(updateTime)
          .fontColor($r('app.color.text_level1'))
          .fontSize(14)
      }
      .justifyContent(FlexAlign.Center)
      .height(19)
      .width('100%')
      .margin({ top: 4 })
    }
    .height(136)
    .width('100%')
  }

  @Builder fileContent(content: Object) {
    Column() {
      Column() {
        Column() {
          ForEach(content["induct"], (item2: string) => {
            Row() {
              Text(item2)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_level1'))
                .fontSize(16)
            }
            .margin({ bottom: 16 })
            .width('100%')
          })
        }
        .margin({ bottom: 14 })
        .width('100%')
      }

      ForEach(content["list"], (item: object, index: number) => {
        Column() {
          Row() {
            Text((index + 1).toString() + ' ' + item["title"])
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_level1'))
              .fontSize(16)
          }
          .width('100%')

          Column() {
            ForEach(item["introduce"], (item2: string) => {
              Row() {
                if (this.checkIsUrl(item2)) {
                  this.textLink(item2)
                } else {
                  Text(item2)
                    .fontColor($r('app.color.text_level1'))
                    .fontSize(16)
                }
              }
              .margin({ top: 16 })
              .width('100%')
            })
          }
          .margin({ top: 8 })
          .width('100%')

          Column() {
            ForEach(item["list"], (item1: object, index1: number) => {
              Column() {
                Row() {
                  Text((index + 1).toString() + '.' + (index1 + 1).toString() + ' ')
                    .fontColor($r('app.color.text_level1'))
                    .fontSize(16)
                  Text(item1["title"])
                    .fontColor($r('app.color.text_level1'))
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .layoutWeight(1)
                }
                .margin({ top: 16 })
                .width('100%')

                Column() {
                  ForEach(item1["introduce"], (item2: string) => {
                    Row() {
                      if (this.checkIsUrl(item2)) {
                        this.textLink(item2)
                      } else {
                        Text(item2)
                          .fontColor($r('app.color.text_level1'))
                          .fontSize(16)
                      }
                    }
                    .margin({ top: 8 })
                    .width('100%')
                  })
                }
                .margin({ top: 8 })
                .width('100%')
              }
            })
          }
        }
        .padding({ bottom: 24 })
        .width('100%')
      })

      Column() {
        Column() {
          Row() {
            Text('开发者：周哲宇')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_level1'))
              .fontSize(16)
          }
          .margin({ bottom: 16 })
          .width('100%')
          Row() {
            Text('应用名称：便单')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_level1'))
              .fontSize(16)
          }
          .margin({ bottom: 16 })
          .width('100%')
        }
        .margin({ bottom: 14 })
        .width('100%')
      }
    }
  }

  build() {
    Column() {
      // Row() {
      //   Image($r('app.media.ic_setting_back'))
      //     .height(24)
      //     .width(24)
      //     .margin({ right: 16 })
      //     .onClick(() => {
      //       router.back();
      //     })
      // }
      // .padding({ left: 24, right: 24 })
      // .height(56)
      // .width('100%')

      Column() {
        Stepper() {
          StepperItem() {
            Column() {
              Column() {
                Scroll() {
                  Column() {
                    this.fileTitle($r('app.media.ic_setting_user'), content0["title"], '更新日期：' + content0["time"])
                    this.fileContent(content0)
                  }
                  .padding({ left: 24, right: 24 })
                }
                .edgeEffect(EdgeEffect.Spring)
              }
              .height('100%')
              .width('100%')
            }
            .width('100%')
            .height('100%')
          }
          .nextLabel('隐私声明')

          StepperItem() {
            Column() {
              Column() {
                Scroll() {
                  Column() {
                    this.fileTitle($r('app.media.ic_setting_privacy'), content1["title"], '更新日期：' + content1["time"])
                    this.fileContent(content1)
                  }
                  .padding({ left: 24, right: 24 })
                }
                .edgeEffect(EdgeEffect.Spring)
              }
              .height('100%')
              .width('100%')
            }
            .width('100%')
            .height('100%')
          }
          .prevLabel('用户协议')
          .nextLabel('完成')
        }
        .onFinish(() => {
          router.back();
          console.info('onFinish');
        })
      }
      .layoutWeight(1)
      .width("100%")
    }
    .backgroundColor($r('app.color.background'))
  }
}