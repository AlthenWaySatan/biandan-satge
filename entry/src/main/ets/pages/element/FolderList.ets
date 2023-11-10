import FolderResource from '../../model/FolderResourceContact';
import EventResource from '../../model/EventsResourceContact';
import { getResource } from '../../control/EventsController';
import { get_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';

@Component
export struct FolderList {
  @Link showResource: FolderResource[]
  private isShowAdd: boolean = false
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false

  @StorageLink('AccentColor1') @Watch('accentColorChanged') AccentColor1: string = '';
  @State accentColor: Resource = get_accent()
  accentColorChanged() {
    this.accentColor = get_accent()
  }

  aboutToAppear() {
    this.accentColor = get_accent();
  }

  private changeFolder(NewFolder: number): void {
    this.folderId = NewFolder
    let context: Context = getContext(this) as common.Context
    getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
  }

  build() {
    Column() {
      ForEach(this.showResource, (item: FolderResource) => {
        Column() {
          Row() {
            Row() {
              Image(item.icon)
                .width(24)
                .height(24)
              Text(item.title)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.folderId == item.id ? this.accentColor : $r('app.color.text_level1'))
                .fontSize(16)
                .margin({ left: 16 })
                .maxLines(1)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
            }
            .width('80%')

            // Row() {
            //   Text(item.counter.toString())
            //     .fontWeight(FontWeight.Medium)
            //     .fontColor($r('app.color.text_level2'))
            //     .fontSize(14)
            // }
            // .justifyContent(FlexAlign.End)
            // .width('20%')
          }
          .width('100%')
          .height(56)

          if(item.id!=-3)
            Divider().width('100%').color($r('app.color.divider'))
        }
        .onClick(() => this.changeFolder(item.id))
      })

      if (this.isShowAdd) {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.ic_folder_add'))
                .width(24)
                .height(24)
              Text($r('app.string.Add_folder'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_level1'))
                .fontSize(16)
                .margin({ left: 16 })
                .maxLines(1)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
            }
            .width('80%')

            Row() {
              Image($r('app.media.ic_arrow_right'))
                .width(12)
                .height(24)
            }
            .justifyContent(FlexAlign.End)
            .width('20%')
          }
          .width('100%')
          .height(56)
        }
        .onClick(()=>{
          this.showFolderAddPanel = true
        })
      }
    }
  }
}

@Component
export struct FolderList_item {
  @Link showResource: FolderResource[]
  controller: CustomDialogController
  private isShowAdd: boolean = false
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false

  @Link thisFolder: number

  private changeFolder(NewFolder: number): void {
    this.thisFolder = NewFolder
  }

  build() {
    Column() {
      ForEach(this.showResource, (item: FolderResource) => {
        if (item.id != 0 && item.id != -2 && item.id != -3) {
          Column() {
            Row() {
              Row() {
                Image(item.icon)
                  .width(24)
                  .height(24)
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_level1'))
                  .fontSize(16)
                  .margin({ left: 16 })
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .layoutWeight(1)

              Column() {
                Radio({ value: this.folderId.toString(), group: 'FolderGroup' })
                  .checked(item.id == this.thisFolder)
                  .height(20)
                  .width(20)
                  .onChange((isChecked:boolean) => {
                    if(isChecked)
                      this.changeFolder(item.id)
                  })
              }
              .width(24)
            }
            .width('100%')
            .height(56)

            if (item.id != -3)
              Divider().width('100%').color($r('app.color.divider'))
          }
          .onClick(() => this.changeFolder(item.id))
        }
      })

      if (this.isShowAdd) {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.ic_folder_add'))
                .width(24)
                .height(24)
              Text($r('app.string.Add_folder'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_level1'))
                .fontSize(16)
                .margin({ left: 16 })
                .maxLines(1)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
            }
            .width('80%')

            Row() {
              Image($r('app.media.ic_arrow_right'))
                .width(12)
                .height(24)
            }
            .justifyContent(FlexAlign.End)
            .width('20%')
          }
          .width('100%')
          .height(56)
        }
        .onClick(()=>{
          console.info('showFolderAddPanel')
          this.showFolderAddPanel = true
          this.controller.close()
        })
      }
    }
  }
}