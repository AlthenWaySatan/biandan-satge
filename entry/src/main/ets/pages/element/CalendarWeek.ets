import { CalendarDate } from '../element/CalendarDate';

@Component
export struct CalendarWeek {
  @StorageLink('showDate') showDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  @State startDate: number[] = []
  @StorageLink('openCalendar') openCalendar: boolean = false
  @StorageLink('showSixLine') showSixLine: boolean = false
  private isNeedClose: boolean

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

  build() {
    Column() {
      if (!this.openCalendar || !this.isNeedClose)
      Row() {
        CalendarDate({
          date: this.getNextNDay(this.startDate, 0),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 1),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 2),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 3),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 4),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 5),
          isHidden: this.openCalendar && this.isNeedClose
        })
        CalendarDate({
          date: this.getNextNDay(this.startDate, 6),
          isHidden: this.openCalendar && this.isNeedClose
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
