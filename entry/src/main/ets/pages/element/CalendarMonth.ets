import { CalendarWeek } from '../element/CalendarWeek';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)

@Component
export struct CalendarMonth {
  @StorageLink('openCalendar') openCalendar: boolean = false
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @Link isShow : boolean;
  @Link accentColor: Resource
  @Link translucentSaturationAccentColor: Resource

  private getStartDate(date: number[]): number[] {
    var dateTime = new Date(date[0], date[1] - 1, 1);
    if (this.FirstDayOfWeek == 0)
      dateTime = new Date(dateTime.setDate(dateTime.getDate() - (dateTime.getDay() + 6) % 7));
    else
      dateTime = new Date(dateTime.setDate(dateTime.getDate() - dateTime.getDay()));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  /**
   * 获取下n天
   */
  private getNextNDay(date: number[], n: number): number[] {
    var dateTime = new Date(date[0], date[1] - 1, date[2]);
    dateTime = new Date(dateTime.setDate(dateTime.getDate() + n));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  private checkNeedClose(startDate: number[]): boolean {
    for (let i = 0; i < 7; i++) {
      let temp: number[] = this.getNextNDay(startDate, i)
      if (temp[1] == this.startDate[1] && temp[2] == this.startDate[2])
        return false
    }
    return true
  }

  @Builder WeekTitle(text: string | Resource) {
    Column() {
      Column() {
        Text(text)
          .fontColor($r('app.color.text_level2'))
          .fontWeight(FontWeight.Medium)
          .fontSize(14)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.foreground'))
      .height('100%')
      .width('100%')
      .borderRadius(8)
    }
    .padding(3)
    .height('100%')
    .layoutWeight(1)
  }

  @State @Watch('aboutToAppear') startDate: number[] = []
  @State data2: number[][] = new Array(5).fill([])
  @State showSixWeek: boolean = false;

  aboutToAppear() {
  }

  build() {
    Column() {
      ForEach(this.data2, (item: number[], index: number) => {
        Row() {
          CalendarWeek({
            startDate: this.getNextNDay(this.getStartDate(this.startDate), index * 7),
            isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.startDate), index * 7)),
            showDate: $startDate,
            accentColor: $accentColor,
            translucentSaturationAccentColor: $translucentSaturationAccentColor,
            showSixLine: this.getNextNDay(this.getStartDate(this.startDate), 35)[1] == this.startDate[1],
            isShow: $isShow
          })
        }
        .backgroundColor($r('app.color.background'))
      },)
      if (this.getNextNDay(this.getStartDate(this.startDate), 35)[1] == this.startDate[1]) {
        Row() {
          CalendarWeek({
            startDate: this.getNextNDay(this.getStartDate(this.startDate), 35),
            isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.startDate), 35)),
            showDate: $startDate,
            accentColor: $accentColor,
            translucentSaturationAccentColor: $translucentSaturationAccentColor,
            showSixLine: this.getNextNDay(this.getStartDate(this.startDate), 35)[1] == this.startDate[1],
            isShow: $isShow
          })
        }
        .backgroundColor($r('app.color.background'))
      }
    }
    .width('100%')
    .height('100%')
    .animation({
      delay: 150,
      duration: 300, // 动画时长
      curve: Curve.EaseOut, // 动画曲线
    })
    .gesture(
      GestureGroup(GestureMode.Parallel,
        PanGesture({ direction: PanDirection.Up, distance: 1 })
          .onActionEnd(() => {
            this.openCalendar = true
          }),
        PanGesture({ direction: PanDirection.Down, distance: 1 })
          .onActionEnd(() => {
            this.openCalendar = false
          })
      )
    )
  }
}
