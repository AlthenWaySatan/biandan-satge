import window from '@ohos.window';
import prompt from '@ohos.prompt'
import { addNewFolder, editNewFolder } from '../../control/FolderController';
import { get_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';

@Component
export struct FolderAddPanel {
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  @StorageLink('screenType') screenType: string = ''
  @StorageLink('folderEdit') isEdit: boolean = false
  @StorageLink('folderEditId') folderId: number = 0
  @StorageLink('folderName') name: string = ''
  @StorageLink('folderClassify') chooseClassify: string = 'red'

  private accentColor: Resource
  aboutToAppear(): void {
    this.accentColor = get_accent()
  }

  //  aboutToAppear(): void {
  //    window.getTopWindow((err, data) => {
  //      var windowClass = data;
  //      windowClass.on('keyboardHeightChange', (data) => {
  //        this.mode = PanelMode.Full
  //        console.info('Succeeded in enabling the listener for keyboard height changes. Data: ' + JSON.stringify(data));
  //      });
  //    });
  //  }

  //  aboutToDisappear(): void {
  //    window.getTopWindow((err, data) => {
  //      var windowClass = data;
  //      windowClass.off('keyboardHeightChange');
  //    });
  //  }

  /**
   * 重置
   */
  private setToStart() {
    this.isEdit = false
    this.name = ''
    this.chooseClassify = 'red'
  }

  private getIcon(): Resource {
    switch (this.chooseClassify) {
      case 'red':
        return $r('app.media.ic_folder_filled_red')
      case 'orange':
        return $r('app.media.ic_folder_filled_orange')
      case 'yellow':
        return $r('app.media.ic_folder_filled_yellow')
      case 'green':
        return $r('app.media.ic_folder_filled_green')
      case 'lakeBlue':
        return $r('app.media.ic_folder_filled_lakeBlue')
      case 'lightBlue':
        return $r('app.media.ic_folder_filled_lightBlue')
      case 'darkBlue':
        return $r('app.media.ic_folder_filled_darkBlue')
      case 'purple':
        return $r('app.media.ic_folder_filled_purple')
      default:
        return $r('app.media.ic_folder_filled')
    }
  }

  @Builder classifyRadio($$:{classify: string, classifyColor: Resource, last: boolean}) {
    Column() {
      Stack() {
        Circle({
          height: this.chooseClassify == $$.classify ? '90%' : '75%',
          width: this.chooseClassify == $$.classify ? '90%' : '75%'
        })
          .fill($$.classifyColor)
        Circle({
          height: this.chooseClassify == $$.classify ? '45%' : 0,
          width: this.chooseClassify == $$.classify ? '45%' : 0
        })
          .fill($r('app.color.foreground'))
      }
      .onClick(() => {
        this.chooseClassify = $$.classify
      })
    }
    .justifyContent(FlexAlign.Center)
    .height(this.screenType == 'sm' ? 24 : 36)
    .width(this.screenType == 'sm' ? 24 : 36)

    if ($$.last)
      Column().layoutWeight(1)
  }

  build() {
    Panel(this.showFolderAddPanel) {
      Column() {
        Column() {
          Row() {
            Column() {
              Text(this.isEdit ? $r('app.string.Edit_folder') : $r('app.string.Add_folder'))
                .fontWeight(FontWeight.Medium)
                .fontSize(20)
                .fontColor($r('app.color.text_level1'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column() {
              Button($r('app.string.save'))
                .backgroundColor(this.accentColor)
                .onClick(() => {
                  if (this.name == '') {
                    prompt.showToast({
                      message: (Object)($r('app.string.folderEntryNull')),
                      duration: 2000,
                    });
                  } else {
                    let context: Context = getContext(this) as common.Context
                    if(this.isEdit){
                      editNewFolder(this.folderId, this.chooseClassify, this.name, context)
                    } else {
                      addNewFolder(this.chooseClassify, this.name, context)
                    }
                    this.setToStart()
                    this.showFolderAddPanel = false
                  }
                })
            }.margin({ right: 12 })

            Column() {
              Button() {
                Image($r('app.media.ic_setting_close'))
                  .height(18)
                  .width(18)
              }
              .type(ButtonType.Circle)
              .fontColor(this.accentColor)
              .backgroundColor($r('app.color.divider'))
              .onClick(() => {
                this.setToStart()
                this.showFolderAddPanel = false
              })
              .height(24)
            }
          }
          .height(28)
          .width('100%')
          .margin({ bottom: 16 })

          Column() {
            Row() {
              this.classifyRadio({classify: 'red', classifyColor: $r('app.color.highSaturation_red'), last: true})
              this.classifyRadio({classify: 'orange', classifyColor: $r('app.color.highSaturation_orange'), last: true})
              this.classifyRadio({classify: 'yellow', classifyColor: $r('app.color.highSaturation_yellow'), last: true})
              this.classifyRadio({classify: 'green', classifyColor: $r('app.color.highSaturation_green'), last: true})
              this.classifyRadio({classify: 'lakeBlue', classifyColor: $r('app.color.highSaturation_lakeBlue'), last: true})
              this.classifyRadio({classify: 'lightBlue', classifyColor: $r('app.color.highSaturation_lightBlue'), last: true})
              this.classifyRadio({classify: 'darkBlue', classifyColor: $r('app.color.highSaturation_darkBlue'), last: true})
              this.classifyRadio({classify: 'purple', classifyColor: $r('app.color.highSaturation_purple'), last: false})
            }
            .padding({ right: 4, left: 4 })

            Row() {
              Column() {
                Image(this.getIcon())
                  .height(24)
                  .width(24)
              }
              .justifyContent(FlexAlign.Center)
              .height(40)
              .width(40)
              .backgroundColor($r('app.color.divider'))
              .borderRadius(20)
              .margin({ right: 8 })

              Column() {
                if (this.showFolderAddPanel) {
                  TextInput({ placeholder: $r('app.string.inputFolderName'), text: this.name })
                    .onChange((value: string) => {
                      this.name = value
                    })
                    .caretColor(this.accentColor)
                    .backgroundColor($r('app.color.divider'))
                    .placeholderColor($r('app.color.text_level3'))
                    .fontColor($r('app.color.text_level1'))
                }
              }
              .justifyContent(FlexAlign.Center)
              .height(56)
              .layoutWeight(1)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .onClick(() => {
      })
    }
    .miniHeight(24 + 28 + 16 + 56 + (this.screenType == 'sm' ? 24 : 36))
    .type(PanelType.Minibar)
    .backgroundColor($r('app.color.foreground'))
  }
}