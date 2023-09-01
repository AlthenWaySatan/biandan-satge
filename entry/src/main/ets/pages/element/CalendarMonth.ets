import { CalendarWeek } from '../element/CalendarWeek';
import { getResource } from '../../control/EventsController';
import { EventsTable } from '../element/EventsTable';
import { AddEventButton } from '../element/AddEventButton';
import { ToolBar } from '../element/ToolBar';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)

@Component
export struct CalendarMonth {
  @StorageLink('selectPos') selectPos: number = 0;
  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false
  @StorageLink('screenType') screenType: string = ''
  @StorageLink('showDate') showDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('openCalendar') openCalendar: boolean = false
  @StorageLink('showSixLine') showSixLine: boolean = false
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0

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
  /**
   * 获取上/下个月
   */
  private getNextNMonth(date: number[], n: number): number[] {
    var dateTime = new Date(date[0], date[1] - 1, date[2]);
    dateTime = new Date(dateTime.setMonth(dateTime.getMonth() + n));
    if (dateTime.getMonth() == (date[1] + n + 11) % 12)
      return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
    else
      return [date[0], (date[1] + n + 11) % 12 + 1, 1]
  }

  private changeShowDate(value: number) {
    if (this.openCalendar)
      this.showDate = this.getNextNDay(this.showDate, 7 * value)
    else
      this.showDate = this.getNextNMonth(this.showDate, value)
    getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId);
  }

  private checkNeedClose(startDate: number[]): boolean {
    for (let i = 0;i < 7; i++) {
      let temp: number[] = this.getNextNDay(startDate, i)
      if (temp[1] == this.showDate[1] && temp[2] == this.showDate[2])
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

  build() {
    Column() {
      if (this.selectPos == 1)
      Column() {
        Column() {
          Row() {
            if (this.FirstDayOfWeek == 1)
              this.WeekTitle($r('app.string.Sun'))
            this.WeekTitle($r('app.string.Mon'))
            this.WeekTitle($r('app.string.Tue'))
            this.WeekTitle($r('app.string.Wed'))
            this.WeekTitle($r('app.string.Thu'))
            this.WeekTitle($r('app.string.Fri'))
            this.WeekTitle($r('app.string.Sat'))
            if (this.FirstDayOfWeek == 0)
              this.WeekTitle($r('app.string.Sun'))
          }
          .height(24)
          .width('100%')
          .animation({
            delay: 200,
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })

          Column() {
            CalendarWeek({
              startDate: this.getStartDate(this.showDate),
              isNeedClose: this.checkNeedClose(this.getStartDate(this.showDate))
            })

            CalendarWeek({
              startDate: this.getNextNDay(this.getStartDate(this.showDate), 7),
              isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.showDate), 7))
            })

            CalendarWeek({
              startDate: this.getNextNDay(this.getStartDate(this.showDate), 14),
              isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.showDate), 14))
            })

            CalendarWeek({
              startDate: this.getNextNDay(this.getStartDate(this.showDate), 21),
              isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.showDate), 21))
            })

            CalendarWeek({
              startDate: this.getNextNDay(this.getStartDate(this.showDate), 28),
              isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.showDate), 28))
            })

            if (this.showSixLine = (this.getNextNDay(this.getStartDate(this.showDate), 35)[1] == this.showDate[1])) {
              CalendarWeek({
                startDate: this.getNextNDay(this.getStartDate(this.showDate), 35),
                isNeedClose: this.checkNeedClose(this.getNextNDay(this.getStartDate(this.showDate), 35))
              })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .gesture(
          GestureGroup(GestureMode.Parallel,
          PanGesture({ direction: PanDirection.Up, distance: 1 })
            .onActionEnd(() => {
              this.openCalendar = true
            }),
          PanGesture({ direction: PanDirection.Down, distance: 1 })
            .onActionEnd(() => {
              this.openCalendar = false
            }),
          PanGesture({ direction: PanDirection.Right, distance: 1 })
            .onActionEnd(() => {
              this.changeShowDate(-1)
            }),
          PanGesture({ direction: PanDirection.Left, distance: 1 })
            .onActionEnd(() => {
              this.changeShowDate(1)
            })
          )
          )

          Column() {
            Image(this.openCalendar ? $r('app.media.ic_calendar_open') : $r('app.media.ic_calendar_close'))
              .width(34.01)
              .height(9.69)
          }
          .justifyContent(FlexAlign.Center)
          .height(16)
          .width(60)
          .margin(6)
          .onClick(() => {
            this.openCalendar = !this.openCalendar
          })
        }
        .height('100%')
        .width('100%')
      }
      .padding({
        left: this.screenType == 'sm' ? 9 : 21,
        right: this.screenType == 'sm' ? 9 : 21,
        bottom: this.screenType == 'lg' ? 6 : 0 })
      .height(this.openCalendar ? '30%' : '100%')
      //      .height(this.screenType == 'lg' ? '30%' : '20%')
      .width('100%')
      .animation({
        delay: 150,
        duration: 300, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
      })

      if (this.openCalendar)
      Column() {
        GridContainer({ columns: this.screenType == 'sm' ? 4 : 8, gutter: 12, margin: 12 }) {
          Column() {
            Stack() {
              Column() {
                EventsTable({})
              }
              .height('100%')
              .width('100%')

              AddEventButton()
            }
            .width('100%')
            .height('100%')
            .alignContent(Alignment.BottomEnd)
          }
          .useSizeType({
            xs: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
            sm: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
            md: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
            lg: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
          })
        }
        .layoutWeight(1)

        ToolBar({
          isHidden: !this.isEdit,
        })
      }
      .height('70%')
      .width('100%')

    }
    .height('100%')
    .width('100%')
  }
}
