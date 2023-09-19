import { ProgressRing } from '../element/ProgressRing'
import { getDoneRate } from '../../control/EventsController';

@Component
export struct DaraField {
  @StorageLink('doneNum') @Watch('newRate') doneNum: number = 0
  @StorageLink('todoNum') @Watch('newRate') todoNum: number = 0
  @State doneRate:number = 0;
  private columnNum: number
  private offsetNum: number

  private newRate() {
    this.doneRate = getDoneRate()
  }

  aboutToAppear() {
    this.newRate();
  }

  build() {
    GridContainer({ columns: this.columnNum, gutter: 12, margin: 12 }) {
      Row() {
        Row() {
          Column() {
            Column() {
              Stack() {
                Text($r('app.string.Done_things'))
                  .fontColor($r('app.color.text_level2'))
                  .fontSize(10)
                  .position({
                    x: 12,
                    y: 12
                  })
                Row() {
                  Text(this.doneNum.toString())
                    .fontColor($r('app.color.text_level1'))
                    .fontSize(36)
                }
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .height('100%')
              .backgroundColor($r('app.color.foreground'))
              .borderRadius(16)
            }
            .width('100%')
            .height('61.8%')
            .padding({ right: 6, bottom: 6 })

            Column() {
              Stack() {
                Text($r('app.string.Todo_things'))
                  .fontColor($r('app.color.text_level2'))
                  .fontSize(10)
                  .position({
                    x: 12,
                    y: 12
                  })
                Row() {
                  Text(this.todoNum.toString())
                    .fontColor($r('app.color.text_level1'))
                    .fontSize(30)
                }
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .height('100%')
              .backgroundColor($r('app.color.foreground'))
              .borderRadius(16)
            }
            .width('100%')
            .height('38.2%')
            .padding({ right: 6, top: 6 })
          }
          .layoutWeight(1)
          .height('100%')

          ProgressRing({ doneRate: $doneRate })

        }.width('100%')
      }
      .width('100%')
      .height(162)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}
