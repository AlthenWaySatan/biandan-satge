import prompt from '@ohos.prompt'
import FolderResource from '../../model/FolderResourceContact';
import EventResource from '../../model/EventsResourceContact';
import { getResource } from '../../control/EventsController';
import { get_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';

@Component
export struct TitleTwo {
  @Link mainTitle: string;
  @State subTitle: string = '全部待办';
  private columnNum: number
  private offsetNum: number
  private changeDate: number[]
  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []

  //当前日期和待办单
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  private todayDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]

  /**
   * 获取日期
   */
  private getShowDate() {
    if (this.todayDate[0] == this.showDate[0]) {
      if (this.todayDate[1] == this.showDate[1] && this.todayDate[2] == this.showDate[2])
        return '今天';
      else
        return this.showDate[1] + '月' + this.showDate[2] + '日';
    }
    else
      return this.showDate[0] + '年' + this.showDate[1] + '月' + this.showDate[2] + '日';
  }

  /**
   * 获取当前待办单标题
   */
  private getFolderTitle() {
    if (this.folderId <= 0)
      return this.systemFolderResource[-this.folderId].title;
    else {
      let id = this.userFolderResource.findIndex((item) => item.id == this.folderId)
      return this.userFolderResource[id].title;
    }
  }

  private accentColor: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  private changeFolder(NewFolder: number): void {
    this.folderId = NewFolder
    this.subTitle = this.getFolderTitle()
    let context: Context = getContext(this) as common.Context
    getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context)
    console.info('Click: ' + NewFolder.toString())
  }

  @Builder FoldrMenu() {
    Column() {
      ForEach(this.systemFolderResource, (item: FolderResource) => {
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
                .margin({ left: 8 })
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
          .height(47)

          if (item.id != -3)
            Divider().width('100%').color($r('app.color.divider'))
        }
        .onTouch(() => this.changeFolder(item.id))
        .padding({ left: 12, right: 12 })
      })
      Column().height(6).width('100%').backgroundColor($r('app.color.background'))
      ForEach(this.userFolderResource, (item: FolderResource) => {
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
                .margin({ left: 8 })
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
          .height(47)

          Divider().width('100%').color($r('app.color.divider'))
        }
        .onTouch(() => this.changeFolder(item.id))
        .padding({ left: 12, right: 12 })
      })
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
              .margin({ left: 8 })
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
        .height(47)
      }
      .onTouch(() => {
        this.showFolderAddPanel = true
      })
      .padding({ left: 12, right: 12 })
    }
    .width(240)
  }

  @State isLunar: boolean = false

  @Builder DateMenu() {
    Column() {
      Column() {
        DatePicker({
          selected: new Date(this.showDate[0], this.showDate[1] - 1 , this.showDate[2])
        })
          .lunar(this.isLunar)
          .onChange((value: DatePickerResult) => {
            this.changeDate = [value.year, value.month + 1, value.day]
            console.info('select this.changeDate is: ', this.changeDate)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(240)
      .height(200)

      Row() {
        Column() {
          Button($r('app.string.Today'))
            .onTouch(() => {
              this.showDate = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
              console.info('select this.showDate is: ', this.showDate)
              this.mainTitle = this.getShowDate();
              let context: Context = getContext(this) as common.Context
              getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
            })
            .fontColor(this.accentColor)
            .backgroundColor('#00000000')
            .width('100%')
            .height('100%')
        }
        .padding({ right: 6 })
        .width(108)
        .height(40)

        Divider().vertical(true).color($r('app.color.divider'))
        Column() {
          Button($r('app.string.confirm'))
            .onTouch(() => {
              this.showDate = this.changeDate
              console.info('select this.showDate is: ', this.showDate)
              this.mainTitle = this.getShowDate();
              let context: Context = getContext(this) as common.Context
              getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
            })
            .fontColor(this.accentColor)
            .backgroundColor('#00000000')
            .width('100%')
            .height('100%')
        }
        .padding({ left: 6 })
        .width(108)
        .height(40)
      }
      .padding(12)
      .width(240)
      .height(44)
    }
    .justifyContent(FlexAlign.Start)
    .width(240)
    .height(244)
  }

  build() {
    GridContainer({ columns: this.columnNum, margin: 12 }) {
      Column() {
        Row() {
          Text(this.mainTitle)
            .fontSize(30)
            .fontColor($r('app.color.text_level1'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
          Image($r('app.media.ic_spinner_level1'))
            .width(24)
            .height(24)
        }
        .bindMenu(this.DateMenu())
        .height(41)

        Row() {
          Text(this.subTitle)
            .fontSize(14)
            .fontColor($r('app.color.text_level2'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
          Image($r('app.media.ic_spinner_level2'))
            .width(24)
            .height(24)
        }
        .bindMenu(this.FoldrMenu())
        .margin({ top: 4 })
        .height(19)
      }
      .padding({ left: 12, right: 12, top: 6 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height(82)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}

@Component
export struct TitleOne {
  @Link mainTitle: string;
  private columnNum: number
  private offsetNum: number
  @Link showDate: number[]
  @State isLunar: boolean = false
  private changeDate: number[]
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0
  @StorageLink('folderId') folderId: number = 0

  /**
   * 获取日期
   */
  private todayDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  private getShowDate() {
    if (this.todayDate[0] == this.showDate[0]) {
      if (this.todayDate[1] == this.showDate[1] && this.todayDate[2] == this.showDate[2])
        return '今天';
      else
        return this.showDate[1] + '月' + this.showDate[2] + '日';
    }
    else
      return this.showDate[0] + '年' + this.showDate[1] + '月' + this.showDate[2] + '日';
  }

  private accentColor: Resource
  aboutToAppear() {
    this.accentColor = get_accent()
  }

  @Builder DateMenu() {
    Column() {
      Column() {
        DatePicker({
          selected: new Date(this.showDate[0], this.showDate[1] - 1 , this.showDate[2])
        })
          .lunar(this.isLunar)
          .onChange((value: DatePickerResult) => {
            this.changeDate = [value.year, value.month + 1, value.day]
            console.info('select current date is: ' + value.year)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(280)
      .height(160)

      Row() {
        Column() {
          Button($r('app.string.Today'))
            .onTouch(() => {
              this.showDate = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
              this.mainTitle = this.getShowDate();
              let context: Context = getContext(this) as common.Context
              getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
            })
            .fontColor(this.accentColor)
            .backgroundColor('#00000000')
            .width('100%')
            .height('100%')
        }
        .padding({ right: 6 })
        .width(128)
        .height(40)

        Divider().vertical(true).color($r('app.color.divider'))
        Column() {
          Button($r('app.string.confirm'))
            .onTouch(() => {
              this.showDate = this.changeDate
              this.mainTitle = this.getShowDate();
              let context: Context = getContext(this) as common.Context
              getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
            })
            .fontColor(this.accentColor)
            .backgroundColor('#00000000')
            .width('100%')
            .height('100%')
        }
        .padding({ left: 6 })
        .width(128)
        .height(40)
      }
      .padding(12)
      .width(280)
      .height(44)
    }
    .justifyContent(FlexAlign.Start)
    .width(280)
    .height(204)
  }

  build() {
    GridContainer({ columns: this.columnNum, margin: 12 }) {
      Column() {
        Row() {
          Text(this.mainTitle)
            .fontSize(30)
            .fontColor($r('app.color.text_level1'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
          Image($r('app.media.ic_spinner_level1'))
            .width(24)
            .height(24)
        }
        .padding({ left: 12, right: 12 })
        .height(41)
      }
      .bindMenu(this.DateMenu())
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height(56)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}

@Component
export struct TitleOne_large {
  @State mainTitle: Resource = $r('app.string.Today')
  private columnNum: number
  private offsetNum: number

  build() {
    GridContainer({ columns: this.columnNum }) {
      Column() {
        Row() {
          Text(this.mainTitle)
            .fontSize(30)
            .fontColor($r('app.color.text_level1'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .height(41)
      }
      .padding({ top: 6 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height(56)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}

@Component
export struct TitleOne_middle {
  @State mainTitle: Resource = $r('app.string.Today')
  private columnNum: number
  private offsetNum: number

  build() {
    GridContainer({ columns: this.columnNum }) {
      Column() {
        Row() {
          Text(this.mainTitle)
            .fontSize(24)
            .fontColor($r('app.color.text_level1'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .height(33)
      }
      .padding({ top: 12 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height(56)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}

@Component
export struct TitleOne_small {
  @Link rotateAngle: number
  private mainTitle: string | Resource
  private offHeight: number = 0

  build() {
    Column() {
      Row() {
        Text(this.mainTitle)
          .fontSize(16)
          .fontColor($r('app.color.text_level1'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
        Image($r('app.media.ic_spinner_level1'))
          .width(24)
          .height(24)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.rotateAngle
          })
          .animation({
            duration: 200, // 动画时长
            curve: Curve.EaseOut, // 动画曲线
            delay: 0, // 动画延迟
            iterations: 1, // 播放次数
          })
      }
      .width('100%')
      .height(22)
    }
    .padding({ top: 16 + this.offHeight, left: 12, right: 12 })
    .alignItems(HorizontalAlign.Start)
    .height(48 + this.offHeight)
  }
}

@Component
export struct EditTitleOne {
  //显示资源
  @StorageLink('eventsShowResource') eventsShowResource: string = JSON.stringify([[], [], []])

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //已完成数目和待完成数目
  @StorageLink('doneNum') doneNum: number = 0
  @StorageLink('todoNum') todoNum: number = 0

  //当前日期和待办单
  @StorageLink('showDate') showDate: number[] = []
  @StorageLink('folderId') folderId: number = 0

  //是否隐藏
  @StorageLink('isHidden') isCardHidden: boolean[] = [false, false, false]
  private columnNum: number
  private offsetNum: number

  /**
   * 修改所有的的待办
   * @param value 是否被选择
   */
  private changeAllChoice(value: boolean): void {
    let temp = JSON.parse(this.eventsShowResource);
    for (var i = 0; i < 3; i++) {
      for (var j = 0;j < temp[i].length; j++) {
        temp[i][j].isChecked = value;
      }
    }
    this.eventsShowResource = JSON.stringify(temp);
  }

  /**
   * 退出编辑模式
   */
  private quitEdit() {
    this.isEdit = false
    this.changeAllChoice(false)
  }

  /**
   * 获取选择数
   * @param id 卡片ID
   */
  private getOneCounter(id: number): number {
    var ret: number = 0;
    let temp = JSON.parse(this.eventsShowResource);
    for (var i = 0;i < temp[id].length; i++) {
      if (temp[id][i].isChecked)
        ret++;
    }
    return ret;
  }

  /**
   * 获取选择总数
   */
  private getCounter(): number {
    var ret: number = 0;
    for (var i = 0;i < 3; i++) {
      if (!this.isCardHidden[i])
        ret += this.getOneCounter(i);
    }
    return ret;
  }

  @Builder SquareText($$:{label: string | Resource}) {
    Text($$.label)
      .fontSize(30)
      .fontColor($r('app.color.text_level1'))
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Center)
  }

  build() {
    GridContainer({ columns: this.columnNum, margin: 12 }) {
      Column() {
        Row() {
          Image($r('app.media.ic_setting_close'))
            .width(30)
            .height(30)
            .onClick(() => this.quitEdit())
          Row() {
            this.SquareText({label: $r('app.string.editTitle', this.getCounter().toString())})
          }
          .margin({ left: 18 })
        }
        .padding({ left: 12, right: 12 })
        .height(41)
      }
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height(56)
      .useSizeType({
        xs: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        sm: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        md: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
        lg: { span: this.columnNum - 2 * this.offsetNum, offset: this.offsetNum },
      })
    }
  }
}