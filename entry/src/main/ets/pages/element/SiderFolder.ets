import { TitleOne_middle } from './Title';
import { FolderList } from './FolderList';
import FolderResource from '../../model/FolderResourceContact';
import { changeAllChoice } from '../../control/EventsController';

@Component
export struct SiderFolder {
  private statusBarHeightVp: number = 0
  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('isEdit') isEdit: boolean = false

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  build() {
    Stack(){
      Row() {
        Column() {
          Column() {
            TitleOne_middle({
              mainTitle: $r('app.string.Todo_folder'),
              columnNum: 4,
              offsetNum: 0
            })

            Column() {
              Column() {
                FolderList({
                  showResource: $systemFolderResource
                })
              }
              .padding({ left: 12, right: 12 })
              .height(224)
              .Card()
            }
            .padding({ left: 12, right: 12 })

            Column() {
              Column() {
                Scroll() {
                  Column() {
                    FolderList({
                      showResource: $userFolderResource,
                      isShowAdd: true
                    })
                  }
                  .padding({ left: 12, right: 12 })
                }
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Off)
              }
              .Card()
            }
            .width('100%')
            .layoutWeight(1)
            .padding(12)
          }
          .height('100%')
          .width('100%')
        }
        .height('100%')
        .width('100%')
        .padding({ top: this.statusBarHeightVp })

        //分隔器
        Column().height('100%').width(1).backgroundColor($r('app.color.divider'))
      }
      .height('100%')
      .width('100%')

      if(this.isEdit){
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(()=>{
            this.isEdit = false
            changeAllChoice(false)
          })
      }
    }
    .height('100%')
    .width('40%')
  }
}