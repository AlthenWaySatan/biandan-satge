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

  easeInOutQuad(s: number, t: number, x: number): number {
    return s + (t - s) * (x < 0.5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) / 2);
  }

  async doneRateChanged() {
    let s = this.ringDoneRate
    let t = this.doneRate
    let temp = 0;
    var d_rate = 0.01;
    console.log("doneRateChanged ~", this.doneRate, this.ringDoneRate)
    for (let i = 0; i < 100; i++) {
      if (temp == 1) {
        this.ringDoneRate = this.doneRate;
        d_rate = 0;
        break;
      } else {
        temp += d_rate;
        this.ringDoneRate = this.easeInOutQuad(s, t, temp);
        console.log("doneRateChanged :", this.doneRate, this.ringDoneRate, temp)
        await this.delay(5);
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
