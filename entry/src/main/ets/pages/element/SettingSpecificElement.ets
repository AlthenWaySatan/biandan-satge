import {
  getLocalTerminals,
  clearTerminalsList,
  CloseSyncListener_devices,
  OpenSyncListener_devices,
  getTerminalsList
} from '../../control/DevicesController';
import {
  getNewAndImportData,
  CloseSyncListener,
  OpenSyncListener,
  UpdateVersionNumber,
  ExportNewVersion,
  getPermission_DISTRIBUTED_DATASYNC
} from '../../control/TerminalsSyncController';
import { RebuildNotification } from '../../control/NotificationController';
import {
  backupFile,
  deleteFile,
  getMediaLibrary,
  importFile,
  getPermission_WRITE_MEDIA
} from '../../control/FileioController';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';
import { backUpPath } from '../../model/BackUpContact';
import { get_accent, getAccentColor } from '../../control/AccentController';
import { deleteAFolder } from '../../control/FolderController';
import FolderResource from '../../model/FolderResourceContact';
import prompt from '@ohos.prompt'
import common from '@ohos.app.ability.common';
import { setStorage } from '../../control/StorageController';

PersistentStorage.PersistProp('BackUpSwitch', 0)
PersistentStorage.PersistProp('AutoBackUpSwitch', 0)
PersistentStorage.PersistProp('TerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('DefaultTimeFormat', 0)
PersistentStorage.PersistProp('AccentColor0', 0)
PersistentStorage.PersistProp('AccentColor1', '')
PersistentStorage.PersistProp('DefaultClockTime0', 10)
PersistentStorage.PersistProp('DefaultClockTime1', 30)
PersistentStorage.PersistProp('DefaultUrgentTime0', 22)
PersistentStorage.PersistProp('DefaultUrgentTime1', 0)
PersistentStorage.PersistProp('DefineCycleLength', 90)

@Component
export struct LocationBackUpPage {
  @StorageLink('BackUpSwitch') BackUpSwitch: number = 0
  @StorageLink('AutoBackUpSwitch') AutoBackUpSwitch: number = 0
  private accentColor: Resource
  @State fileList: mediaLibrary.FileAsset[] = []
  @State showSwitch: boolean = true
  //  @State fileList: string[] = ['20230404222400.json', '20230404222400.json', '20230404222400.json', '20230404222400.json', '20230404222400.json']

  private async refreshFileList() {
    if (this.BackUpSwitch == 1) {
      let context: Context = getContext(this) as common.Context
      this.fileList = await getMediaLibrary(context)
    } else {
      this.fileList = []
    }
  }

  aboutToAppear() {
    this.accentColor = get_accent();
    if (this.BackUpSwitch == 1) {
      let context: Context = getContext(this) as common.Context
      getPermission_WRITE_MEDIA(context).then((value: boolean) => {
        if (!value) {
          this.BackUpSwitch = 0
          this.CODE_DISTURBANCE()
        }
      })
      this.refreshFileList()
    }
  }

  aboutToDisappear() {
  }

  private getFileName(time: string): string {
    let num = Number(time)
    if (isNaN(num)) return time

    let fileTime: Date = new Date(num)
    let y = fileTime.getFullYear()
    let m = fileTime.getMonth() + 1
    let d = fileTime.getDate()
    let h_ = fileTime.getHours()
    let m_ = fileTime.getMinutes()
    let s_ = fileTime.getSeconds()
    let ret =
      y.toString() + '-' +
      m.toString() + '-' +
      d.toString() + ' ' +
      (h_ < 10 ? '0' : '') + h_.toString() + ':' +
      (m_ < 10 ? '0' : '') + m_.toString() + ':' +
      (s_ < 10 ? '0' : '') + s_.toString()
    //    console.log('FileName: ' + ret)
    return ret;
  }

  private async backUpNow() {
    let context: Context = getContext(this) as common.Context
    await backupFile(context)
    setTimeout(() => {
      this.refreshFileList()
    }, 0)
    this.refreshFileList()
  }

  private async importObject(filename: mediaLibrary.FileAsset) {
    let context: Context = getContext(this) as common.Context
    importFile(filename, context).then((ret: [boolean, string]) => {
      if (ret[0]) {
        prompt.showToast({
          message: '导入成功',
          duration: 1000,
        });
        UpdateVersionNumber()
        RebuildNotification(context)
      } else {
        prompt.showToast({
          message: '导入失败：' + ret[1],
          duration: 1000,
        });
      }
    })
  }

  private CODE_DISTURBANCE() {
    this.showSwitch = !this.showSwitch;
    this.showSwitch = !this.showSwitch;
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder settingItem($$:{title: string | Resource}) {
    Stack() {
      Column() {
        Row() {
          Text($$.title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .height(56)
      }
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .height(56)
    .width('100%')
  }
  @Builder settingSubTitle() {
    Row() {
      Image($r('app.media.ic_arrow_right'))
        .width(12)
        .height(24)
        .margin({ left: 4 })
    }
    .padding({ right: 12 })
    .justifyContent(FlexAlign.End)
  }

  @Builder fileItem($$:{filename: mediaLibrary.FileAsset, showDivider: boolean}) {
    Stack({ alignContent: Alignment.End }) {
      Stack() {
        Column() {
          Row() {
            Text(this.getFileName($$.filename.title))
              .fontColor($r('app.color.text_level1'))
              .fontSize(14)
          }
          .height(48)

          if ($$.showDivider)
          Column() {
            Divider().width('100%').color($r('app.color.divider'))
          }

        }
        .padding({ left: 12, right: 12 })
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Row() {
          Button('导入')
            .backgroundColor(this.accentColor)
            .fontSize(14)
            .height(24)
            .margin({ right: 6 })
            .onClick(() => {
              this.importObject($$.filename)
            })

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_edit_delete'))
              .height(14)
              .width(14)
          }
          .backgroundColor($r('app.color.warning'))
          .height(24)
          .width(24)
          .onClick(async () => {
            await deleteFile($$.filename)
            this.refreshFileList()
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.End)
      }
      .height(48)
      .width('100%')
    }.height(48).width('100%')
  }

  private async openBackUp(value: boolean): Promise<boolean> {
    if (value) {
      let context: Context = getContext(this) as common.Context
      let isOn = await getPermission_WRITE_MEDIA(context)
      if (!isOn) {
        prompt.showToast({
          message: '权限未获取，暂无法开启',
          duration: 1000,
        });
        return false
      }
    }
    return value
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({ title: '开启备份' })
            if (this.showSwitch)
            Row() {
              Toggle({ type: ToggleType.Switch, isOn: this.BackUpSwitch == 1 })
                .height(24)
                .selectedColor(this.accentColor)
                .onChange(async (isOn: boolean) => {
                  if (await this.openBackUp(isOn ? true : false))
                    this.BackUpSwitch = 1
                  else
                    this.BackUpSwitch = 0
                  if (this.BackUpSwitch == 0)
                    this.AutoBackUpSwitch = 0
                  this.refreshFileList()
                  this.CODE_DISTURBANCE();
                })
            }
            .padding({ right: 6 })
            .justifyContent(FlexAlign.End)
          }.height(56).width('100%')

          Column() {
            if (this.BackUpSwitch == 1)
              Text('备份目录：' + backUpPath + '\n最多可以保留10个备份')
                .fontSize(14)
                .fontColor($r('app.color.text_level2'))
          }
          .alignItems(HorizontalAlign.Start)
          .height(this.BackUpSwitch == 1 ? 45 : 0)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })
        }
        .Card()
        .height(this.BackUpSwitch == 1 ? 101 : 56)
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })

        if (this.BackUpSwitch == 1)
        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({ title: '开启自动备份' })
            if (this.showSwitch)
            Row() {
              Toggle({ type: ToggleType.Switch, isOn: this.AutoBackUpSwitch == 1 })
                .height(24)
                .selectedColor(this.accentColor)
                .onChange(async (isOn: boolean) => {
                  this.AutoBackUpSwitch = isOn ? 1 : 0
                  this.CODE_DISTURBANCE();
                })
            }
            .padding({ right: 6 })
            .justifyContent(FlexAlign.End)
          }.height(56).width('100%')

          Column() {
            if (this.AutoBackUpSwitch == 1)
              Text('每次退出应用时自动备份')
                .fontSize(14)
                .fontColor($r('app.color.text_level2'))
          }
          .alignItems(HorizontalAlign.Start)
          .height(this.AutoBackUpSwitch == 1 ? 30 : 0)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })
        }
        .Card()
        .height(this.AutoBackUpSwitch == 1 ? 86 : 56)
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })


        if (this.BackUpSwitch == 1)
        Column() {
          Row() {
            Button('立即备份')
              .backgroundColor(this.accentColor)
              .fontSize(16)
              .height(30)
              .margin({ right: 6 })
              .onClick(() => {
                this.backUpNow()
              })

            Blank()

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_setting_refresh'))
                .height(18)
                .width(18)
            }
            .backgroundColor('#00000000')
            .height(30)
            .width(30)
            .onClick(() => {
              this.refreshFileList()
            })
          }.height(56).width('100%')
          .justifyContent(FlexAlign.End)
          .padding({ left: 6, right: 6 })
        }
        .width('100%')

        if (this.BackUpSwitch == 1)
        Column() {
          if (this.fileList.length == 0) {
            Row() {
              Text('暂无备份')
                .fontColor($r('app.color.text_level2'))
                .fontSize(14)
            }
            .height(48)
          } else {
            Column() {
              ForEach(this.fileList, (item: mediaLibrary.FileAsset, index: number) => {
                this.fileItem({filename: item, showDivider: index < this.fileList.length - 1})
              })
            }
          }
        }
        .Card()
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    //    .height('100%')
    //    .backgroundColor(Color.Red)
  }
}

@Component
export struct TerminalsSyncPage {
  @StorageLink('TerminalsSyncSwitch') @Watch('setListener') TerminalsSyncSwitch: number = 0
  @StorageLink('AutoTerminalsSyncSwitch') AutoTerminalsSyncSwitch: number = 0
  private accentColor: Resource
  @State showSwitch: boolean = true
  @State TerminalsList: object[] = []
  @State localTerminals: object = {}

  private async refreshTerminalsList() {
    let context: Context = getContext(this) as common.Context
    this.TerminalsList = await getTerminalsList(context)
  }

  aboutToAppear() {
    this.accentColor = get_accent();
    this.localTerminals = getLocalTerminals();
    let context: Context = getContext(this) as common.Context
    clearTerminalsList(context)
    if (this.TerminalsSyncSwitch == 1) {
      getPermission_DISTRIBUTED_DATASYNC(context).then((value: boolean) => {
        if (!value) {
          this.TerminalsSyncSwitch = 0
          this.CODE_DISTURBANCE()
        }
      })
      this.refreshTerminalsList()
    }
  }

  aboutToDisappear() {
  }

  private CODE_DISTURBANCE() {
    this.showSwitch = !this.showSwitch;
    this.showSwitch = !this.showSwitch;
  }

  private setListener() {
    let context: Context = getContext(this) as common.Context
    if (this.TerminalsSyncSwitch == 1) {
      OpenSyncListener(context)
      OpenSyncListener_devices(() => {
        this.refreshTerminalsList()
      }, context)
    } else {
      CloseSyncListener(context);
      CloseSyncListener_devices(context);
    }
  }

  private exportNow() {
    let context: Context = getContext(this) as common.Context
    ExportNewVersion(context, true)
  }

  private importNow() {
    let context: Context = getContext(this) as common.Context
    getNewAndImportData(context)
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder settingItem($$:{title: string | Resource}) {
    Stack() {
      Column() {
        Row() {
          Text($$.title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .height(56)
      }
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .height(56)
    .width('100%')
  }

  private getIcon(type: string): Resource {
    switch (type) {
      case 'wearable':
        return $r('app.media.ic_setting_watch')
      case 'tablet':
        return $r('app.media.ic_setting_pad')
      default:
        return $r('app.media.ic_setting_phone')
    }
  }

  @Builder TerminalsItem($$:{type: string, title: string | Resource, showDivider: boolean}) {
    Stack() {
      Column() {
        Row() {
          Image(this.getIcon($$.type))
            .height(24)
            .width(24)
          Text($$.title)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          //          Button() {
          //            Image($r('app.media.ic_setting_enovate'))
          //              .height(24)
          //              .width(24)
          //          }
          //          .backgroundColor('#00000000')
          //          .height(30)
          //          .width(30)
          //          .margin({ left: 16 })
        }
        .height(56)

        if ($$.showDivider) {
          Column() {
            Divider().width('100%').color($r('app.color.divider'))
          }.padding({ left: 40 })
        }
      }
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .height(56)
    .width('100%')
  }

  private async openTerminalsSync(value: boolean): Promise<boolean> {
    if (value) {
      let context: Context = getContext(this) as common.Context
      let isOn = await getPermission_DISTRIBUTED_DATASYNC(context)
      if (!isOn) {
        prompt.showToast({
          message: '权限未获取，暂无法开启',
          duration: 1000,
        });
        return false
      }
    }
    return value
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({ title: '开启同步' })
            if (this.showSwitch)
            Row() {
              Toggle({ type: ToggleType.Switch, isOn: this.TerminalsSyncSwitch == 1 })
                .height(24)
                .selectedColor(this.accentColor)
                .onChange(async (isOn: boolean) => {
                  if (await this.openTerminalsSync(isOn ? true : false))
                    this.TerminalsSyncSwitch = 1
                  else
                    this.TerminalsSyncSwitch = 0
                  if (this.TerminalsSyncSwitch == 0)
                    this.AutoTerminalsSyncSwitch = 0
                  let context: Context = getContext(this) as common.Context
                  clearTerminalsList(context);
                  this.refreshTerminalsList()
                  this.CODE_DISTURBANCE();
                })
            }
            .padding({ right: 6 })
            .justifyContent(FlexAlign.End)
          }.height(56).width('100%')

          Column() {
            if (this.TerminalsSyncSwitch == 1)
              Text('开启后将允许其他设备数据覆盖本地数据')
                .fontSize(14)
                .fontColor($r('app.color.text_level2'))
          }
          .alignItems(HorizontalAlign.Start)
          .height(this.TerminalsSyncSwitch == 1 ? 30 : 0)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })
        }
        .Card()
        .height(this.TerminalsSyncSwitch == 1 ? 86 : 56)
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })

        if (this.TerminalsSyncSwitch == 1)
        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({ title: '自动同步数据到其他设备' })
            if (this.showSwitch)
            Row() {
              Toggle({ type: ToggleType.Switch, isOn: this.AutoTerminalsSyncSwitch == 1 })
                .height(24)
                .selectedColor(this.accentColor)
                .onChange(async (isOn: boolean) => {
                  this.AutoTerminalsSyncSwitch = isOn ? 1 : 0
                  this.CODE_DISTURBANCE();
                })
            }
            .padding({ right: 6 })
            .justifyContent(FlexAlign.End)
          }.height(56).width('100%')

          Column() {
            if (this.AutoTerminalsSyncSwitch == 1)
              Text('每次退出应用时自动同步')
                .fontSize(14)
                .fontColor($r('app.color.text_level2'))
          }
          .alignItems(HorizontalAlign.Start)
          .height(this.AutoTerminalsSyncSwitch == 1 ? 30 : 0)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
          })
        }
        .Card()
        .height(this.AutoTerminalsSyncSwitch == 1 ? 86 : 56)
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })

        if (this.TerminalsSyncSwitch == 1)
        Column() {
          Row() {
            Button('向所有设备发送数据')
              .backgroundColor(this.accentColor)
              .fontSize(16)
              .height(30)
              .margin({ right: 6 })
              .onClick(() => {
                this.exportNow()
              })

            Blank()

            Button('接收数据')
              .backgroundColor(this.accentColor)
              .fontSize(16)
              .height(30)
              .margin({ right: 6 })
              .onClick(() => {
                this.importNow()
              })
          }.height(56).width('100%')
          .justifyContent(FlexAlign.End)
          .padding({ left: 6, right: 6 })
        }
        .width('100%')

        if (this.TerminalsSyncSwitch == 1)
        Column() {
          Stack({ alignContent: Alignment.End }) {
            this.settingItem({ title: '已连接设备' })
            if (this.showSwitch)
            Row() {
              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.ic_setting_refresh'))
                  .height(18)
                  .width(18)
              }
              .backgroundColor('#00000000')
              .height(30)
              .width(30)
              .onClick(() => {
                this.refreshTerminalsList()
              })
            }
            .padding({ right: 12 })
            .justifyContent(FlexAlign.End)
          }.height(56).width('100%')

          if (this.TerminalsList.length <= 1) {
            Row() {
              Text('未发现设备，请检查连接')
                .fontColor($r('app.color.text_level2'))
                .fontSize(14)
            }
            .height(56)
          } else {
            Column() {
              ForEach(this.TerminalsList, (item: object, index: number) => {
                if (JSON.stringify(this.localTerminals) != JSON.stringify(item))
                  this.TerminalsItem({type: item['type'], title: item['name'], showDivider: index < this.TerminalsList.length - 1})
              })
            }
          }
        }
        .Card()
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }
}

@Component
export struct DefaultClockTimePage {
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('DefaultClockTime0') DefaultClockTime0: number = 10
  @StorageLink('DefaultClockTime1') DefaultClockTime1: number = 30
  private tempTime: [number, number] = [this.DefaultClockTime0, this.DefaultClockTime1]
  private outPut: () => void = () => {
  }
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      Column() {
        TimePicker({ selected: new Date(2023, 3, 11, this.DefaultClockTime0, this.DefaultClockTime1) })
          .onChange((value: TimePickerResult) => {
            this.tempTime = [value.hour, value.minute]
          })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .width('80%')
          .height(240)
      }
      .height(240)
      .Card()

      Column() {
        Button($r('app.string.confirm'))
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
          .width('100%')
          .onClick(() => {
            this.DefaultClockTime0 = this.tempTime[0]
            this.DefaultClockTime1 = this.tempTime[1]
            this.outPut()
          })
      }
      .Card()
    }
  }
}

@Component
export struct DefaultUrgentTimePage {
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('DefaultUrgentTime0') DefaultUrgentTime0: number = 22
  @StorageLink('DefaultUrgentTime1') DefaultUrgentTime1: number = 0
  private tempTime: [number, number] = [this.DefaultUrgentTime0, this.DefaultUrgentTime1]
  private outPut: () => void = () => {
  }
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      Column() {
        TimePicker({ selected: new Date(2023, 3, 11, this.DefaultUrgentTime0, this.DefaultUrgentTime1) })
          .onChange((value: TimePickerResult) => {
            while (value.hour == 23 && value.minute == 59) {
              value.minute = 58;
              prompt.showToast({
                message: (Object)($r('app.string.urgentTimeWrong')),
                duration: 500,
              });
            }
            this.tempTime = [value.hour, value.minute]
          })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .width('80%')
          .height(240)
      }
      .height(240)
      .Card()

      Column() {
        Button($r('app.string.confirm'))
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
          .width('100%')
          .onClick(() => {
            this.DefaultUrgentTime0 = this.tempTime[0]
            this.DefaultUrgentTime1 = this.tempTime[1]
            this.outPut()
          })
      }
      .Card()
    }
  }
}

@Component
export struct AccentColorPage {
  @StorageLink('AccentColor0') AccentColor0: number = 0;
  @StorageLink('AccentColor1') AccentColor1: string = '';
  @StorageLink('accentColorArray') accentColorArray: [string, string][] = [
    ['便单黄', ''],
    ['宇宙蓝', '_blue'],
    ['燃力红', '_red'],
    ['宝石绿', '_green'],
    ['魔法紫', '_purple'],
    ['樱花粉', '_pink']
  ]
  private outPut: () => {} = () => void {}

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      Column() {
        ForEach(this.accentColorArray, (item: [string, string], index: number) => {
          Column() {
            Row() {
              Row() {
                Column() {
                  Circle()
                    .fill(getAccentColor(item[1]))
                    .height('80%')
                    .width('80%')
                }
                .justifyContent(FlexAlign.Center)
                .height(24)
                .width(24)

                Text(item[0])
                  .fontColor($r('app.color.text_level1'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 16 })
              }
              .height(56)
              .layoutWeight(1)

              Column() {
                Radio({ value: item[1], group: 'AccentColorGroup' })
                  .checked(item[1] == this.AccentColor1)
                  .height(20)
                  .width(20)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.AccentColor0 = index;
                      this.AccentColor1 = item[1];
                      let context: Context = getContext(this) as common.Context
                      setStorage("setting", "accentColor", this.AccentColor1, context);
                      prompt.showToast({
                        message: (Object)($r('app.string.restartToTakeEffect')),
                        duration: 500,
                      });
                    }
                  })
              }
              .width(24)
            }
            .onClick(() => {
              if (item[1] != this.AccentColor1) {
                this.AccentColor0 = index
                this.AccentColor1 = item[1]
                let context: Context = getContext(this) as common.Context
                setStorage("setting", "accentColor", this.AccentColor1, context);
                prompt.showToast({
                  message: (Object)($r('app.string.restartToTakeEffect')),
                  duration: 500,
                });
              }
            })

            if (index != this.accentColorArray.length - 1) {
              Column() {
                Divider().width('100%').color($r('app.color.divider'))
              }.padding({ left: 40 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 12, right: 12 })
        })
      }
      .Card()
    }
  }
}

@Component
export struct DefineCycleLengthPage {
  @StorageLink('DefineCycleLength') DefineCycleLength: number = 90 //默认重复时间长度
  private tempNumber: number = this.DefineCycleLength
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      Column() {
        Column() {
          TextInput({
            placeholder: '请输入默认重复时长（单位：天）',
            text: this.tempNumber.toString()
          })
            .type(InputType.Number)
            .onChange((value: string) => {
              this.tempNumber = Number(value)
            })
        }
        .padding(12)

        Column() {
          Button($r('app.string.confirm'))
            .backgroundColor('#00000000')
            .fontColor(this.accentColor)
            .width('100%')
            .onClick(() => {
              if (this.tempNumber > 0 && this.tempNumber <= 5000 && Math.floor(this.tempNumber) === this.tempNumber) {
                this.DefineCycleLength = this.tempNumber
                prompt.showToast({
                  message: (Object)($r('app.string.restartToTakeEffect')),
                  duration: 500,
                });
              } else {
                prompt.showToast({
                  message: (Object)($r('app.string.numberWrong')),
                  duration: 500,
                });
              }
            })
        }
        .padding(12)
      }
      .Card()
    }
  }
}

@CustomDialog
struct DeleteCustomDialog {
  controller: CustomDialogController
  private folderId: number = 0

  //屏幕类型
  @StorageLink('screenType') @Watch("onChanged") screenType: string = ''
  @StorageLink('selectPos') selectPos: number = 3;
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  onChanged() {
    if (this.screenType == 'md' && this.selectPos == 3)
      this.controller.close()
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.deleteFolder'))
          .width('100%')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_level1'))
      }
      .padding({ left: 8, right: 8 })
      .justifyContent(FlexAlign.Center)
      .height(56)
      .width('100%')

      Column() {
        Text($r('app.string.folderIsNotNull'))
          .width('100%')
          .fontSize(16)
          .fontColor($r('app.color.text_level1'))
      }
      .padding({ left: 8, right: 8 })
      .width('100%')

      Column() {
        Button($r('app.string.folderMove'))
          .onClick(() => {
            let context: Context = getContext(this) as common.Context
            deleteAFolder(this.folderId, false, context)
            this.controller.close()
          })
          .width('100%')
          .height(40)
          .margin({ top: 8 })
          .backgroundColor(this.accentColor)

        Button($r('app.string.deleteAll'))
          .onClick(() => {
            let context: Context = getContext(this) as common.Context
            deleteAFolder(this.folderId, true, context)
            this.controller.close()
          })
          .width('100%')
          .height(40)
          .margin({ top: 12 })
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)

        Button($r("app.string.cancel"))
          .onClick(() => {
            this.controller.close()
          })
          .width('100%')
          .height(40)
          .margin({ top: 4 })
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
      }.padding({ top: 8, bottom: 8 })
    }
    .padding({ left: 16, right: 16 })
  }
}

@Component
export struct FolderEditPage {
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  @StorageLink('folderEdit') folderEdit: boolean = false
  @StorageLink('folderEditId') folderEditId: number = 0
  @StorageLink('folderName') folderName: string | Resource = ''
  @StorageLink('folderClassify') folderClassify: string = 'red'
  @State chooseFolder: number = 0
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteCustomDialog({ folderId: this.chooseFolder })
  })
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      if (this.userFolderResource.length != 0) {
        Column() {
          ForEach(this.userFolderResource, (item: FolderResource, index: number) => {
            Column() {
              Row() {
                Row() {
                  Image(item.icon)
                    .height(24)
                    .width(24)
                  Text(item.title)
                    .fontColor($r('app.color.text_level1'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .margin({ left: 16 })
                }
                .height(56)
                .layoutWeight(1)

                Row() {
                  Button({ type: ButtonType.Circle }) {
                    Image($r('app.media.ic_edit_edit'))
                      .height(18)
                      .width(18)
                  }
                  .backgroundColor(this.accentColor)
                  .height(30)
                  .width(30)
                  .margin({ right: 6 })
                  .onClick(() => {
                    this.folderEdit = true
                    this.folderEditId = item.id
                    this.folderName = item.title
                    this.folderClassify = item.classify
                    this.showFolderAddPanel = true
                  })

                  Button({ type: ButtonType.Circle }) {
                    Image($r('app.media.ic_edit_delete'))
                      .height(18)
                      .width(18)
                  }
                  .backgroundColor($r('app.color.warning'))
                  .height(30)
                  .width(30)
                  .onClick(() => {
                    if (item.counter == 0) {
                      let context: Context = getContext(this) as common.Context
                      deleteAFolder(item.id, true, context)
                    } else {
                      this.chooseFolder = item.id
                      this.dialogController.open()
                    }
                  })
                }
              }

              if (index != this.userFolderResource.length - 1) {
                Column() {
                  Divider().width('100%').color($r('app.color.divider'))
                }
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 12, right: 12 })
          })
        }
        .Card()
      } else {
        Column() {
          Column() {
            Image($r('app.media.ic_folder_add'))
              .height(48)
              .width(48)
              .margin({ bottom: 12 })
            Text('还没有待办单，点击添加')
              .fontColor($r('app.color.text_level1'))
              .fontSize(16)
          }
          .opacity(0.6)
          .onClick(() => {
            this.showFolderAddPanel = true
          })
          .offset({
            x: 0,
            y: -26
          })
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .width('100%')
        .opacity(0.6)
      }
    }
  }
}
