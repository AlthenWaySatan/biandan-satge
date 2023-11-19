import EventResource from '../../model/EventsResourceContact';
import vibrator from '@ohos.vibrator';
import { AddCompTime, checkEvents, queryCreateResource, SubCompTime } from '../../control/EventsController';
import { refreshResource } from '../../control/EventsController';
import common from '@ohos.app.ability.common';
import { checkQuadrant, getDescription, getStateResource } from '../../control/EventsResourceController';
import { get_accent } from '../../control/AccentController';

PersistentStorage.PersistProp('DefaultTimeFormat', 0)

@Component
export struct EventQuadrant {
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  private isImportant: boolean
  private isUrgent: boolean
  @StorageLink('isQuadrantHidden') isQuadrantHidden: boolean[] = []
  @StorageLink('isHidden') isHidden: boolean[] = [false, false, false]
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('eventsShowResource') eventsShowResource: string = JSON.stringify([[], [], []])
  @State thisQuadrant: EventResource[][] = [[], [], []]
  @StorageLink('movingEvent') movingEventResource: [number, boolean, boolean] = [0, false, false];
  @StorageLink('showDetailPanelDoneNumber') showDetailPanelDoneNumber: number = 0

  private accentColor: Resource

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  @State isRefreshing: boolean = false
  @State isScroll: boolean = false
  private tootleOffset: number = 0

  aboutToAppear() {
    this.tootleOffset = 0
    this.isScroll = false
    this.accentColor = get_accent()
  }

  private CODE_DISTURBANCE() {
    this.isQuadrantHidden[0] = !this.isQuadrantHidden[0];
    this.isQuadrantHidden[0] = !this.isQuadrantHidden[0];
    this.isHidden[0] = !this.isHidden[0];
    this.isHidden[0] = !this.isHidden[0];
  }

  private completeEvent(eventId: number, state: number) {
    let context: Context = getContext(this) as common.Context
    if (state == 2) {
      SubCompTime(eventId, context);
    } else {
      AddCompTime(eventId, context);
    }
    this.CODE_DISTURBANCE()
  }

  /**
   * 获取标题颜色
   * @param State 状态分类
   */
  private getTitleColor(type: number, State: number): Resource {
    if (type == 1)
      return $r('app.color.warning')
    switch (State) {
      case 2:
        return $r('app.color.text_level2')
      default:
        return $r('app.color.text_level1')
    }
  }

  /**
   * 获取描述颜色
   */
  private getDescriptionColor(type: number): Resource {
    if (type == 1)
      return $r('app.color.warning')
    else
      return $r('app.color.text_level2')
  }

  // private checkUrgent(event: EventResource): boolean {
  //   return (event.validEndTime[0] == this.showDate[0]) && (event.validEndTime[1] == this.showDate[1]) && (event.validEndTime[2] == this.showDate[2]) &&
  //   (event.validEndTime[3] != 23 || event.validEndTime[4] != 59)
  // }

  private getNewResource(): EventResource[][] {
    this.thisQuadrant = [[], [], []]
    let temp = JSON.parse(this.eventsShowResource);
    //    getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId);
    for (let i = 0;i < 3; i++) {
      for (let j = 0;j < temp[i].length; j++)
        if(checkQuadrant(temp[i][j], this.isImportant, this.isUrgent, this.showDate))
        // if (this.eventsShowResource[i][j].isImportant == this.isImportant && this.checkUrgent(this.eventsShowResource[i][j]) == this.isUrgent)
          this.thisQuadrant[i].push(temp[i][j])
    }
    return this.thisQuadrant
  }

  private checkEvents(state: boolean, eventId: number): void {
    checkEvents(state, eventId)
    this.CODE_DISTURBANCE()
  }

  @Builder movingEvent(item: EventResource, index: number) {
    Column() {
      Row() {
        Column() {
          Image(getStateResource(item))
            .height(24)
            .width(24)
        }
        .padding({ left: 12 })
        .height('100%')
        .width(52)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        Column() {
          Column() {
            Text(item.title)
              .fontColor(this.getTitleColor(index, item.state))
              .decoration({
                type: item.state == 2 ? TextDecorationType.LineThrough : TextDecorationType.None,
                color: $r('app.color.icon_level2')
              })
              .maxLines(1)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Row() {
              if (item.isImportant) {
                Image($r('app.media.ic_target_warning'))
                  .height(12)
                  .width(12)
                  .margin({ right: 4 })
              }
              if (item.isCollected) {
                Image($r('app.media.ic_target_highlights'))
                  .height(12)
                  .width(12)
                  .margin({ right: 4 })
              }
              if (item.isClock) {
                Image($r('app.media.ic_target_clock'))
                  .height(12)
                  .width(12)
                  .margin({ right: 4 })
              }
              Text(getDescription(item, this.showDate, this.DefaultTimeFormat == 0))
                .fontColor(this.getDescriptionColor(index))
                .maxLines(1)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .layoutWeight(1)
                .fontSize(12)
            }
            .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .height('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height(56)
    }
    .width(150)
    .padding({ right: 12 })
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('app.color.foreground'))
    .opacity(0.8)
  }

  build() {
    Column() {
      Refresh({ refreshing: this.isRefreshing }) {
        Scroll() {
          Column() {
            ForEach(this.thisQuadrant = this.getNewResource(), (typeQuadrant: EventResource[], index: number) => {
              ForEach(typeQuadrant, (item: EventResource) => {
                Column() {
                  Row() {
                    Column() {
                      Image(getStateResource(item))
                        .height(24)
                        .width(24)
                    }
                    .padding({ left: 12 })
                    .height('100%')
                    .width(52)
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => this.completeEvent(item.eventId, item.state))
                    .gesture(
                      LongPressGesture()
                        .onAction(() => {
                          if (item.doneTimes != 0) {
                            let context: Context = getContext(this) as common.Context
                            SubCompTime(item.eventId, context)
                            vibrator.startVibration({ type: 'time', duration: 10, }, { id: 0, usage: 'touch' })
                            this.CODE_DISTURBANCE()
                          }
                        })
                    )

                    Column() {
                      Column() {
                        Text(item.title)
                          .fontColor(this.getTitleColor(index, item.state))
                          .decoration({
                            type: item.state == 2 ? TextDecorationType.LineThrough : TextDecorationType.None,
                            color: $r('app.color.icon_level2')
                          })
                          .maxLines(1)
                          .textOverflow({
                            overflow: TextOverflow.Ellipsis
                          })
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                        Row() {
                          if (item.isImportant) {
                            Image($r('app.media.ic_target_warning'))
                              .height(12)
                              .width(12)
                              .margin({ right: 4 })
                          }
                          if (item.isCollected) {
                            Image($r('app.media.ic_target_highlights'))
                              .height(12)
                              .width(12)
                              .margin({ right: 4 })
                          }
                          if (item.isClock) {
                            Image($r('app.media.ic_target_clock'))
                              .height(12)
                              .width(12)
                              .margin({ right: 4 })
                          }
                          Text(getDescription(item, this.showDate, this.DefaultTimeFormat == 0))
                            .fontColor(this.getDescriptionColor(index))
                            .maxLines(1)
                            .textOverflow({
                              overflow: TextOverflow.Ellipsis
                            })
                            .layoutWeight(1)
                            .fontSize(12)
                        }
                        .margin({ top: 2 })
                      }
                      .alignItems(HorizontalAlign.Center)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                    }
                    .height('100%')
                    .layoutWeight(1)
                    .onClick(() => {
                      console.log("4Q event onclick")
                      if (this.isEdit)
                        this.checkEvents(!item.isChecked, item.eventId)
                      else {
                        let context: Context = getContext(this) as common.Context
                        console.log("edit event " + item.eventId)
                        queryCreateResource(item.eventId, context)
                        this.showDetailPanelDoneNumber = item.doneTimes
                        setTimeout(() => {
                          AppStorage.Set<boolean>("showDetailPanel", true)
                        }, 200)
                      }
                    })
                    .gesture(
                      LongPressGesture()
                        .onAction(() => {
                          console.log("4Q event LongPressGesture")
                          if (!this.isEdit) {
                            this.checkEvents(true, item.eventId)
                            this.isEdit = true
                            this.checkEvents(true, item.eventId)
                            this.isQuadrantHidden = [false, false, false, false]
                            this.isHidden = [false, false, false]
                            this.isEdit = true
                            vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
                          }
                        })
                    )
                    .onDragStart(() => {
                      this.movingEventResource = [item.eventId, this.isImportant, this.isUrgent];
                      this.isQuadrantHidden = [false, false, false, false]
                      vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
                      return this.movingEvent(item, index);
                    })

                    Column() {
                      Checkbox({ name: item.eventId.toString(), group: 'TodoList' })
                        .height(20)
                        .width(20)
                        .select(item.isChecked)
                        .selectedColor(this.accentColor)
                        .offset({ x: this.isEdit ? 0 : 48, y: 0 })
                        .animation({
                          duration: 200, // 动画时长
                          curve: Curve.EaseOut, // 动画曲线
                          delay: 0, // 动画延迟
                          iterations: 1, // 播放次数
                        })
                        .onChange((value: boolean) =>
                        this.checkEvents(value ? true : false, item.eventId)
                        )
                    }
                    .justifyContent(FlexAlign.Center)
                    .width(this.isEdit ? 24 : 0)
                  }
                  .width('100%')
                  .height(56)

                  Row() {
                    if (typeQuadrant.findIndex((item1) => item1.eventId == item.eventId) != typeQuadrant.length - 1) {
                      Divider().width('100%').color($r('app.color.divider'))
                    } else if ((index == 1 && this.thisQuadrant[2].length > 0) || (index == 0 && (this.thisQuadrant[1].length > 0 || this.thisQuadrant[2].length > 0))) {
                      Column().height(6).width('100%').backgroundColor($r('app.color.divider'))
                    }
                  }
                  .padding({ left: 12 })
                }
                .width('100%')
                .padding({ right: 12 })
                .borderRadius(16)
                .height((typeQuadrant.findIndex((item1) => item1.eventId == item.eventId) == typeQuadrant.length - 1) &&
                        ((index == 1 && this.thisQuadrant[2].length > 0) || (index == 0 && (this.thisQuadrant[1].length > 0 || this.thisQuadrant[2].length > 0))) ?
                  62 : 56)
              })
            })
          }
        }
        .padding(2)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .onScroll((xOffset: number, yOffset: number) => {
          this.tootleOffset += yOffset
          if (this.tootleOffset <= -200 && !this.isRefreshing && !this.isScroll) {
            console.info("yOffset:" + yOffset + ", tootleOffset:" + this.tootleOffset)
            this.isRefreshing = true
            this.isScroll = true
          }
          else if (this.tootleOffset > 0.001 && this.isRefreshing) this.isRefreshing = false
        })
        .onScrollEnd(() => {
          console.info("onScrollEnd")
          this.isScroll = false
          this.tootleOffset = 0;
        })
        .width('100%')
        .offset({
          x: 0,
          y: this.isRefreshing ? 60 : 0
        })
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        console.info('Refresh onStatueChange state is ' + refreshStatus)
        if (refreshStatus == 1) {
          this.isRefreshing = true
        } else if (refreshStatus == 0) {
          this.isRefreshing = false
        }
      })
      .onRefreshing(async () => {
        let context: Context = getContext(this) as common.Context
        await refreshResource(context)
        setTimeout(() => {
          this.CODE_DISTURBANCE()
          this.isRefreshing = false
        }, 200)
        console.log('onRefreshing test')
      })
    }
  }
}