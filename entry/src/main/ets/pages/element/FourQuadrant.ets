import vibrator from '@ohos.vibrator';
import common from '@ohos.app.ability.common';
import { changeQuadrant } from '../../control/EventsController';
import { EventQuadrant } from '../element/EventQuadrant';

PersistentStorage.PersistProp('DefaultUrgentTime0', 22)
PersistentStorage.PersistProp('DefaultUrgentTime1', 0)

@Component
export struct FourQuadrant {
  @StorageLink('isQuadrantHidden') isQuadrantHidden: boolean[] = [false, false, false, false]

  @StorageLink('showDate') showDate: number[] = []

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //当前打开的象限属性
  @StorageLink('isQuadrantImportant') isQuadrantImportant: boolean = false;
  @StorageLink('isQuadrantUrgent') isQuadrantUrgent: boolean = false;
  @StorageLink('movingEvent') movingEventResource: [number, boolean, boolean] = [0, false, false];
  @StorageLink('DefaultUrgentTime0') DefaultUrgentTime0: number = 22;
  @StorageLink('DefaultUrgentTime1') DefaultUrgentTime1: number = 0;

  private isAllShow(): boolean {
    return this.isQuadrantHidden[0] == false && this.isQuadrantHidden[1] == false && this.isQuadrantHidden[2] == false && this.isQuadrantHidden[3] == false
  }

  private moveQuadrant(isImportant: boolean, isUrgent: boolean) {
    if (this.movingEventResource[0] == 0) return;
    if (this.movingEventResource[1] == isImportant && this.movingEventResource[2] == isUrgent)
      return;

    console.log("move " + this.movingEventResource[0] + " " + isImportant + "," + isUrgent);
    let context: Context = getContext(this) as common.Context
    changeQuadrant(this.movingEventResource[0], isImportant, (isUrgent ?
      [this.showDate[0], this.showDate[1], this.showDate[2], this.DefaultUrgentTime0, this.DefaultUrgentTime1] :
      [this.showDate[0], this.showDate[1], this.showDate[2], 23, 59]), context)
    this.movingEventResource = [0, false, false];
  }

  private clickCard(type: number) {
    if (this.isEdit) return;
    if (this.isQuadrantHidden[type] || this.isAllShow()) {
      this.isQuadrantHidden = [true, true, true, true]
      this.isQuadrantHidden[type] = false
      switch (type) {
        case 0:
          this.isQuadrantImportant = true;
          this.isQuadrantUrgent = true;
          break;
        case 1:
          this.isQuadrantImportant = true;
          this.isQuadrantUrgent = false;
          break;
        case 2:
          this.isQuadrantImportant = false;
          this.isQuadrantUrgent = true;
          break;
        default:
          this.isQuadrantImportant = false;
          this.isQuadrantUrgent = false;
      }
    } else {
      this.isQuadrantHidden = [false, false, false, false]
      this.isQuadrantImportant = false;
      this.isQuadrantUrgent = false;
    }
    console.log("Quadrants changed: Important? "+ this.isQuadrantImportant +", Urgent? "+ this.isQuadrantUrgent);
  }

  @Styles row0() {
    .width('100%')
    .height(this.isAllShow() ? '50%' : (this.isQuadrantHidden[0] && this.isQuadrantHidden[1] ? '10%' : '90%'))
    .padding({ bottom: 6 })
    .animation({
      delay: 200,
      duration: 200, // 动画时长
      curve: Curve.Linear, // 动画曲线
    })
  }

  @Styles row1() {
    .width('100%')
    .height(this.isAllShow() ? '50%' : (this.isQuadrantHidden[2] && this.isQuadrantHidden[3] ? '10%' : '90%'))
    .padding({ top: 6 })
    .animation({
      delay: 200,
      duration: 200, // 动画时长
      curve: Curve.Linear, // 动画曲线
    })
  }

  @Styles column0() {
    .height('100%')
    .width(this.isAllShow() ? '50%' : (this.isQuadrantHidden[0] && this.isQuadrantHidden[2] ? '20%' : '80%'))
    .padding({ right: 6 })
    .animation({
      delay: 200,
      duration: 200, // 动画时长
      curve: Curve.Linear, // 动画曲线
    })
  }

  @Styles column1() {
    .height('100%')
    .width(this.isAllShow() ? '50%' : (this.isQuadrantHidden[1] && this.isQuadrantHidden[3] ? '20%' : '80%'))
    .padding({ left: 6 })
    .animation({
      delay: 200,
      duration: 200, // 动画时长
      curve: Curve.Linear, // 动画曲线
    })
  }

  build() {
    Column() {
      Row() {
        Column() {
          Stack() {
            Column() {
              Image($r('app.media.ic_quadrant_red'))
                .height(23)
                .width(23)
                .offset({ x: 2, y: 2 })
            }
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.End)
            .height('100%')
            .width('100%')
            .opacity(0.6)
            .borderRadius(16)
            .border({
              width: 2,
              color: $r('app.color.highSaturation_red'),
            })

            Column() {
              Column() {
                Text($r('app.string.quadrant0'))
                  .fontColor($r('app.color.highSaturation_red'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .padding({ left: 12, right: 12 })
              .height(48)
              .width('100%')
              .justifyContent(FlexAlign.Center)

              if (!this.isQuadrantHidden[0]) {
                Column() {
                  EventQuadrant({
                    isImportant: true,
                    isUrgent: true
                  })
                }
                .layoutWeight(1)
                .width('100%')
              }
            }
            .height('100%').width('100%')
            .borderRadius(16)
            .backgroundColor($r('app.color.translucentSaturation_red'))
          }
          .backgroundColor($r('app.color.foreground'))
          .borderRadius(16)
        }
        .column0()
        .onClick(() => {
          this.clickCard(0)
        })
        .onDragEnter(() => {
          vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
        })
        .onDrop(() => {
          this.moveQuadrant(true, true);
        })

        Column() {
          Stack() {
            Column() {
              Image($r('app.media.ic_quadrant_yellow'))
                .height(23)
                .width(23)
                .offset({ x: -2, y: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.End)
            .height('100%')
            .width('100%')
            .opacity(0.6)
            .borderRadius(16)
            .border({
              width: 2,
              color: $r('app.color.highSaturation_yellow'),
            })

            Column() {
              Column() {
                Text($r('app.string.quadrant1'))
                  .fontColor($r('app.color.highSaturation_yellow'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .padding({ left: 12, right: 12 })
              .height(48)
              .width('100%')
              .justifyContent(FlexAlign.Center)

              if (!this.isQuadrantHidden[1]) {
                Column() {
                  EventQuadrant({
                    isImportant: true,
                    isUrgent: false
                  })
                }
                .layoutWeight(1)
                .width('100%')
              }
            }
            .height('100%').width('100%')
            .borderRadius(16)
            .backgroundColor($r('app.color.translucentSaturation_yellow'))
          }
          .backgroundColor($r('app.color.foreground'))
          .borderRadius(16)
        }
        .column1()
        .onClick(() => {
          this.clickCard(1)
        })
        .onDragEnter(() => {
          vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
        })
        .onDrop(() => {
          this.moveQuadrant(true, false);
        })
      }
      .row0()

      Row() {
        Column() {
          Stack() {
            Column() {
              Image($r('app.media.ic_quadrant_lightBlue'))
                .height(23)
                .width(23)
                .offset({ x: 2, y: -2 })
            }
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.Start)
            .height('100%')
            .width('100%')
            .opacity(0.6)
            .borderRadius(16)
            .border({
              width: 2,
              color: $r('app.color.highSaturation_lightBlue'),
            })

            Column() {
              Column() {
                Text($r('app.string.quadrant2'))
                  .fontColor($r('app.color.highSaturation_lightBlue'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .padding({ left: 12, right: 12 })
              .height(48)
              .width('100%')
              .justifyContent(FlexAlign.Center)

              if (!this.isQuadrantHidden[2]) {
                Column() {
                  EventQuadrant({
                    isImportant: false,
                    isUrgent: true
                  })
                }
                .layoutWeight(1)
                .width('100%')
              }
            }
            .height('100%').width('100%')
            .borderRadius(16)
            .backgroundColor($r('app.color.translucentSaturation_lightBlue'))
          }
          .backgroundColor($r('app.color.foreground'))
          .borderRadius(16)
        }
        .column0()
        .onClick(() => {
          this.clickCard(2)
        })
        .onDragEnter(() => {
          vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
        })
        .onDrop(() => {
          this.moveQuadrant(false, true);
        })

        Column() {
          Stack() {
            Column() {
              Image($r('app.media.ic_quadrant_green'))
                .height(23)
                .width(23)
                .offset({ x: -2, y: -2 })
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .height('100%')
            .width('100%')
            .opacity(0.6)
            .borderRadius(16)
            .border({
              width: 2,
              color: $r('app.color.highSaturation_green'),
            })

            Column() {
              Column() {
                Text($r('app.string.quadrant3'))
                  .fontColor($r('app.color.highSaturation_green'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .padding({ left: 12, right: 12 })
              .height(48)
              .width('100%')
              .justifyContent(FlexAlign.Center)

              if (!this.isQuadrantHidden[3]) {
                Column() {
                  EventQuadrant({
                    isImportant: false,
                    isUrgent: false
                  })
                }
                .layoutWeight(1)
                .width('100%')
              }
            }
            .height('100%').width('100%')
            .borderRadius(16)
            .backgroundColor($r('app.color.translucentSaturation_green'))
          }
          .backgroundColor($r('app.color.foreground'))
          .borderRadius(16)
        }
        .column1()
        .onClick(() => {
          this.clickCard(3)
        })
        .onDragEnter(() => {
          vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
        })
        .onDrop(() => {
          this.moveQuadrant(false, false);
        })
      }
      .row1()

    }.height('100%').width('100%')
  }
}