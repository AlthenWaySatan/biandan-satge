import { get_accent } from '../../control/AccentController';

@Component
export struct ProgressRing {
  @Link doneRate: number;
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent()
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Text((100 * this.doneRate).toFixed(this.doneRate == 1 ? 0 : 1).toString())
            .fontWeight(FontWeight.Medium)
            .fontSize(36)
            .fontColor($r('app.color.text_level1'))
          Text('%')
            .fontWeight(FontWeight.Medium)
            .fontSize(12)
            .fontColor($r('app.color.text_level2'))
        }
        .alignItems(VerticalAlign.Bottom)
        .offset({
          x: 4,
          y: 0
        })

        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .value(this.doneRate * 100)
          .color(this.accentColor)
          .backgroundColor($r('app.color.barIcon_fill_off'))
          .style({ strokeWidth: 18 })
          .animation({
            delay: 200,
            duration: 200, // 动画时长
            curve: Curve.Linear, // 动画曲线
          })
          .width('100%')
          .height('100%')

      }
      .height('100%')
      .width('100%')
    }
    .height(162)
    .width(162)
    .padding({ left: 6 })
  }
}
