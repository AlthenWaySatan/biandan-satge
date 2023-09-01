import { refreshResource } from '../../control/EventsController';
import { getNewAndImportData } from '../../control/TerminalsSyncController';
import { ExportNewVersion } from '../../control/TerminalsSyncController';
import { get_accent } from '../../control/AccentController';
import vibrator from '@ohos.vibrator';
import { get_translucentSaturation_accent, get_add_Marking } from '../../control/AccentController';

PersistentStorage.PersistProp('TerminalsSyncSwitch', false)

@Component
export struct AddEventButton {
  @StorageLink('isEdit') @Watch('openEdit') isEdit: boolean = false
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false
  @StorageLink('showAddMore') showAddMore: boolean = false
  private addIcon: Resource
  private accentColor: Resource
  private shadowColor: Resource

  aboutToAppear() {
    this.addIcon = get_add_Marking()
    this.accentColor = get_accent()
    this.shadowColor = get_translucentSaturation_accent()
  }

  private openEdit() {
    if (this.isEdit)
      this.showAddMore = false
  }

  private exportNow() {
    ExportNewVersion(true)
  }

  private async importNow() {
    await getNewAndImportData()
    await refreshResource()
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
      Column() {
        Image($r('app.media.ic_setting_upload'))
          .width(24)
          .height(24)
      }
      .justifyContent(FlexAlign.Center)
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

      Column() {
        Image($r('app.media.ic_setting_download'))
          .width(24)
          .height(24)
      }
      .justifyContent(FlexAlign.Center)
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

      Column() {
        Image(this.addIcon)
          .width(60)
          .height(60)
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