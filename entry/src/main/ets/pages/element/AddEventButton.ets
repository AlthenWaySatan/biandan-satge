import { refreshResource } from '../../control/EventsController';
import { getNewAndImportData } from '../../control/TerminalsSyncController';
import { ExportNewVersion } from '../../control/TerminalsSyncController';
import { get_accent } from '../../control/AccentController';
import vibrator from '@ohos.vibrator';
import { get_translucentSaturation_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';

PersistentStorage.PersistProp('TerminalsSyncSwitch', false)

@Component
export struct AddEventButton {
  @StorageLink('isEdit') @Watch('openEdit') isEdit: boolean = false
  @StorageLink('AccentColor') @Watch('accentColorChanged') AccentColor: [number, string] = [0, '']
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false
  @StorageLink('showAddMore') showAddMore: boolean = false
  @State accentColor: Resource = get_accent()
  @State shadowColor: Resource = get_translucentSaturation_accent()
  @State imgSize: number = 60;

  aboutToAppear() {
    this.accentColor = get_accent()
    this.shadowColor = get_translucentSaturation_accent()
  }

  accentColorChanged() {
    this.accentColor = get_accent()
    this.shadowColor = get_translucentSaturation_accent()
  }

  private openEdit() {
    if (this.isEdit)
      this.showAddMore = false
  }

  private exportNow() {
    let context: Context = getContext(this) as common.Context
    ExportNewVersion(context, true)
  }

  private async importNow() {
    let context: Context = getContext(this) as common.Context
    await getNewAndImportData(context)
    await refreshResource(context)
  }

  private shortPress() {
    if (this.isEdit)
      return;
    if (this.showAddMore) {
      this.showAddMore = false
    } else {
      this.showEventAddPanel = true
    }
  }

  private longPress() {
    if (!this.isEdit && !this.showAddMore) {
      if (!AppStorage.Get<boolean>('TerminalsSyncSwitch')) return;
      vibrator.vibrate(20)
      this.showAddMore = true
    }
  }

  build() {
    Stack() {
      Button() {
        Image($r('app.media.ic_setting_upload'))
          .width(24)
          .height(24)
      }
      // .justifyContent(FlexAlign.Center)
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor(this.accentColor)
      .shadow({
        radius: 20,
        color: this.shadowColor,
        offsetY: 10
      })
      .offset({
        x: 0,
        y: this.showAddMore ? -96 : 0
      })
      .animation({
        duration: 200, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
      })
      .onClick(() => {
        this.exportNow()
      })

      Button() {
        Image($r('app.media.ic_setting_download'))
          .width(24)
          .height(24)
      }
      // .justifyContent(FlexAlign.Center)
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor(this.accentColor)
      .shadow({
        radius: 20,
        color: this.shadowColor,
        offsetY: 10
      })
      .offset({
        x: 0,
        y: this.showAddMore ? -54 : 0
      })
      .animation({
        duration: 200, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
      })
      .onClick(() => {
        this.importNow()
      })

      Button() {
        Image($r("app.media.ic_add_Marking"))
          .width('100%')
          .height('100%')
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.showAddMore ? 45 : 0
          })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })
      }
      .width(60)
      .height(60)
      .borderRadius(30)
      .backgroundColor(this.accentColor)
      .shadow({
        radius: 20,
        color: this.shadowColor,
        offsetY: 10
      })
      .onClick(() => {
        this.shortPress()
      })
      .gesture(
        LongPressGesture()
          .onAction(() => {
            this.longPress()
          })
      )
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.imgSize = 48
        }
        if (event.type === TouchType.Up) {
          this.imgSize = 60
        }
      })
    }
    .offset({
      x: -12,
      y: this.isEdit ? 60 : -24
    })
    .animation({
      duration: 200, // 动画时长
      curve: Curve.EaseOut, // 动画曲线
    })
  }
}