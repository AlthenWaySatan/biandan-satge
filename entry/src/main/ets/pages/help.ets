import router from '@ohos.router'
import { helpResources } from '../model/QuestionAndAnswer';

@Entry
@Component
struct ProgressExample {
  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  @StorageLink('settingNum') settingNum: number = 0
  @State showAnswer: boolean[] = []

  aboutToAppear() {
  }

  aboutToDisappear() {
    this.settingNum = 0
    this.showAnswer = []
  }

  @Builder listItem(title: string, subTitle: string[], showAnswer: boolean) {
    Column() {
      Column() {
        Row() {
          Text(title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
      }
      .margin({ top: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      if (showAnswer)
      Column() {
        ForEach(subTitle, (item: string) => {
          Text(item)
            .fontColor($r('app.color.text_level2'))
            .fontSize(16)
            .margin({ bottom: 8 })
        })
      }
      .margin({ bottom: 8 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .padding({ left: 12, right: 12 })
    .margin({ bottom: 12 })
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('app.color.foreground'))
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
        Text('常见问题')
          .fontWeight(FontWeight.Medium)
          .fontSize(20)
          .fontColor($r('app.color.text_level1'))
      }
      .padding({ left: 24, right: 24 })
      .height(56)
      .width('100%')

      Column() {
        GridContainer({ gutter: 12, margin: 12 }) {
          Scroll() {
            Column() {
              ForEach(helpResources, (item: object, index: number) => {
                Column() {
                  this.listItem(item['Question'], item['Answer'], this.showAnswer[index])
                }
                .onClick(() => {
                  this.showAnswer[index] = !this.showAnswer[index]
                })
              })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .useSizeType({
            sm: { span: 4, offset: 0 },
            md: { span: 6, offset: 1 },
            lg: { span: 8, offset: 2 }
          })
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background'))
  }
}