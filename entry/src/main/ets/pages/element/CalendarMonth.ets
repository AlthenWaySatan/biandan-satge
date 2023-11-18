import { CalendarWeek } from '../element/CalendarWeek';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)

@Component
export struct CalendarMonth {
  @Link @Watch('startDatesChanged') startDates: number[][]
  @Link @Watch('isShowsChanged') isShows: boolean[]
  private index: number
  @StorageLink('openCalendar') openCalendar: boolean = false
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @State isShow : boolean = true;
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

  @State @Watch('refreshData') startDate: number[] = []
  @State data2: number[][] = new Array(5).fill([])
  @State checkNeedCloseArr: boolean[] = new Array(5).fill(false)
  @State showSixWeek: boolean = false;

  startDatesChanged() {
    this.startDate = this.startDates[this.index]
  }

  isShowsChanged() {
    this.isShow = this.isShows[this.index]
  }

  refreshData() {
    let temp = this.getStartDate(this.startDate)
    this.data2 = new Array(5).fill([])
    this.checkNeedCloseArr = new Array(5).fill(false)
    this.showSixWeek = false;
    for (let i = 0; i < 5; i++) {
      this.data2[i] = this.getNextNDay(temp, i * 7)
      this.checkNeedCloseArr[i] = this.checkNeedClose(this.data2[i])
    }
    if (this.getNextNDay(temp, 35)[1] == this.startDate[1]) {
      this.showSixWeek = true;
      this.data2.push(this.getNextNDay(temp, 35))
      this.checkNeedCloseArr.push(this.checkNeedClose(this.data2[5]))
    }
  }

  aboutToAppear() {
    this.startDatesChanged()
    this.isShowsChanged()
    this.refreshData()
  }

  build() {
    Column() {
      ForEach(this.data2, (item: number[], index: number) => {
        Row() {
          CalendarWeek({
            startDate: item,
            isNeedClose: this.checkNeedCloseArr[index],
            showDate: $startDate,
            accentColor: $accentColor,
            translucentSaturationAccentColor: $translucentSaturationAccentColor,
            showSixLine: $showSixWeek,
            isShow: $isShow
          })
        }
        .backgroundColor($r('app.color.background'))
      },)
      // if (this.showSixWeek) {
      //   Row() {
      //     CalendarWeek({
      //       startDate: this.getNextNDay(this.getStartDate(this.startDate), 35),
      //       isNeedClose: this.Six_checkNeedClose,
      //       showDate: $startDate,
      //       accentColor: $accentColor,
      //       translucentSaturationAccentColor: $translucentSaturationAccentColor,
      //       showSixLine: this.showSixWeek,
      //       isShow: $isShow
      //     })
      //   }
      //   .backgroundColor($r('app.color.background'))
      // }
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
