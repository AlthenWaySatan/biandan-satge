import prompt from '@ohos.prompt'
import FolderResource from '../../model/FolderResourceContact';
import { createEvent, editThisEvent } from '../../control/EventsController';
import CreateResource from '../../model/CreateResourceContact';
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';
import { getFolderClassify, getFolderIcon } from '../../control/FolderController';
import vibrator from '@ohos.vibrator';


PersistentStorage.PersistProp('FirstDayOfWeek', 0)
PersistentStorage.PersistProp('DefaultTimeFormat', 0)

@Component
export struct EventDetailPanel {
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('showDetailPanelDoneNumber') showDetailPanelDoneNumber: number = 0
  @StorageLink('showDetailPanel') @Watch('setToStart') showDetailPanel: boolean = false
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false
  @StorageLink('screenType') screenType: string = 'sm' //屏幕类型

  @StorageLink('editEvent') editEvent: boolean = false
  @StorageLink('thisEvent') thisEvent: CreateResource = new CreateResource(
    [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  )
  @State folderIcon: Resource = $r('app.media.ic_folder_filled') //当前文件夹图标

  private accentColor: Resource

  //当前打开的象限属性
  @StorageLink('selectPos') @Watch('setToStart') selectPos: number = 0;
  @StorageLink('isQuadrantImportant') @Watch('setToStart') isQuadrantImportant: boolean = false;
  @StorageLink('isQuadrantUrgent') @Watch('setToStart') isQuadrantUrgent: boolean = false;

  /**
   * 当前时间和分类
   */
  @StorageLink('showDate') @Watch('setToStart') showDate: number[] = []
  @StorageLink('folderId') @Watch('setToStart') folderId: number = null

  aboutToAppear() {
    this.accentColor = get_accent()
    this.setToStart()
    // this.thisEvent.name = "很长很长很长很长很长很长"
    // this.thisEvent.name = "很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长"
    // this.thisEvent.comment = "备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注备注"
  }


  /**
   * 重置
   */
  private setToStart() {
    if (!this.showDetailPanel) return;

    if (this.thisEvent.thisFolderId > 0) {
      let folderClassify = getFolderClassify(this.thisEvent.thisFolderId)
      this.folderIcon = getFolderIcon(folderClassify)
    } else {
      this.folderIcon = $r('app.media.ic_folder_filled')
    }
  }

  @Builder listItem(icon: Resource, title: string | Resource, description: string | Resource, showDivider: boolean = true) {
    Column() {
      Row() {
        Row() {
          Image(icon)
            .width(24)
            .height(24)
          Text(title)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_level1'))
            .fontSize(16)
            .margin({ left: 16 })
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
        }
        .width('30%')

        Row() {
          Column() {
            Text(description)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_level2'))
              .fontSize(14)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.End)
          .layoutWeight(1)
        }
        .justifyContent(FlexAlign.End)
        .width('70%')
      }
      .width('100%')
      .height(56)

      if (showDivider) {
        Divider().width('100%').color($r('app.color.divider'))
      }
    }
  }

  private closeThis() {
    this.setToStart()
    this.showDetailPanel = false
  }

  private editThis() {
    this.editEvent = true
    this.showEventAddPanel = true
    this.closeThis()
  }

  build() {
    Panel(this.showDetailPanel) {
      Column() {
        // Scroll() {
        Column() {
          Row() {
            Column() {
              Text("待办详情")
                .fontWeight(FontWeight.Medium)
                .fontSize(20)
                .fontColor($r('app.color.text_level1'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column() {
              Button("编辑")
                .backgroundColor(this.accentColor)
                .onClick(() => {
                  this.editThis()
                })
            }.margin({ right: 12 })

            Column() {
              Button() {
                Image($r('app.media.ic_setting_close'))
                  .height(18)
                  .width(18)
              }
              .type(ButtonType.Circle)
              .backgroundColor($r('app.color.divider'))
              .onClick(() => {
                this.closeThis()
              })
              .height(24)
            }
          }
          .height(28)
          .margin({ bottom: 16 })

          Column() {
            Scroll() {
              Column() {

                Column() {
                  Column() {
                    if (this.showDetailPanel) {
                      Row() {
                        Text(this.thisEvent.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_level1'))
                      }
                      .padding(8)
                      .constraintSize({ minHeight: 40 })
                      .width('100%')
                      .backgroundColor($r('app.color.divider'))
                      .borderRadius(20)
                    }
                  }
                }
                .width('100%')
                .margin({ bottom: 8 })

                Divider().color($r('app.color.divider'))
                  .margin({ bottom: 8 })

                Column() {
                  Row() {
                    Button() {
                      Image(this.folderIcon).height(24).width(24)
                    }
                    .height(40)
                    .width(40)
                    .backgroundColor($r('app.color.divider'))
                    .margin({ right: 8 })
                    .borderRadius(20)
                    .stateEffect(false)

                    Button() {
                      Image(this.thisEvent.isCollect ? $r('app.media.ic_choose_collect_on_Marking') : $r('app.media.ic_new_highlights'))
                        .height(24)
                        .width(24)
                    }
                    .height(40)
                    .width(40)
                    .backgroundColor($r('app.color.divider'))
                    .margin({ right: 8 })
                    .borderRadius(20)
                    .stateEffect(false)

                    Button() {
                      Image(this.thisEvent.isImportant ? $r('app.media.ic_target_warning') : $r('app.media.ic_new_warning'))
                        .height(24)
                        .width(24)
                    }
                    .height(40)
                    .width(40)
                    .backgroundColor($r('app.color.divider'))
                    .margin({ right: 8 })
                    .borderRadius(20)
                    .stateEffect(false)

                    Button() {
                      Column() {
                        Text(this.thisEvent.cycleState == 0 ? this.thisEvent.getShowDate() : "已设置循环")
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_level1'))
                      }
                    }
                    .backgroundColor($r('app.color.divider'))
                    .height(40)
                    .layoutWeight(1)
                    .borderRadius(20)
                    .stateEffect(false)
                  }
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  if (this.showDetailPanel) {
                    Row() {
                      Text(this.thisEvent.comment == "" ? "无备注" : this.thisEvent.comment)
                        .fontSize(14)
                        .fontColor($r('app.color.text_level2'))
                    }
                    // .padding({
                    //   left: 8,
                    //   right: 8,
                    //   top: 13,
                    //   bottom: 13
                    // })
                    .padding(8)
                    .constraintSize({ minHeight: 40 })
                    .width('100%')
                    .backgroundColor($r('app.color.divider'))
                    .borderRadius(20)
                  }
                }

                Column() {
                  this.listItem($r('app.media.ic_new_cycle'), $r('app.string.cycle'), this.thisEvent.getCycleInfo(this.FirstDayOfWeek))
                }

                Column() {
                  this.listItem($r('app.media.ic_new_effectiveTime'), $r('app.string.validTime'), this.thisEvent.getValidTimeInfo(this.DefaultTimeFormat == 0))
                }

                Column() {
                  this.listItem($r('app.media.ic_new_clock'), $r('app.string.clock'), this.thisEvent.getClockInfo(this.DefaultTimeFormat == 0))
                }

                Column() {
                  this.listItem($r('app.media.ic_new_number'), $r('app.string.times'), this.showDetailPanelDoneNumber.toString() + ' / ' + this.thisEvent.countNumber.toString() + ' 次', false)
                }
              }
            }
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        // }
        // .scrollBar(BarState.Off)
        // .width('100%')
        // .height('100%')
      }
      .onClick(() => {
      })
    }
    .type(PanelType.Temporary)
    .backgroundColor($r('app.color.foreground'))
  }
}