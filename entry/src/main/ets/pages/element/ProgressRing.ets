import { get_accent } from '../../control/AccentController';

@Component
export struct ProgressRing {
  @Link @Watch("doneRateChanged") doneRate: number;
  private tempDoneRate: number = this.doneRate
  private accentColor: Resource
  @State ringDoneRate: number = this.tempDoneRate;

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  async doneRateChanged() {
    this.tempDoneRate = this.doneRate;
    var d_rate = (this.tempDoneRate - this.ringDoneRate) > 0 ? 0.001 : -0.001;
    for (let i = 0; i < 1000; i++) {
      if (Math.abs(this.tempDoneRate - this.ringDoneRate) < Math.abs(d_rate)) {
        this.ringDoneRate = this.tempDoneRate;
        d_rate = 0;
        break;
      } else {
        this.ringDoneRate += d_rate;
        await this.delay(2);
      }
    }
    // console.log("doneRateChanged ~", this.tempDoneRate, this.ringDoneRate)
  }

  aboutToAppear() {
    this.accentColor = get_accent()
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Text((100 * this.ringDoneRate).toFixed(this.ringDoneRate == 1 ? 0 : 1).toString())
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
          .value(this.ringDoneRate * 100)
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
