import ThingsResource from '../../model/EventsResourceContact';
import { FolderList_item } from '../element/FolderList';
import FolderResource from '../../model/FolderResourceContact';
import {
  getIsAllCollect,
  setAllCollect,
  getIsAllChecked,
  changeAllChoice,
  getOneCounter,
  isCyclic,
  setAllFolder,
  deleteAll,
} from '../../control/EventsController';
import { get_accent, get_allChoose_on_Marking, get_collect_on_Marking } from '../../control/AccentController';

@CustomDialog
struct FolderCustomDialog {
  controller: CustomDialogController
  @StorageLink('isHidden') isCardHidden: boolean[] = [false, false, false]
  @StorageLink('eventsShowResource') eventsShowResource: ThingsResource[][] = [[]]
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []
  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @Link thisFolder: number
  @State changeFolder: number = this.thisFolder

  private accentColor: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
  }

  private CODE_DISTURBANCE() {
    this.isCardHidden[0] = !this.isCardHidden[0];
    this.isCardHidden[0] = !this.isCardHidden[0];
  }

  //设置所有待办单
  private async setAllFolder(folderId: number) {
    await setAllFolder(folderId)
    this.CODE_DISTURBANCE()
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.pleaseChooseFolder'))
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
        Scroll() {
          Column() {
            FolderList_item({
              thisFolder: $changeFolder,
              showResource: $systemFolderResource
            })

            Column().height(6).width('100%').backgroundColor($r('app.color.background'))

            FolderList_item({
              controller: this.controller,
              thisFolder: $changeFolder,
              showResource: $userFolderResource,
              isShowAdd: true
            })
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(this.userFolderResource.length > 7 ? 1 : 0)

      Row() {
        Button($r('app.string.cancel'))
          .onClick(() => {
            this.controller.close()
          })
          .width('50%')
          .height(40)
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
        Divider()
          .vertical(true)
          .color($r('app.color.divider'))
          .height(40)
        Button($r('app.string.confirm'))
          .onClick(() => {
            this.setAllFolder(this.thisFolder = this.changeFolder)
            this.controller.close()
          })
          .width('50%')
          .height(40)
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
      }
      .padding({ top: 8, bottom: 16 })
      .height(40)
    }
    .padding({ left: 16, right: 16 })
  }
}

@CustomDialog
struct DirectlyDeleteCustomDialog {
  controller1: CustomDialogController
  @StorageLink('isHidden') isCardHidden: boolean[] = [false, false, false]
  @StorageLink('eventsShowResource') eventsShowResource: ThingsResource[][] = [[]]
  private isWhole = false
  private accentColor: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
  }

  private CODE_DISTURBANCE() {
    this.isCardHidden[0] = !this.isCardHidden[0];
    this.isCardHidden[0] = !this.isCardHidden[0];
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.deleteEvent'))
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
        Text($r('app.string.deleteEvent_info'))
          .width('100%')
          .fontSize(16)
          .fontColor($r('app.color.text_level1'))
      }
      .padding({ left: 8, right: 8 })
      .width('100%')

      Row() {
        Button($r('app.string.cancel'))
          .onClick(() => {
            this.controller1.close()
          })
          .width('50%')
          .height(40)
          .backgroundColor('#00000000')
          .fontColor(this.accentColor)
        Divider()
          .vertical(true)
          .color($r('app.color.divider'))
          .height(40)
        Button($r('app.string.delete'))
          .onClick(() => {
            deleteAll(this.isWhole)
            this.CODE_DISTURBANCE()
            this.controller1.close()
          })
          .width('50%')
          .height(40)
          .backgroundColor('#00000000')
          .fontColor($r('app.color.warning'))
      }.padding({ top: 8, bottom: 16 })
    }
    .padding({ left: 16, right: 16 })
  }
}

@CustomDialog
struct DeleteCustomDialog {
  nextOneDialog: CustomDialogController = new CustomDialogController({
    builder: DirectlyDeleteCustomDialog({}),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -12 }
  })
  nextWholeDialog: CustomDialogController = new CustomDialogController({
    builder: DirectlyDeleteCustomDialog({ isWhole: true }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -12 }
  })
  controller: CustomDialogController
  @StorageLink('isHidden') isCardHidden: boolean[] = [false, false, false]
  @StorageLink('eventsShowResource') eventsShowResource: ThingsResource[][] = [[]]

  private accentColor: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
  }

  build() {
    Column() {
      Column() {
        Text($r("app.string.deleteEvent"))
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
        Text($r("app.string.deleteEvent_info2"))
          .width('100%')
          .fontSize(16)
          .fontColor($r('app.color.text_level1'))
      }
      .padding({ left: 8, right: 8 })
      .width('100%')

      Column() {
        Button($r("app.string.deleteEventOnly"))
          .onClick(() => {
            this.controller.close()
            this.nextOneDialog.open()
          })
          .width('100%')
          .height(40)
          .margin({ top: 8 })
          .backgroundColor(this.accentColor)

        Button($r("app.string.deleteEventAll"))
          .onClick(() => {
            this.controller.close()
            this.nextWholeDialog.open()
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
export struct ToolBar {
  /**
   * 当前时间和分类
   */
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0

  /**
   * 完成比率
   */
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0

  /**
   * 展示资源
   */
  @StorageLink('eventsShowResource') eventsShowResource: ThingsResource[][] = [[]]

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //是否隐藏
  @StorageLink('isHidden') isCardHidden: boolean[] = [false, false, false]
  @StorageLink('screenType') screenType: string = ''
  private isHidden: boolean

  private accentColor: Resource
  private ic_allChoose_on_Marking: Resource
  private ic_collect_on_Marking: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
    this.ic_allChoose_on_Marking = get_allChoose_on_Marking()
    this.ic_collect_on_Marking = get_collect_on_Marking()
  }

  private CODE_DISTURBANCE() {
    this.isCardHidden[0] = !this.isCardHidden[0];
    this.isCardHidden[0] = !this.isCardHidden[0];
  }

  private getCounter(): number {
    var ret: number = 0;
    for (let i = 0;i < 3; i++) {
      if (!this.isCardHidden[i]) {
        ret += getOneCounter(i)
      }
    }
    return ret;
  }

  public async barClick(id: number) {
    switch (id) {
      case 0: {
        if (this.getCounter() <= 0) return;
        return
      }
      case 1: {
        if (this.getCounter() <= 0) return;
        if (getIsAllCollect()) {
          await setAllCollect(false);
        }
        else {
          await setAllCollect(true);
        }
        this.CODE_DISTURBANCE()
        return
      }
      case 2: {
        if (this.getCounter() <= 0) return;
        this.thisFolder = this.getFolder();
        this.FolderCustomDialogController.open()
        return
      }
      case 3: {
        if (this.getCounter() <= 0) return;
        if (isCyclic())
          this.DeleteCustomDialogController.open()
        else
          this.DirectlyDeleteCustomDialogController.open()
        return
      }
      case 4: {
        if (getIsAllChecked()) {
          changeAllChoice(false);
        }
        else {
          changeAllChoice(true);
        }
        this.CODE_DISTURBANCE()
        return
      }
    }
  }

  @Builder BarIcon(icon: Resource) {
    Image(icon)
      .width(24)
      .height(24)
  }

  @Builder BarTextBut(text: Resource, color: Resource) {
    Text(text)
      .size({ width: '100%', height: 14 })
      .textAlign(TextAlign.Center)
      .fontColor(color)
      .fontSize(10)
      .fontWeight('Medium')
      .margin({ top: 4 })
  }

  @Styles Item() {
    .layoutWeight(1)
    .height("100%")
    .padding({ top: 7 })
  }

  //当前选择事项的待办单ID
  @State thisFolder: number = -5
  FolderCustomDialogController: CustomDialogController = new CustomDialogController({
    builder: FolderCustomDialog({
      thisFolder: $thisFolder
    }),
  })

  /**
   * 获取当前选择事项的待办单ID
   */
  private getFolder(): number {
    var ret: number = -5
    for (let i = 0;i < 3; i++) {
      if (!this.isCardHidden[i]) {
        for (let j = 0;j < this.eventsShowResource[i].length; j++) {
          if (this.eventsShowResource[i][j].isChecked) {
            if (ret != -5 && ret != this.eventsShowResource[i][j].folderId)
              return -5
            ret = this.eventsShowResource[i][j].folderId
          }
        }
      }
    }
    return ret
  }

  /*-------------------------------------------------------------------------------------------------------------------*/

  DeleteCustomDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteCustomDialog({}),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -12 }
  })
  DirectlyDeleteCustomDialogController: CustomDialogController = new CustomDialogController({
    builder: DirectlyDeleteCustomDialog({}),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -12 }
  })

  build() {
    Column() {
      Row() {

        //        Column() {
        //          this.BarIcon(
        //              this.getCounter() > 0 ?
        //            $r('app.media.ic_choose_share_off') :
        //            $r('app.media.ic_choose_share_disabled')
        //          )
        //          this.BarTextBut($r('app.string.share'),
        //              this.getCounter() > 0 ?
        //            $r('app.color.text_level1') :
        //            $r('app.color.text_level3')
        //          )
        //        }
        //        .Item()
        //        .onClick(this.barClick.bind(this, 0))

        Column() {
          this.BarIcon(
              this.getCounter() > 0 ? (getIsAllCollect() ? this.ic_collect_on_Marking : $r('app.media.ic_collect')) : $r('app.media.ic_choose_collect_disabled')
          )
          this.BarTextBut(
              (getIsAllCollect() && this.getCounter() > 0) ? $r('app.string.cancelCollect') : $r('app.string.collect'),
              this.getCounter() > 0 ? (getIsAllCollect() ? this.accentColor : $r('app.color.text_level1')) : $r('app.color.text_level3')
          )
        }
        .Item()
        .onClick(this.barClick.bind(this, 1))

        Column() {
          this.BarIcon(
              this.getCounter() > 0 ?
            $r('app.media.ic_choose_move_off') :
            $r('app.media.ic_choose_move_disabled')
          )
          this.BarTextBut($r('app.string.move'),
              this.getCounter() > 0 ?
            $r('app.color.text_level1') :
            $r('app.color.text_level3')
          )
        }
        .Item()
        .onClick(this.barClick.bind(this, 2))

        Column() {
          this.BarIcon(
              this.getCounter() > 0 ?
            $r('app.media.ic_choose_delete_off') :
            $r('app.media.ic_choose_delete_disabled')
          )
          this.BarTextBut($r('app.string.delete'),
              this.getCounter() > 0 ?
            $r('app.color.text_level1') :
            $r('app.color.text_level3')
          )
        }
        .Item()
        .onClick(this.barClick.bind(this, 3))

        Column() {
          this.BarIcon(getIsAllChecked() ?
            this.ic_allChoose_on_Marking :
          $r('app.media.ic_choose_allChoose_off'))
          this.BarTextBut(
            getIsAllChecked() ? $r('app.string.cancelAllChoose') : $r('app.string.allChoose'),
            getIsAllChecked() ? this.accentColor : $r('app.color.text_level1')
          )
        }
        .Item()
        .onClick(this.barClick.bind(this, 4))
      }
      .width('100%')
      .height(54)
      .backgroundColor($r('app.color.bar'))
      .padding({ left: this.screenType == 'sm' ? 12 : 24, right: this.screenType == 'sm' ? 12 : 24 })
      .offset({ x: 0, y: this.isHidden ? 54 : 0 })
      .animation({
        duration: 200, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
        delay: 0, // 动画延迟
        iterations: 1, // 播放次数
      })
    }
    .height(this.isHidden ? 0 : 54)
  }
}