import { TitleTwo, TitleOne, EditTitleOne } from '../element/Title';
import { DaraField } from '../element/DataField';
import { SiderFolder } from '../element/SiderFolder';
import { EventsTable } from '../element/EventsTable';
import { ToolBar } from '../element/ToolBar';
import FolderResource from '../../model/FolderResourceContact';
import { AddEventButton } from '../element/AddEventButton';

@Component
export struct TodoPage {
  @StorageLink('selectPos') selectPos: number = 0;

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //当前日期和待办单
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''
  //状态栏高度

  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  build() {
    Column() {
      Column() {
        DaraField()
      }
      .margin({ bottom: 12 })

      Column() {
        // if (this.selectPos == 0)
        Column() {
          EventsTable({})
        }
        .height('100%')
        .width('100%')
      }
      .layoutWeight(1)
    }
    .visibility(this.selectPos == 0 ? Visibility.Visible : Visibility.None)
    .opacity(this.selectPos == 0 ? 1 : 0)
    .animation({
      delay: 0,
      duration: 200, // 动画时长
      curve: Curve.EaseInOut, // 动画曲线
    })
  }
}