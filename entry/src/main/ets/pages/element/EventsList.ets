import CreateResource from '../../model/CreateResourceContact';
import vibrator from '@ohos.vibrator';
import EventResource from '../../model/EventsResourceContact';
import { checkEvents, AddCompTime, SubCompTime, putOff, queryCreateResource } from '../../control/EventsController';
import { get_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';
import { getDescription, getStateResource } from '../../control/EventsResourceController';

PersistentStorage.PersistProp('DefaultTimeFormat', 0)

@Component
export struct EventsList {
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('showDate') showDate: number[] = []

  //显示资源
  @StorageLink('eventsShowResource') eventsShowResource: string = JSON.stringify([[], [], []])

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //是否隐藏
  @StorageLink('isHidden') isHidden: boolean[] = [false, false, false]

  @StorageLink('editEvent') editEvent: boolean = false
  @StorageLink('thisEvent') thisEvent: CreateResource = new CreateResource([0,0,0])

  @StorageLink('showDetailPanelDoneNumber') showDetailPanelDoneNumber: number = 0

  private type: number //类型
  private isPath: boolean = false //是否已过期
  private isDone: boolean = false //是否已完成
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent()
  }

  private CODE_DISTURBANCE() {
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
  private getTitleColor(State: number): Resource {
    if (this.isPath)
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
  private getDescriptionColor(): Resource {
    if (this.isPath)
      return $r('app.color.warning')
    else
      return $r('app.color.text_level2')
  }

  /**
   * 选择待办
   * @param state 选择状态
   * @param things 待办
   */
  private checkEvents(state: boolean, eventId: number): void {
    checkEvents(state, eventId)
    this.CODE_DISTURBANCE()
  }

  build() {
    Column() {
      ForEach(JSON.parse(this.eventsShowResource)[this.type], (item: EventResource) => {
        Column() {
          if (!this.isHidden[this.type]) {
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
                    .fontColor(this.getTitleColor(item.state))
                    .decoration({
                      type: this.isDone ? TextDecorationType.LineThrough : TextDecorationType.None,
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
                      .fontColor(this.getDescriptionColor())
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
              .gesture(
              LongPressGesture()
                .onAction(() => {
                  if (!this.isEdit) {
                    this.checkEvents(true, item.eventId)
                    this.isEdit = true
                    vibrator.startVibration({ type: 'time', duration: 20, }, { id: 0, usage: 'touch' })
                  }
                })
              )
              .onClick(() => {
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

              if (this.isPath) {
                Column() {
                  Button($r('app.string.putOff'))
                    .height(40)
                    .width(72)
                    .offset({ x: this.isEdit ? 72 : 0, y: 0 })
                    .animation({
                      duration: 200, // 动画时长
                      curve: Curve.EaseOut, // 动画曲线
                      delay: 0, // 动画延迟
                      iterations: 1, // 播放次数
                    })
                    .fontColor(this.accentColor)
                    .backgroundColor($r('app.color.divider'))
                    .onClick(() => {
                      let context: Context = getContext(this) as common.Context
                      putOff(item.eventId, context)
                    })
                }
                .width(this.isEdit ? 0 : 72)
              }

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
          }
          if (!this.isHidden[this.type]) {
            Row() {
              if (JSON.parse(this.eventsShowResource)[this.type].findIndex((item1) => item1.eventId == item.eventId) != JSON.parse(this.eventsShowResource)[this.type].length - 1) {
                Divider().width('100%').color($r('app.color.divider'))
              }
            }
            .padding({ left: 12 })
          }
        }
        .width('100%')
        .padding({ right: 12 })
        .borderRadius(16)
        .height(this.isHidden[this.type] ? 0 : 56)
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
          delay: 0, // 动画延迟
          iterations: 1, // 播放次数
        })
      })
    }
  }
}

@Component
export struct EventsList_little {
  @Link showResource: [string, Resource, number][]
  @State titleColor: Resource = $r('app.color.text_level1')

  build() {
    Column() {
      List() {
        ForEach(this.showResource, (item: [string, string, number]) => {
          ListItem() {
            Column() {
              Text(item[0])
                .fontSize(10)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(item[2] == 1 ? $r('app.color.warning') : $r('app.color.text_level2'))
                .decoration({
                  type: item[2] == 2 ? TextDecorationType.LineThrough : TextDecorationType.None,
                  color: $r('app.color.icon_level2')
                })
            }
            .padding({ left: 3, right: 3 })
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(item[1])
            .height('100%')
            .width('100%')
            .borderRadius(4)
          }
          //        .displayPriority(this.showResource.length - index - 1)
          .margin({ top: 2 })
          .backgroundColor($r('app.color.foreground'))
          .height(14)
          .width('100%')
          .borderRadius(4)
        }, item => JSON.stringify(item))
      }.cachedCount(5)
      .width('100%')
      .height('100%')
    }
    .justifyContent(FlexAlign.End)
  }
}