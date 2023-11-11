@Entry
@Component
struct RecommendCard {

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

  /**
   * 获取标题颜色
   * @param State 状态分类
   */
  private getTitleColor(State: number): Resource {
    if (State == 2)
       return $r('app.color.text_level3')
    if (this.event.isPath)
      return $r('app.color.warning')
    return $r('app.color.text_level1')
  }

  /**
   * 获取描述颜色
   */
  private getDescriptionColor(): Resource {
    if (this.event.State == 2)
      return $r('app.color.text_level3')
    if (this.event.isPath)
      return $r('app.color.warning')
    return $r('app.color.text_level3')
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

  private nextPage() {
  postCardAction(this, {
    'action': 'message',
    'params': {
      'type': "nextPage"
    }
  });
}

  private lastPage() {
    postCardAction(this, {
      'action': 'message',
      'params': {
        'type': "lastPage"
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

  @LocalStorageProp('Date') Date:string = "--月--日";
  @LocalStorageProp('Folder') Folder:string = "全部代办";
  @LocalStorageProp('accentColor') accentColor:Resource = $r('app.color.accent')

  @LocalStorageProp('showEvent') showEvent: boolean = true;

  @LocalStorageProp('event') event:Event = {
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
  }

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
          // Blank()
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
        .padding({right: 18})
        Row() {
          Text(this.Folder)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_level2'))
            .textOverflow({overflow :TextOverflow.Clip})
            .maxLines(1)
        }
        .height(12)
        .width('100%')
      }
      .height(28)
      .width('100%')
      Row() {
        Stack() {
          Row() {
            Text(this.doneStr)
              .fontWeight(FontWeight.Medium)
              .fontSize(14)
              .fontColor($r('app.color.text_level2'))
          }
          Progress({ value: 0, total: 100, type: ProgressType.Ring })
            .value(this.doneRate * 100)
            .color(this.accentColor)
            .backgroundColor($r('app.color.barIcon_fill_off'))
            .style({ strokeWidth: 8 })
            .animation({
              delay: 200,
              duration: 200, // 动画时长
              curve: Curve.Linear, // 动画曲线
            })
            .width('100%')
            .height('100%')
        }
        .height('100%')
        .aspectRatio(1)
      }
      .margin(6)
      .width('100%')
      .height(0)
      .flexGrow(1)
      Stack(){
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .backgroundColor(this.accentColor)
          .opacity(0.2)
        if(this.showEvent)
          Row(){
            Column() {
              Image(this.event.stateResource)
                .width('100%')
                .height('100%')
            }
            .width(24)
            .height(24)
            .onClick(() => {
              this.completeEvent(this.event.eventId, this.event.State)
            })
            Column() {
              Row() {
                Text(this.event.Title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getTitleColor(this.event.State))
                .textOverflow({overflow :TextOverflow.Clip})
                .maxLines(1)
                  .decoration({
                    type: this.event.State == 2 ? TextDecorationType.LineThrough : TextDecorationType.None,
                    color: $r('app.color.icon_level2')
                  })
              }
              .width('100%')
              .height(16)
              // .backgroundColor(Color.Red);
              Row() {
                if(this.event.isWarning)
                  Image($r('app.media.ic_target_warning'))
                    .height(12)
                    .width(12)
                    .margin({right: 4})
                    .flexBasis('auto')
                if(this.event.isHighlight)
                  Image($r('app.media.ic_target_highlights'))
                    .height(12)
                    .width(12)
                    .margin({right: 4})
                    .flexBasis('auto')
                if(this.event.isClock)
                  Image($r('app.media.ic_target_clock'))
                    .height(12)
                    .width(12)
                    .margin({right: 4})
                    .flexBasis('auto')
                Row() {
                  Row() {
                    Text(this.event.Time)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.getDescriptionColor())
                      .textOverflow({overflow :TextOverflow.Clip})
                      .maxLines(1)
                  }
                  .height('100%')
                  .width('100%')
                }
                .height('100%')
                .width(0)
                .flexGrow(1)
              }
              .width('100%')
              .height(14)
              // .backgroundColor(Color.Green);
            }
            .margin({left: 3})
            .padding({top: 3, bottom: 3, right: 3})
            .width(0)
            .height('100%')
            .flexGrow(1)
            // .backgroundColor($r('app.color.accent_pink'))
            .borderRadius(9)
            Column(){
              Image($r('app.media.ic_card_arrow_left'))
                .height(14)
                .width(14)
                .flexBasis('auto')
                .onClick(() => {
                  this.lastPage();
                })
              Blank()
                .width(0)
                .flexGrow(1)
              Image($r('app.media.ic_card_arrow_right'))
                .height(14)
                .width(14)
                .flexBasis('auto')
                .onClick(() => {
                  this.nextPage();
                })
            }
            .padding({top: 2, bottom: 2})
            .height('100%')
            .width(14)
          }
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .padding(3)
      }
      .width('100%')
      .height(42)
    }
    .padding(12)
    .height('100%')
    .onClick(() => {
      postCardAction(this, {
        "action": this.ACTION_TYPE,
        "abilityName": this.ABILITY_NAME,
        "params": {
          "message": "recommend"
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