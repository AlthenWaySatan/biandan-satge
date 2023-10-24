@Entry
@Component
struct FourQuadrantsCard {
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

  private addEvent() {

  }

  private refreshInfo() {

  }

  private Date = "10月28日";
  private Folder = "全部代办";
  private accentColor = $r('app.color.accent')
  private events = [[
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
  ],[
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
  ],[
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
      isPath: true,
      isDone: false,
      State: 2,
      eventId: 0
    }
  ],[
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
    }
  ]
  ]

  private doneNum = 3
  private allNum = 5
  private doneRate = 0.6

  private doneStr = "3/5"

  build() {
    Column() {
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

          Row() {
            Text(this.Folder)
              .fontSize(10)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_level2'))
              .textOverflow({overflow :TextOverflow.Clip})
              .maxLines(1)
          }
          .margin({right: 4})

          Row() {
            Text(this.doneStr)
              .fontSize(10)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_level2'))
              .textOverflow({overflow :TextOverflow.Clip})
              .maxLines(1)
          }
          .margin({right: 4})
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
      .height(31)
      .width('100%')
      .padding({top: 12, left: 12, right: 30})
      Column() {
        Row() {
          Stack() {
            Column(){}
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.highSaturation_red'))
            .opacity(0.2)
            .borderRadius(12)

            Column() {
              Column() {
                Text($r('app.string.quadrant0'))
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.highSaturation_red'))
                  .opacity(0.6)
              }
              Column() {
                ForEach(this.events[0], (item) => {
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
              .height(0)
              .flexGrow(1)
            }
            .padding(6)
            .width('100%')
            .height('100%')

            Column(){}
            .width('100%')
            .height('100%')
            .opacity(0.6)
            .borderWidth(2)
            .borderColor($r('app.color.highSaturation_red'))
            .borderRadius(12)
          }
          .width('50%')
          .height('100%')
          .padding({bottom: 3, right: 3})

          Stack() {
            Column(){}
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.highSaturation_yellow'))
            .opacity(0.2)
            .borderRadius(12)

            Column() {
              Column() {
                Text($r('app.string.quadrant1'))
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.highSaturation_yellow'))
                  .opacity(0.6)
              }
              Column() {
                ForEach(this.events[1], (item) => {
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
              .height(0)
              .flexGrow(1)
            }
            .padding(6)
            .width('100%')
            .height('100%')

            Column(){}
            .width('100%')
            .height('100%')
            .opacity(0.6)
            .borderWidth(2)
            .borderColor($r('app.color.highSaturation_yellow'))
            .borderRadius(12)
          }
          .width('50%')
          .height('100%')
          .padding({bottom: 3, left: 3})
        }
        .width('100%')
        .height('50%')
        Row() {
          Stack() {
            Column(){}
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.highSaturation_lightBlue'))
            .opacity(0.2)
            .borderRadius(12)

            Column() {
              Column() {
                Text($r('app.string.quadrant2'))
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.highSaturation_lightBlue'))
                  .opacity(0.6)
              }
              Column() {
                ForEach(this.events[2], (item) => {
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
              .height(0)
              .flexGrow(1)
            }
            .padding(6)
            .width('100%')
            .height('100%')

            Column(){}
            .width('100%')
            .height('100%')
            .opacity(0.6)
            .borderWidth(2)
            .borderColor($r('app.color.highSaturation_lightBlue'))
            .borderRadius(12)
          }
          .width('50%')
          .height('100%')
          .padding({top: 3, right: 3})

          Stack() {
            Column(){}
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.highSaturation_green'))
            .opacity(0.2)
            .borderRadius(12)

            Column() {
              Column() {
                Text($r('app.string.quadrant1'))
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.highSaturation_green'))
                  .opacity(0.6)
              }
              Column() {
                ForEach(this.events[3], (item) => {
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
              .height(0)
              .flexGrow(1)
            }
            .padding(6)
            .width('100%')
            .height('100%')

            Column(){}
            .width('100%')
            .height('100%')
            .opacity(0.6)
            .borderWidth(2)
            .borderColor($r('app.color.highSaturation_green'))
            .borderRadius(12)
          }
          .width('50%')
          .height('100%')
          .padding({top: 3, left: 3})

        }
        .width('100%')
        .height('50%')
      }
      .width('100%')
      .height(0)
      .flexGrow(1)
      .padding({top: 3, left: 12, bottom: 12, right: 12})
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