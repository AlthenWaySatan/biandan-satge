@Entry
@Component
struct TodolistCard {
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
    postCardAction(this, {
      'action': 'message',
      'params': {
        'type': "clickEvent",
        'eventId': eventId,
        'state': state
      }
    });
  }

  private changePage() {
    postCardAction(this, {
      'action': 'message',
      'params': {
        'type': "changePage"
      }
    });
  }

  private addEvent() {
    postCardAction(this, {
      "action": 'router',
      "abilityName": 'EntryAbility',
      "params": {
        "message": 'addEvent'
      }
    });
  }

  private refreshInfo() {
    postCardAction(this, {
      'action': 'message',
      'params': {
        'type': "refresh"
      }
    });
  }

  @LocalStorageProp('widthLength') widthLength:number = 2;
  @LocalStorageProp('listLength') listLength:number = 5;

  @LocalStorageProp('Date') Date:string = "--月--日";
  @LocalStorageProp('Folder') Folder:string = "全部代办";
  @LocalStorageProp('accentColor') accentColor:Resource = $r('app.color.accent')
  @LocalStorageProp('events') events:Event[] = [
    {
      Title: "----",
      Time: "--:-----:--",
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
      Title: "----",
      Time: "--:-----:--",
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
      Title: "----",
      Time: "--:-----:--",
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
      Title: "----",
      Time: "--:-----:--",
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
      Title: "----",
      Time: "--:-----:--",
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

  @LocalStorageProp('doneNum') doneNum:number = 0
  @LocalStorageProp('allNum') allNum:number = 0
  @LocalStorageProp('doneRate') doneRate:number = 0

  @LocalStorageProp('pageNum') pageNum:number = 0;

  @LocalStorageProp('doneStr') doneStr:string = "0/0"

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

          if(this.widthLength == 4)
            Row() {
              Text(this.Folder)
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_level2'))
                .textOverflow({overflow :TextOverflow.Clip})
                .maxLines(1)
            }
            .margin({right: 4})

          if(this.widthLength == 4)
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
      .backgroundColor(this.accentColor)
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
              if(this.widthLength == 4)
                Row() {
                  Blank()
                    .flexGrow(1)
                  Text(item.Time)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getDescriptionColor(item.isPath, item.State))
                    .textOverflow({overflow :TextOverflow.Clip})
                    .maxLines(1)
                }
                .height('100%')
                .width(0)
                .flexGrow(1)
            }
            .width("100%")
            .height(this.listLength == 5 ? '20%' : '10%')
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
    .height('100%')
    .onClick(() => {
      postCardAction(this, {
        "action": this.ACTION_TYPE,
        "abilityName": this.ABILITY_NAME,
        "params": {
          "message": "todoList"
        }
      });
    })
  }
}

interface Event {
  Title: string,
  Time: string,
  isWarning: boolean,
  isHighlight: boolean,
  stateResource: Resource,
  isClock: boolean,
  isPath: boolean,
  isDone: boolean,
  State: number,
  eventId: number
}