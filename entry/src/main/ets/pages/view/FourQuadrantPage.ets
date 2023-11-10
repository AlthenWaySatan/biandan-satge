import { TitleTwo, TitleOne, EditTitleOne } from '../element/Title';
import { SiderFolder } from '../element/SiderFolder';
import { FourQuadrant } from '../element/FourQuadrant';
import FolderResource from '../../model/FolderResourceContact';
import { AddEventButton } from '../element/AddEventButton';
import { ToolBar } from '../element/ToolBar';

@Component
export struct FourQuadrantPage {
  @StorageLink('selectPos') selectPos: number = 2;

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //当前日期和待办单
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('showEventAddPanel') showEventAddPanel: boolean = false

  //屏幕类型
  @StorageLink('screenType') screenType: string = ''

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
        if (this.selectPos == 2)
          FourQuadrant({})
      }
      .padding({ bottom: 12 })
      .height('100%')
      .width('100%')
    }
    .visibility(this.selectPos == 2 ? Visibility.Visible : Visibility.None)
    .opacity(this.selectPos == 2 ? 1 : 0)
    .animation({
      delay: 0,
      duration: 200, // 动画时长
      curve: Curve.EaseInOut, // 动画曲线
    })
  }
}