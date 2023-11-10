import { TitleTwo, TitleOne, EditTitleOne } from '../element/Title';
import { CalendarMonth } from '../element/CalendarMonth';
import { SiderFolder } from '../element/SiderFolder';
import { EventsTable } from '../element/EventsTable';
import { ToolBar } from '../element/ToolBar';
import FolderResource from '../../model/FolderResourceContact';
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';

@Component
export struct CalendarPage {
  @StorageLink('selectPos') selectPos: number = 1;

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //当前日期和待办单
  @StorageLink('showDate') @Watch('calendarViewChanged') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  @StorageLink('openCalendar') @Watch('calendarViewChanged') openCalendar: boolean = false
  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []
  @StorageLink('AccentColor1') @Watch('accentColorChanged') AccentColor1: string = '';
  @State accentColor: Resource = get_accent()
  @State translucentSaturationAccentColor: Resource = get_translucentSaturation_accent()

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  accentColorChanged() {
    this.accentColor = get_accent()
    this.translucentSaturationAccentColor = get_translucentSaturation_accent()
  }

  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0

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

  @State data: number[][] = [
  this.getNextNMonth(this.showDate, -1),
  this.showDate,
  this.getNextNMonth(this.showDate, 1)
  ]
  @State monthShow0: boolean = false;
  @State monthShow1: boolean = true;
  @State monthShow2: boolean = false;
  @State data2: number[][][] = []
  @State index: number = 1

  private getNextNDay(date: number[], n: number): number[] {
    var dateTime = new Date(date[0], date[1] - 1, date[2]);
    dateTime = new Date(dateTime.setDate(dateTime.getDate() + n));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  private getNextNMonth(date: number[], n: number): number[] {
    var dateTime = new Date(date[0], date[1] - 1, date[2]);
    dateTime = new Date(dateTime.setMonth(dateTime.getMonth() + n));
    if (dateTime.getMonth() == (date[1] + n + 11) % 12)
      return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
    else
      return [date[0], (date[1] + n + 11) % 12 + 1, 1]
  }

  calendarViewChanged() {
    this.data[this.index] = this.showDate;
    if (this.openCalendar) {
      this.data[(this.index + 2) % 3] = this.getNextNDay(this.data[this.index], -7);
      this.data[(this.index + 1) % 3] = this.getNextNDay(this.data[this.index], 7);
    } else {
      this.data[(this.index + 2) % 3] = this.getNextNMonth(this.data[this.index], -1);
      this.data[(this.index + 1) % 3] = this.getNextNMonth(this.data[this.index], 1);
    }
  }

  aboutToAppear() {
    this.data = [
    this.getNextNMonth(this.showDate, -1),
    this.showDate,
    this.getNextNMonth(this.showDate, 1)
    ];
    this.accentColor = get_accent()
    this.translucentSaturationAccentColor = get_translucentSaturation_accent()
  }

  build() {
    Column() {
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

          if (this.selectPos == 1)
          Swiper() {
            // ForEach(this.data, (item: number[], index: number) => {
            //   CalendarMonth({
            //     startDate: item,
            //     accentColor: $accentColor,
            //     translucentSaturationAccentColor: $translucentSaturationAccentColor,
            //     isShow: $monthShow[index]
            //   })
            // })

            CalendarMonth({
              startDate: this.data[0],
              accentColor: $accentColor,
              translucentSaturationAccentColor: $translucentSaturationAccentColor,
              isShow: $monthShow0
            })

            CalendarMonth({
              startDate: this.data[1],
              accentColor: $accentColor,
              translucentSaturationAccentColor: $translucentSaturationAccentColor,
              isShow: $monthShow1
            })

            CalendarMonth({
              startDate: this.data[2],
              accentColor: $accentColor,
              translucentSaturationAccentColor: $translucentSaturationAccentColor,
              isShow: $monthShow2
            })
          }
          .loop(true)
          .index(this.index)
          .indicator(false)
          .onChange((index) => {
            if (this.openCalendar) {
              this.data[(index + 2) % 3] = this.getNextNDay(this.data[index], -7);
              this.data[(index + 1) % 3] = this.getNextNDay(this.data[index], 7);
            } else {
              this.data[(index + 2) % 3] = this.getNextNMonth(this.data[index], -1);
              this.data[(index + 1) % 3] = this.getNextNMonth(this.data[index], 1);
            }
            this.index = index;
            this.showDate = this.data[this.index]
            this.monthShow0 = (index == 0)
            this.monthShow1 = (index == 1)
            this.monthShow2 = (index == 2)
          })
          .itemSpace(16)
          .width('100%')
          .layoutWeight(1)
          .animation({
            delay: 150,
            duration: 300, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })

          Column() {
            Column() {
              Image(this.openCalendar ? $r('app.media.ic_calendar_open') : $r('app.media.ic_calendar_close'))
                .width(34.01)
                .height(9.69)
            }
            .width(60)
            .height(16)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(28)
          .padding({ top: 6, bottom: 6 })
          // .backgroundColor(Color.Yellow)
          .onClick(() => {
            this.openCalendar = !this.openCalendar
          })
        }
        .width('100%')
        .height(this.openCalendar ? '30%' : '100%')
        .animation({
          delay: 150,
          duration: 300, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })
        .padding({ bottom: this.screenType == 'lg' ? 6 : 0 })


        if (this.openCalendar)
        Column() {
          EventsTable({})
        }
        .height('70%')
        .width('100%')

      }
      .height('100%')
      .width('100%')
    }
    .visibility(this.selectPos == 1 ? Visibility.Visible : Visibility.None)
    .opacity(this.selectPos == 1 ? 1 : 0)
    .animation({
      duration: 500, // 动画时长
      curve: Curve.EaseInOut, // 动画曲线
    })
  }
}