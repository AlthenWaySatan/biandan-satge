import { getResource } from '../../control/EventsController';
import { CalendarDate } from '../element/CalendarDate';

@Component
export struct CalendarWeek {
  @Link showDate: number[]
  private data3: number[] = [1, 2, 3, 4, 5, 6, 7]
  @State startDate: number[] = []
  @StorageLink('openCalendar') @Watch('openCalendarChanged') openCalendar: boolean = false
  @State @Watch('changeShow') openCalendarDelay:boolean = this.openCalendar;

  @Link accentColor: Resource
  @Link translucentSaturationAccentColor: Resource

  private isNeedClose: boolean = false;
  private showSixLine: boolean = false;
  @Link @Watch('changeShow') isShow: boolean;
  @State isShowItem: boolean = this.isShow && (!(this.openCalendarDelay || this.openCalendar) || !this.isNeedClose)

  openCalendarChanged() {
    setTimeout(()=> {
      this.openCalendarDelay = this.openCalendar;
      this.changeShow()
    }, 450)
  }

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

  changeShow() {
    this.isShowItem = this.isShow && (!(this.openCalendarDelay || this.openCalendar) || !this.isNeedClose)
  }

  aboutToAppear() {
    this.changeShow()
  }

  build() {
    Column() {
      // Row() {
      //   ForEach(this.data3, (item: number, index: number) => {
      //     CalendarDate({
      //       date: this.getNextNDay(this.startDate, index),
      //       showDate: this.showDate,
      //       accentColor: this.accentColor,
      //       translucentSaturationAccentColor: this.translucentSaturationAccentColor,
      //       isShow: !(this.openCalendarDelay || this.openCalendar) || !this.isNeedClose
      //     })
      //   })
      // }
      Grid() {
        ForEach(this.data3, (item: number, index: number) => {
          GridItem() {
            CalendarDate({
              date: this.getNextNDay(this.startDate, index),
              showDate: $showDate,
              accentColor: $accentColor,
              translucentSaturationAccentColor: $translucentSaturationAccentColor,
              isShow: $isShowItem,
            })
          }
        })
      }
      .rowsTemplate("1fr")
      .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
    }
    .height(this.openCalendar ? (this.isNeedClose ? '0%' : '100%') : (this.showSixLine ? '16.667%' : '20%'))
  }
}
