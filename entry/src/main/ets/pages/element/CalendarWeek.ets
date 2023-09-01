import { CalendarDate } from '../element/CalendarDate';

@Component
export struct CalendarWeek {
  @StorageLink('showDate') showDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  @Link @Watch('StartDateRefresh') startDate: number[]
  @StorageLink('openCalendar') openCalendar: boolean = false
  @StorageLink('showSixLine') showSixLine: boolean = false
  @Link isNeedClose: boolean

  /**
   * 获取下n天
   * @param year 年
   * @param month 月
   * @param day 日
   * @param n 之后的n天数
   */
  private getNextNDay(date: number[], n: number): number[] {
    var dateTime = new Date(date[0], date[1] - 1, date[2]);
    dateTime = new Date(dateTime.setDate(dateTime.getDate() + n));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  @State isHidden: boolean = this.openCalendar && this.isNeedClose
  @State date0: number[] = this.getNextNDay(this.startDate, 0)
  @State date1: number[] = this.getNextNDay(this.startDate, 1)
  @State date2: number[] = this.getNextNDay(this.startDate, 2)
  @State date3: number[] = this.getNextNDay(this.startDate, 3)
  @State date4: number[] = this.getNextNDay(this.startDate, 4)
  @State date5: number[] = this.getNextNDay(this.startDate, 5)
  @State date6: number[] = this.getNextNDay(this.startDate, 6)

  private StartDateRefresh() {
    this.date0 = this.getNextNDay(this.startDate, 0)
    this.date1 = this.getNextNDay(this.startDate, 1)
    this.date2 = this.getNextNDay(this.startDate, 2)
    this.date3 = this.getNextNDay(this.startDate, 3)
    this.date4 = this.getNextNDay(this.startDate, 4)
    this.date5 = this.getNextNDay(this.startDate, 5)
    this.date6 = this.getNextNDay(this.startDate, 6)
  }

  build() {
    Column() {
      if (!this.openCalendar || !this.isNeedClose)
      Row() {
        CalendarDate({
          date: $date0,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date1,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date2,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date3,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date4,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date5,
          isHidden: $isHidden
        })
        CalendarDate({
          date: $date6,
          isHidden: $isHidden
        })
      }
      .height('100%')
      .width('100%')
    }
    .height(this.openCalendar ? (this.isNeedClose ? '0%' : '100%') : (this.showSixLine ? '16.667%' : '20%'))
    .width('100%')
    .animation({
      delay: 100,
      duration: 200, // 动画时长
      curve: Curve.Linear, // 动画曲线
    })
  }
}
