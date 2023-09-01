import { TitleTwo, TitleOne, EditTitleOne } from '../element/Title';
import { CalendarMonth } from '../element/CalendarMonth';
import { SiderFolder } from '../element/SiderFolder';
import { EventsTable } from '../element/EventsTable';
import { ToolBar } from '../element/ToolBar';
import FolderResource from '../../model/FolderResourceContact';

@Component
export struct CalendarPage {

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
  @StorageLink('openCalendar') openCalendar: boolean = false

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
              columnNum: 4,
              offsetNum: 0
            })
          } else {
            if (this.screenType == 'lg') {
              TitleOne({
                showDate: $showDate,
                mainTitle: this.getShowDate(),
                columnNum: 4,
                offsetNum: 0
              })
            } else {
              TitleTwo({
                mainTitle: this.getShowDate(),
                subTitle: this.getFolderTitle(),
                columnNum: 4,
                offsetNum: 0
              })
            }
          }

          //数据区
          Column() {
            CalendarMonth({})
          }
          .width('100%')
          .layoutWeight(1)
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