import { TitleTwo, TitleOne, EditTitleOne } from '../element/Title';
import { DaraField } from '../element/DataField';
import { SiderFolder } from '../element/SiderFolder';
import { EventsTable } from '../element/EventsTable';
import { ToolBar } from '../element/ToolBar';
import FolderResource from '../../model/FolderResourceContact';
import { AddEventButton } from '../element/AddEventButton';

@Component
export struct TodoPage {

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //当前日期和待办单
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  //状态栏高度
  private statusBarHeightVp: number
  //今日日期
  private todayDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]

  /**
   * 获取日期
   */
  private getShowDate(): any {
    if (this.todayDate[0] == this.showDate[0]) {
      if (this.todayDate[1] == this.showDate[1] && this.todayDate[2] == this.showDate[2])
        return $r('app.string.Today');
      else
        return this.showDate[1] + '月' + this.showDate[2] + '日';
    }
    else
      return this.showDate[0] + '年' + this.showDate[1] + '月' + this.showDate[2] + '日';
  }

  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  /**
   * 获取当前待办单标题
   */
  private getFolderTitle(): any {
    if (this.folderId <= 0)
      return this.systemFolderResource[-this.folderId].title;
    else {
      let id = this.userFolderResource.findIndex((item) => item.id == this.folderId)
      return this.userFolderResource[id].title;
    }
  }

  build() {
    Column() {
      Row() {
        if (this.screenType == 'lg') {
          SiderFolder({
            statusBarHeightVp: this.statusBarHeightVp,
          })
        }
        Column() {
          //标题
          if (this.isEdit) {
            EditTitleOne({
              columnNum: this.screenType == 'sm' ? 4 : 8,
              offsetNum: this.screenType == 'sm' ? 0 : 1
            })
          } else {
            if (this.screenType == 'sm') {
              TitleTwo({
                mainTitle: this.getShowDate(),
                subTitle: this.getFolderTitle(),
                columnNum: 4,
                offsetNum: 0
              })
            } else if (this.screenType == 'md') {
              TitleTwo({
                mainTitle: this.getShowDate(),
                subTitle: this.getFolderTitle(),
                columnNum: 8,
                offsetNum: 1
              })
            } else {
              TitleOne({
                showDate: $showDate,
                mainTitle: this.getShowDate(),
                columnNum: 8,
                offsetNum: 1
              })
            }
          }

          //数据区
          if (this.screenType == 'sm') {
            DaraField({
              columnNum: 4,
              offsetNum: 0
            })
          } else {
            DaraField({
              columnNum: 8,
              offsetNum: 1
            })
          }

          //列表展示区
          GridContainer({ columns: this.screenType == 'sm' ? 4 : 8, gutter: 12, margin: 12 }) {
            Column() {
              Stack() {
                Column() {
                  EventsTable({})
                }
                .height('100%')
                .width('100%')

                AddEventButton()
              }
              .width('100%')
              .height('100%')
              .alignContent(Alignment.BottomEnd)
            }
            .useSizeType({
              xs: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
              sm: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
              md: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
              lg: { span: this.screenType == 'sm' ? 4 : 6, offset: this.screenType == 'sm' ? 0 : 1 },
            })
            .margin({ top: 12 })
          }
          .layoutWeight(1)

          ToolBar({
            isHidden: !this.isEdit,
          })
        }
        .width((this.screenType == 'lg' ? '60%' : '100%'))
        .margin({ top: this.statusBarHeightVp })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}