@Entry
@Component
struct CalendarCard {
  /*
   * The title.
   */
  readonly TITLE: string = 'Hello World';

  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';

  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';

  /*
   * The message.
   */
  readonly MESSAGE: string = 'add detail';

  /*
   * The with percentage setting.
   */
  readonly FULL_WIDTH_PERCENT: string = '100%';

  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';

  private getTitleColor(isPath: boolean, State: number): Resource {
    if (State == 2)
      return $r('app.color.text_level2')
    if (isPath)
      return $r('app.color.warning')
    return $r('app.color.text_level1')
  }

  private getDescriptionColor(isPath: boolean, State: number): Resource {
    if (State == 2)
      return $r('app.color.text_level2')
    if (isPath)
      return $r('app.color.warning')
    return $r('app.color.text_level2')
  }

  private completeEvent(eventId: number, state: number) {
    if (state == 2) {
      // SubCompTime(eventId);
    } else {
      // AddCompTime(eventId);
    }
  }

  private changePage() {

  }

  private lastMonth() {

  }

  private changeDate(date: number, month: number) {

  }

  private nextMonth() {

  }

  private addEvent() {

  }

  private refreshInfo() {

  }

  private getDateTextColor(date: number, month: number) {
    if (date == this.thisDate && month == this.thisMonth)
      return $r('app.color.foreground')
    if (date == new Date().getDate() && month == new Date().getMonth() + 1)
      return this.accentColor;
    if (month == new Date().getMonth() + 1)
      return $r('app.color.text_level1')
    return $r('app.color.text_level2')
  }

  private getPointColor(date: number, month: number) {
    if (date == this.thisDate && month == this.thisMonth)
      return $r('app.color.foreground')
    return this.accentColor;
  }

  private thisDate = 28;
  private thisMonth = 10;

  private Date = "10月28日";
  private Month = "2023年10月";
  private Folder = "全部代办";
  private accentColor = $r('app.color.accent')
  private events = [
    {
      Title: "Text Text",
      Time: "Time Time 123 123",
      isWarning: true,
      isHighlight: true,
      stateResource: $r('app.media.ic_todo_wait_black'),
      isClock: true,
      isPath: false,
      isDone: false,
      State: 0,
      eventId: 0
    },
    {
      Title: "Text Text",
      Time: "Time Time 123 123",
      isWarning: true,
      isHighlight: true,
      stateResource: $r('app.media.ic_todo_wait_black'),
      isClock: true,
      isPath: false,
      isDone: false,
      State: 1,
      eventId: 0
    },
    {
      Title: "Text Text",
      Time: "Time Time 123 123",
      isWarning: true,
      isHighlight: true,
      stateResource: $r('app.media.ic_todo_wait_black'),
      isClock: true,
      isPath: false,
      isDone: false,
      State: 2,
      eventId: 0
    },
    {
      Title: "Text Text",
      Time: "Time Time 123 123",
      isWarning: true,
      isHighlight: true,
      stateResource: $r('app.media.ic_todo_wait_black'),
      isClock: true,
      isPath: true,
      isDone: false,
      State: 0,
      eventId: 0
    },
    {
      Title: "Text Text",
      Time: "Time Time 123 123",
      isWarning: true,
      isHighlight: true,
      stateResource: $r('app.media.ic_todo_wait_black'),
      isClock: true,
      isPath: true,
      isDone: false,
      State: 2,
      eventId: 0
    }
  ]

  private dates = [
    [
      {
        date: 1,
        month: 10,
        haveEvent: false
      },
      {
        date: 2,
        month: 10,
        haveEvent: false
      },
      {
        date: 3,
        month: 10,
        haveEvent: false
      },
      {
        date: 4,
        month: 10,
        haveEvent: false
      },
      {
        date: 5,
        month: 10,
        haveEvent: false
      },
      {
        date: 6,
        month: 10,
        haveEvent: false
      },
      {
        date: 7,
        month: 10,
        haveEvent: false
      }
    ],
    [
      {
        date: 8,
        month: 10,
        haveEvent: true
      },
      {
        date: 9,
        month: 10,
        haveEvent: true
      },
      {
        date: 10,
        month: 10,
        haveEvent: true
      },
      {
        date: 11,
        month: 10,
        haveEvent: true
      },
      {
        date: 12,
        month: 10,
        haveEvent: true
      },
      {
        date: 13,
        month: 10,
        haveEvent: true
      },
      {
        date: 14,
        month: 10,
        haveEvent: true
      }
    ],
    [
      {
        date: 15,
        month: 10,
        haveEvent: true
      },
      {
        date: 16,
        month: 10,
        haveEvent: true
      },
      {
        date: 17,
        month: 10,
        haveEvent: true
      },
      {
        date: 18,
        month: 10,
        haveEvent: true
      },
      {
        date: 19,
        month: 10,
        haveEvent: true
      },
      {
        date: 20,
        month: 10,
        haveEvent: true
      },
      {
        date: 21,
        month: 10,
        haveEvent: true
      }
    ],
    [
      {
        date: 22,
        month: 10,
        haveEvent: true
      },
      {
        date: 23,
        month: 10,
        haveEvent: true
      },
      {
        date: 24,
        month: 10,
        haveEvent: true
      },
      {
        date: 25,
        month: 10,
        haveEvent: true
      },
      {
        date: 26,
        month: 10,
        haveEvent: true
      },
      {
        date: 27,
        month: 10,
        haveEvent: true
      },
      {
        date: 28,
        month: 10,
        haveEvent: true
      }
    ],
    [
      {
        date: 29,
        month: 10,
        haveEvent: true
      },
      {
        date: 30,
        month: 10,
        haveEvent: true
      },
      {
        date: 31,
        month: 10,
        haveEvent: true
      },
      {
        date: 1,
        month: 11,
        haveEvent: true
      },
      {
        date: 2,
        month: 11,
        haveEvent: true
      },
      {
        date: 3,
        month: 11,
        haveEvent: true
      },
      {
        date: 4,
        month: 11,
        haveEvent: true
      }
    ]
  ]

  readonly dateHeader = ['日', '一', '二', '三', '四', '五', '六']

  private doneNum = 3
  private allNum = 5
  private doneRate = 0.6

  private doneStr = "3/5"

  build() {
    Row() {
      Column() {
        Stack() {
          Column()
            .width('50%')
            .height('100%')
            .backgroundColor(this.accentColor)
            .position({x: 0, y: 0})
          Column()
            .width('100%')
            .height('50%')
            .backgroundColor(this.accentColor)
            .position({x: 0, y: 0})
          Column() {
            Row() {
              Row() {
                Row() {
                  Text(this.Date)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_level1'))
                    .textOverflow({overflow :TextOverflow.Clip})
                    .maxLines(1)
                }
                .height('100%')
                .width('100%')
              }
              .height(16)
              .width(0)
              .flexGrow(1)

              Image($r('app.media.ic_form_shuffle'))
                .height(14)
                .width(14)
                .margin({left: 4})
                .flexBasis('auto')
                .onClick(() => {
                  this.changePage();
                })
              Image($r('app.media.ic_form_add'))
                .height(14)
                .width(14)
                .margin({left: 4})
                .flexBasis('auto')
                .onClick(() => {
                  this.addEvent();
                })
              Image($r('app.media.ic_form_refresh'))
                .height(14)
                .width(14)
                .margin({left: 4})
                .flexBasis('auto')
                .onClick(() => {
                  this.refreshInfo();
                })
            }
            .width('100%')
          }
          .width('100%')
          .height('100%')
          .padding({top: 12, left: 12, right: 12})
          .backgroundColor(this.accentColor)
          .borderRadius(12)
        }
        .width('100%')
        .height(31)
        Row() {
          Column() {
            ForEach(this.events, (item) => {
              Row() {
                Image(item.stateResource)
                  .width(20)
                  .height(20)
                  .margin({right: 3})
                  .onClick(() => {
                    this.completeEvent(item.eventId, item.State)
                  })
                Row() {
                  Text(item.Title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getTitleColor(item.isPath, item.State))
                    .textOverflow({overflow :TextOverflow.Clip})
                    .maxLines(1)
                    .decoration({
                      type: item.State == 2 ? TextDecorationType.LineThrough : TextDecorationType.None,
                      color: $r('app.color.icon_level2')
                    })
                }
                .height('100%')
                .width(0)
                .flexGrow(2)
              }
              .width("100%")
              .height('20%')
            })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(0)
        .flexGrow(1)
        .padding({top: 3, left: 12, bottom: 12, right: 12})
      }
      .width('50%')
      .height('100%')
      Column() {
        Row() {
          Image($r('app.media.ic_card_arrow_left'))
            .height(14)
            .width(14)
            .margin({left: 4})
            .flexBasis('auto')
            .onClick(() => {
              this.lastMonth();
            })
          // Blank()
          //   .flexGrow(1)
          Column() {
            Text(this.Month)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_level1'))
              .textOverflow({overflow :TextOverflow.Clip})
              .maxLines(1)
              .textAlign(TextAlign.Center)
          }
          .flexGrow(1)
          .width(0)
          .height('100%')
          // Blank()
          //   .flexGrow(1)
          Image($r('app.media.ic_card_arrow_right'))
            .height(14)
            .width(14)
            .margin({left: 4})
            .flexBasis('auto')
            .onClick(() => {
              this.nextMonth();
            })
        }
        .width('100%')
        .height(31)
        .padding({top: 12, right: 30, left: 30})
        Column() {
          Row() {
            ForEach(this.dateHeader, (item) => {
              Column(){
                Text(item)
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_level3'))
                  .textAlign(TextAlign.Center)
              }
              .height(12)
              .flexGrow(1)
            })
          }
          .height(12)
          .width('100%')
          Column() {
            ForEach(this.dates, (weekDates) => {
              Row() {
                ForEach(weekDates, (item) => {
                  Stack() {
                    if (this.thisMonth == item.month && this.thisDate == item.date)
                      Column() {}
                      .width('100%')
                      .height('100%')
                      .backgroundColor(this.accentColor)
                      .borderRadius(12)
                    Text(item.date.toString())
                      .fontSize(10)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.getDateTextColor(item.date, item.month))
                      .textOverflow({overflow :TextOverflow.Clip})
                      .maxLines(1)
                    if (item.haveEvent)
                      Column() {}
                      .width(4)
                      .height(4)
                      .borderRadius(2)
                      .backgroundColor(this.getPointColor(item.date, item.month))
                      .offset({x: 0, y: 7})
                  }
                  .height('100%')
                  .width(0)
                  .flexGrow(1)
                  .onClick(() => {
                    this.changeDate(item.date, item.month)
                  })
                });
              }
              .width('100%')
              .height(0)
              .flexGrow(1)
            })
          }
          .width('100%')
          .height(0)
          .flexGrow(1)
        }
        .width('100%')
        .height(0)
        .flexGrow(1)
        .padding({top: 3, left: 12, bottom: 12, right: 12})
      }
      .width('50%')
      .height('100%')
    }
    .height('100%')
	.onClick(() => {
      postCardAction(this, {
        "action": this.ACTION_TYPE,
        "abilityName": this.ABILITY_NAME,
        "params": {
          "message": this.MESSAGE
        }
      });
    })
  }
}