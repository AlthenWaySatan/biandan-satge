import prompt from '@ohos.promptAction'
import FolderResource from '../../model/FolderResourceContact';
import { createEvent, editThisEvent } from '../../control/EventsController';
import CreateResource from '../../model/CreateResourceContact';
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';
import { getFolderClassify, getFolderIcon } from '../../control/FolderController';

PersistentStorage.PersistProp('FirstDayOfWeek', 0)
PersistentStorage.PersistProp('DefaultTimeFormat', 0)
PersistentStorage.PersistProp('DefaultClockTime', [10, 30])
PersistentStorage.PersistProp('DefaultUrgentTime', [22, 0])
PersistentStorage.PersistProp('DefineCycleLength', 90)

@Component
export struct EventAddPanel {
  @StorageLink('FirstDayOfWeek') FirstDayOfWeek: number = 0
  @StorageLink('DefaultTimeFormat') DefaultTimeFormat: number = 0
  @StorageLink('DefaultClockTime') DefaultClockTime: [number, number] = [10, 30]
  @StorageLink('DefaultUrgentTime') DefaultUrgentTime: [number, number] = [22, 0]
  @StorageLink('showEventAddPanel') @Watch('setToStart') showEventAddPanel: boolean = false
  @StorageLink('systemFolderResource') systemFolderResource: FolderResource[] = []
  @StorageLink('userFolderResource') userFolderResource: FolderResource[] = []
  @StorageLink('showFolderAddPanel') showFolderAddPanel: boolean = false
  @StorageLink('DefineCycleLength') DefineCycleLength: number = 90 //默认重复时间长度
  @StorageLink('screenType') screenType: string = 'sm' //屏幕类型

  @StorageLink('editEvent') editEvent: boolean = false
  @StorageLink('thisEvent') thisEvent: CreateResource = new CreateResource(
  this.getNextNDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), this.DefineCycleLength)
  )
  @State folderIcon: Resource = $r('app.media.ic_folder_filled') //当前文件夹图标

  @State mode: PanelMode = PanelMode.Mini //当前面板类型
  @State isLargeComment: boolean = false //是否显示长备注
  @State isShowMore: boolean[] = [false, false, false, false] //是否显示更多
  private tempDate: number[] = [1, 1] //临时日期变量
  @State isLongDate: boolean = false //是否长日期
  @State @Watch('youChangedCycle') changedCycle: boolean = false //是否修改了重复内容

  private accentColor: Resource
  private translucentSaturationAccentColor: Resource

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
    this.translucentSaturationAccentColor = get_translucentSaturation_accent()
    this.setToStart()
  }

  private youChangedCycle() {
    console.log('changedCycle: ' + this.changedCycle);
  }

  private CODE_DISTURBANCE() {
    this.isShowMore[3] = !this.isShowMore[3]
    this.isShowMore[3] = !this.isShowMore[3]
  }

  /**
   * 重置
   */
  private setToStart() {
    if (!this.showEventAddPanel) return
    console.log('aboutToAppear , isEdit: ' + this.editEvent);
    this.isLongDate = false

    this.mode = PanelMode.Mini

    this.isLargeComment = false
    this.isShowMore = [false, false, false, false]

    this.tempDate = [1, 1]

    if (this.editEvent) {
      if (this.thisEvent.thisFolderId > 0) {
        let folderClassify = getFolderClassify(this.thisEvent.thisFolderId)
        this.folderIcon = getFolderIcon(folderClassify)
      } else {
        this.folderIcon = $r('app.media.ic_folder_filled')
      }
    } else {
      this.folderIcon = $r('app.media.ic_folder_filled')

      console.log('DefineCycleLength, ' + this.getNextNDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), this.DefineCycleLength))
      this.thisEvent = new CreateResource(
      this.getNextNDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), this.DefineCycleLength)
      )

      if (this.folderId > 0) {
        this.thisEvent.thisFolderId = this.folderId
        let folderClassify = getFolderClassify(this.folderId)
        this.folderIcon = getFolderIcon(folderClassify)
      } else if (this.folderId == -2) {
        this.thisEvent.isCollect = true
      } else if (this.folderId == -3) {
        this.thisEvent.isImportant = true
      }

      this.thisEvent.setDate(this.showDate[0], this.showDate[1], this.showDate[2], this.DefineCycleLength)

      if (this.selectPos == 2) {
        if (this.isQuadrantImportant)
          this.thisEvent.isImportant = true
        if (this.isQuadrantUrgent) {
          this.thisEvent.validEndTime[3] = this.DefaultUrgentTime[0],
          this.thisEvent.validEndTime[4] = this.DefaultUrgentTime[1]
        }
      }
    }
    if (this.thisEvent.cycleState != 0) {
      this.thisEvent.clockTime[0] = this.thisEvent.thisDate[0],
      this.thisEvent.clockTime[1] = this.thisEvent.thisDate[1],
      this.thisEvent.clockTime[2] = this.thisEvent.thisDate[2]
      this.thisEvent.validEndTime[0] = this.thisEvent.thisDate[0],
      this.thisEvent.validEndTime[1] = this.thisEvent.thisDate[1],
      this.thisEvent.validEndTime[2] = this.thisEvent.thisDate[2]
    }
    this.CODE_DISTURBANCE()
  }

  /**
   * 改变文件夹
   * @param NewFolder 新文件夹ID
   * @param NewIcon 新文件夹图标
   */
  private changeFolder(NewFolder: number, NewClassify: string, NewIcon: Resource): void {
    this.thisEvent.thisFolderId = NewFolder
    this.folderIcon = NewIcon
    console.info('Click: ' + this.thisEvent.thisFolderId + ' ' + this.folderIcon)
  }

  /**
   * 收藏夹菜单
   */
  @Builder FoldrMenu() {
    Column() {
      Column() {
        Row() {
          Row() {
            Image(this.systemFolderResource[1].icon)
              .width(24)
              .height(24)
            Text(this.systemFolderResource[1].title)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.thisEvent.thisFolderId == this.systemFolderResource[1].id ? this.accentColor : $r('app.color.text_level1'))
              .fontSize(16)
              .margin({ left: 8 })
              .maxLines(1)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
          }
          .width('80%')

          // Row() {
          //   Text(this.systemFolderResource[1].counter.toString())
          //     .fontWeight(FontWeight.Medium)
          //     .fontColor($r('app.color.text_level2'))
          //     .fontSize(14)
          // }
          // .justifyContent(FlexAlign.End)
          // .width('20%')
        }
        .width('100%')
        .height(47)
      }
      .onTouch(() => this.changeFolder(this.systemFolderResource[1].id, this.systemFolderResource[1].classify, this.systemFolderResource[1].icon))
      .padding({ left: 12, right: 12 })

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
                .fontColor(this.thisEvent.thisFolderId == item.id ? this.accentColor : $r('app.color.text_level1'))
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
        .onTouch(() => this.changeFolder(item.id, item.classify, item.icon))
        .padding({ left: 12, right: 12 })
      }, (item: FolderResource) => item.toString())

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
  }

  /**
   * 日期选择菜单
   */
  @Builder DateMenu() {
    Column() {
      Column() {
        DatePicker({
          selected: new Date(this.thisEvent.thisDate[0] + '-' + this.thisEvent.thisDate[1] + '-' + this.thisEvent.thisDate[2])
        })
          .onChange((value: DatePickerResult) => {
            this.thisEvent.setDate(value.year, value.month + 1, value.day, this.DefineCycleLength)
            this.CODE_DISTURBANCE()
            console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 比较日期
   * @param date 日期数组
   */
  private isTheDay(date: number[]): boolean {
    if (this.thisEvent.thisDate[0] != date[0])
      return false
    if (this.thisEvent.thisDate[1] != date[1])
      return false
    if (this.thisEvent.thisDate[2] != date[2])
      return false
    return true
  }

  /**
   * 获取下一天
   * @param year 年
   * @param month 月
   * @param day 日
   */
  private getNextDay(year: number, month: number, day: number): number[] {
    var dateTime = new Date(year, month - 1, day);
    dateTime = new Date(dateTime.setDate(dateTime.getDate() + 1));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  /**
   * 获取下n天
   * @param year 年
   * @param month 月
   * @param day 日
   * @param n 之后的n天数
   */
  private getNextNDay(year: number, month: number, day: number, n: number): number[] {
    var dateTime = new Date(year, month - 1, day);
    dateTime = new Date(dateTime.setDate(dateTime.getDate() + n));
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  }

  @Builder listItem(icon: Resource, title: string | Resource, description: string | Resource, isShowMore: boolean, showDivider: boolean = true) {
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

          Image($r('app.media.ic_spinner_level2'))
            .width(24)
            .height(24)
            .margin({ left: 4 })
            .rotate({
              x: 0, y: 0, z: 1,
              angle: isShowMore ? 0 : -90
            })
            .animation({
              duration: 200, // 动画时长
              curve: Curve.EaseOut, // 动画曲线
              delay: 0, // 动画延迟
              iterations: 1, // 播放次数
            })
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

  @Builder listItem_little(title: string | Resource, description: string | Resource, isShow: boolean, showDivider: boolean = true) {
    Column() {
      Row() {
        if (isShow)
        Row() {
          Column()
            .height(24)
            .width(24)
          Text(title)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_level2'))
            .fontSize(16)
            .margin({ left: 16 })
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
        }
        .width('50%')

        if (isShow)
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

          Image($r('app.media.ic_arrow_right'))
            .width(24)
            .height(24)
            .margin({ left: 4 })
        }
        .justifyContent(FlexAlign.End)
        .width('50%')
      }
      .width('100%')
      .height(isShow ? 48 : 0)
      .animation({
        duration: 200, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
        delay: 0, // 动画延迟
        iterations: 1, // 播放次数
      })

      if (showDivider && isShow) {
        Column() {
          Divider().width('100%').color($r('app.color.divider'))
        }.padding({ left: 40 })
      }
    }
  }

  /**
   * 获取日期和时间
   */
  private getTimeInfo(showTime: number[], isShowDate: boolean = true): string | Resource {
    var ret = ''
    if (isShowDate) {
      if (showTime[0] != this.thisEvent.thisDate[0]) {
        ret = ret + showTime[0] + '年' + showTime[1] + '月' + showTime[2] + '日'
      }
      else if (showTime[1] != this.thisEvent.thisDate[1] || showTime[2] != this.thisEvent.thisDate[2]) {
        ret = ret + showTime[1] + '月' + showTime[2] + '日'
      }
    }
    if (this.DefaultTimeFormat == 0) {
      return ret + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    } else {
      if (showTime[3] < 12)
        return ret + '上午' + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
      else if (showTime[3] == 12)
        return ret + '下午' + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
      else
        return ret + '下午' + ((showTime[3] - 12) < 10 ? '0' : '') + (showTime[3] - 12) + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    }
  }

  /*-------------------------------------------------------提醒--------------------------------------------------------*/

  private clockStateRes: Resource[] = [$r('app.string.noClock'), $r('app.string.beforeStartClock'), $r('app.string.fixedTimeClock')]

  /**
   * 重复模式选择菜单
   */
  @Builder clockStateMenu() {
    Column() {
      Column() {
        ForEach(this.clockStateRes, (item: string, index: number) => {
          Column() {
            Column() {
              Text(item)
                .fontColor($r('app.color.text_level1'))
                .fontSize(14)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ bottom: 12, top: 12 })
            .onTouch(() => {
              this.thisEvent.clockState = index
              if (index == 2) {
                this.thisEvent.clockTime = [this.thisEvent.thisDate[0], this.thisEvent.thisDate[1], this.thisEvent.thisDate[2], this.DefaultClockTime[0], this.DefaultClockTime[1]]
              }
            })

            if (index != this.clockStateRes.length - 1)
              Divider().color($r('app.color.divider'))
          }
          .width('100%')

        })
      }
      .padding({ left: 12, right: 12 })
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 提前时间提醒选择菜单
   */
  @Builder clockTimeLongMenu() {
    Column() {
      Column() {
        TimePicker({
          selected: new Date(1919, 8, 10, this.thisEvent.clockTimeLong[0], this.thisEvent.clockTimeLong[1])
        })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .onChange((value: TimePickerResult) => {
            if (this.thisEvent.validStartTime[3] < value.hour || (this.thisEvent.validStartTime[3] == value.hour && this.thisEvent.validStartTime[4] < value.minute)) {
              prompt.showToast({
                message: (Object)($r('app.string.clockCantBeEarlier')),
                duration: 500,
              });
            } else {
              this.thisEvent.clockTimeLong = [value.hour, value.minute]
              console.info('select current Time is: ' + value.hour + '-' + value.minute)
            }
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 固定时间提醒选择菜单
   */
  @Builder clockTimeMenu() {
    Column() {
      if (this.thisEvent.cycleState == 0) {
        Column() {
          DatePicker({
            selected: new Date(this.thisEvent.clockTime[0], this.thisEvent.clockTime[1] - 1, this.thisEvent.clockTime[2], this.thisEvent.clockTime[3], this.thisEvent.clockTime[4])
          })
            .onChange((value: DatePickerResult) => {
              this.thisEvent.clockTime = [value.year, value.month + 1, value.day, this.thisEvent.clockTime[3], this.thisEvent.clockTime[4]]
              console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
            })
            .width('100%')
            .height('100%')
        }
        .padding(12)
        .width(this.screenType == 'lg' ? 280 : 240)
        .height(this.screenType == 'lg' ? 160 : 200)

        Column().height(6).width('100%').backgroundColor($r('app.color.background'))
      }

      Column() {
        TimePicker({
          selected: new Date(this.thisEvent.clockTime[0], this.thisEvent.clockTime[1] - 1, +this.thisEvent.clockTime[2], this.thisEvent.clockTime[3], this.thisEvent.clockTime[4])
        })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .onChange((value: TimePickerResult) => {
            this.thisEvent.clockTime = [this.thisEvent.clockTime[0], this.thisEvent.clockTime[1], this.thisEvent.clockTime[2], value.hour, value.minute]
            console.info('select current time is: ' + value.hour + ':' + value.minute)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /*-------------------------------------------------------重复--------------------------------------------------------*/
  private createNumberRange(start: number, end: number): string[] {
    var ret: string[] = []
    for (let i = start;i <= end; i++)
      ret.push(i.toString())
    return ret
  }

  private cycleStateRes: Resource[] = [$r('app.string.onlyOneTime'), $r('app.string.customize'), $r('app.string.everyWorkingDay'), $r('app.string.everyNonworkingDay'), $r('app.string.everyDay'), $r('app.string.ebbinghaus')]
  //  private userCyclePeriod: Resource[] = [$r('app.string.day'), $r('app.string.week'), $r('app.string.month'), $r('app.string.year')]
  private weekResource: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
  //  private weekResource: Resource[] = [$r('app.string.Monday'), $r('app.string.Tuesday'), $r('app.string.Wednesday'), $r('app.string.Thursday'), $r('app.string.Friday'), $r('app.string.Saturday'), $r('app.string.Sunday')]
  private monthResource: string[] = this.createNumberRange(1, 31)

  private changeCycleState(value: number) {
    if (this.thisEvent.cycleState != value)
      this.changedCycle = true
    this.thisEvent.cycleState = value
    if (value != 0) {
      this.thisEvent.clockTime[0] = this.thisEvent.thisDate[0],
      this.thisEvent.clockTime[1] = this.thisEvent.thisDate[1],
      this.thisEvent.clockTime[2] = this.thisEvent.thisDate[2]
      this.thisEvent.validEndTime[0] = this.thisEvent.thisDate[0],
      this.thisEvent.validEndTime[1] = this.thisEvent.thisDate[1],
      this.thisEvent.validEndTime[2] = this.thisEvent.thisDate[2]
    }
  }
  /**
   * 重复模式选择菜单
   */
  @Builder cycleStateMenu() {
    Column() {
      Column() {
        ForEach(this.cycleStateRes, (item: string, index: number) => {
          if (index != 1) {
            Column() {
              Column() {
                Text(item)
                  .fontColor($r('app.color.text_level1'))
                  .fontSize(14)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ bottom: 12, top: 12 })
              .onTouch(() => {
                this.changeCycleState(index)
              })

              Divider().color($r('app.color.divider'))
            }
            .width('100%')
          }
        })
        Column() {
          Column() {
            Text(this.cycleStateRes[1])
              .fontColor($r('app.color.text_level1'))
              .fontSize(14)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ bottom: 12, top: 12 })
          .onTouch(() => {
            this.changeCycleState(1)
          })
        }
        .width('100%')
      }
      .padding({ left: 12, right: 12 })
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 重复开始时间选择菜单
   */
  @Builder cycleStartTimeMenu() {
    Column() {
      Column() {
        DatePicker({
          selected: new Date(this.thisEvent.cycleStartDate[0], this.thisEvent.cycleStartDate[1] - 1, this.thisEvent.cycleStartDate[2]),
          end: new Date(this.thisEvent.cycleEndDate[0], this.thisEvent.cycleEndDate[1] - 1, this.thisEvent.cycleEndDate[2])
        })
          .onChange((value: DatePickerResult) => {
            this.changedCycle = true
            this.thisEvent.cycleStartDate = [value.year, value.month + 1, value.day]
            console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 重复开始时间选择菜单
   */
  @Builder cycleEndTimeMenu() {
    Column() {
      Column() {
        DatePicker({
          start: new Date(this.thisEvent.cycleStartDate[0], this.thisEvent.cycleStartDate[1] - 1, this.thisEvent.cycleStartDate[2]),
          selected: new Date(this.thisEvent.cycleEndDate[0], this.thisEvent.cycleEndDate[1] - 1, this.thisEvent.cycleEndDate[2])
        })
          .onChange((value: DatePickerResult) => {
            this.changedCycle = true
            this.thisEvent.cycleEndDate = [value.year, value.month + 1, value.day]
            console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 自定义重复周期选择菜单
   */
  @Builder cyclePeriodMenu() {
    Column() {
      Row() {
        TextPicker({ range: ['每'] })
          .width('30%')
          .height('100%')
        TextPicker({ range: this.createNumberRange(1, 99), selected: this.thisEvent.cycleBaseNumber - 1 })
          .onChange((value: string, index: number) => {
            this.changedCycle = true
            this.thisEvent.cycleBaseNumber = index + 1
          })
          .width('40%')
          .height('100%')
        TextPicker({ range: $r('app.strarray.dateUnit'), selected: this.thisEvent.cycleUnit - 1 })
          .onChange((value: string, index: number) => {
            this.changedCycle = true
            this.thisEvent.cycleDate = []
            this.thisEvent.cycleDateYear = []
            this.thisEvent.cycleUnit = index + 1
            if (index == 1) {
              var temp = (new Date(this.thisEvent.thisDate[0], this.thisEvent.thisDate[1] - 1, this.thisEvent.thisDate[2])).getDay()
              this.thisEvent.cycleDate.push(temp == 0 ? 7 : temp)
            }
            else if (index == 2)
              this.thisEvent.cycleDate.push(this.thisEvent.thisDate[2])
            else if (index == 3)
              this.thisEvent.cycleDateYear.push((this.thisEvent.thisDate[1] < 10 ? '0' : '') + this.thisEvent.thisDate[1] + '-' + (this.thisEvent.thisDate[2] < 10 ? '0' : '') + this.thisEvent.thisDate[2])
          })
          .width('30%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 状态按钮
   */
  @Builder toggleButton(text: string, value: number, width: number) {
    Toggle({ type: ToggleType.Button, isOn: this.thisEvent.cycleDate.indexOf(value) != -1 }) {
      Text(text)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_level1'))
    }
    .height(40)
    .width(width)
    .selectedColor(this.translucentSaturationAccentColor)
    .onChange((isOn: boolean) => {
      this.changedCycle = true
      if (isOn && this.thisEvent.cycleDate.indexOf(value) == -1) {
        console.info('add ' + value.toString())
        this.thisEvent.cycleDate.push(value)
      } else {
        if (this.thisEvent.cycleDate.length > 1) {
          console.info('sub ' + value.toString())
          this.thisEvent.cycleDate = this.thisEvent.cycleDate.filter(item => item != value)
        } else {
          prompt.showToast({
            message: (Object)($r('app.string.dateCantBeEmpty')),
            duration: 500,
          });
        }
      }
      this.CODE_DISTURBANCE()
    })
  }

  /**
   * 重复具体内容
   */
  @Builder cycleDataMenu() {
    Column() {
      if (this.thisEvent.cycleUnit == 2) {
        Column({ space: 8 }) {
          if (this.FirstDayOfWeek == 1) {
            ForEach(this.weekResource, (item: string, index: number) => {
              this.toggleButton(item, index, 80)
            })
          } else {
            ForEach(this.weekResource, (item: string, index: number) => {
              if (index > 0)
                this.toggleButton(item, index, 80)
            })
            this.toggleButton(this.weekResource[0], 0, 80)
          }
        }.padding(12)
      } else if (this.thisEvent.cycleUnit == 3) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.monthResource, (item: string, index: number) => {
            Column() {
              this.toggleButton(item, index + 1, 40)
            }.padding(4)
          })
        }.width(16 + 48 * (this.screenType == 'sm' ? 4 : 7))
        .padding(8)
      }
    }
    .justifyContent(FlexAlign.Start)
  }

  @Builder cycleDataYearMenu(isShow: Boolean) {
    Column() {
      Column() {
        Stack() {
          if (isShow) {
            Stack() {
              DatePicker({
                selected: new Date(2020, this.tempDate[0] - 1, this.tempDate[1])
              })
                .onChange((value: DatePickerResult) => {
                  this.tempDate = [value.month + 1, value.day]
                  console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
                })
                .width('100%')
                .height('100%')
              Column() {
                Scroll() {
                  Column({ space: 8 }) {
                    ForEach(this.thisEvent.cycleDateYear, (item: string) => {
                      Button() {
                        Text(item)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_level1'))
                      }
                      .height(32)
                      .width('100%')
                      .backgroundColor(this.translucentSaturationAccentColor)
                      .onClick(() => {
                        this.changedCycle = true
                        if (this.thisEvent.cycleDateYear.length > 1) {
                          console.info('sub ' + item)
                          this.thisEvent.cycleDateYear = this.thisEvent.cycleDateYear.filter(item2 => item2 != item)
                        } else {
                          prompt.showToast({
                            message: (Object)($r('app.string.dateCantBeEmpty')),
                            duration: 500,
                          });
                        }
                        this.CODE_DISTURBANCE()
                      })
                    })
                  }.padding(8)
                }
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Off)
              }
              .backgroundColor($r('app.color.panelCard'))
              .width('43%')
              .height('100%')
              .borderRadius(12)
              .onClick(() => {
              })
            }.alignContent(Alignment.Start)

            Button() {
              Image($r('app.media.ic_new_add'))
                .height('80%')
                .width('80%')
            }
            .height(24)
            .width(24)
            .backgroundColor($r('app.color.divider'))
            .onClick(() => {
              this.changedCycle = true
              var temp: string = (this.tempDate[0] < 10 ? '0' : '') + this.tempDate[0] + '-' + (this.tempDate[1] < 10 ? '0' : '') + this.tempDate[1]
              console.info(temp)
              if (this.thisEvent.cycleDateYear.indexOf(temp) == -1)
                this.thisEvent.cycleDateYear.push(temp)
              this.CODE_DISTURBANCE()
            })
          }
        }.alignContent(Alignment.BottomEnd)
      }
      .padding({ left: 40, top: isShow ? 12 : 0, right: 12, bottom: isShow ? 12 : 0 })
      .height(isShow ? (this.screenType == 'lg' ? 160 : 200) : 0)
      .width('100%')
      .animation({
        duration: 200, // 动画时长
        curve: Curve.EaseOut, // 动画曲线
        delay: 0, // 动画延迟
        iterations: 1, // 播放次数
      })

      if (isShow) {
        Column() {
          Divider().width('100%').color($r('app.color.divider'))
        }.padding({ left: 40 })
      }
    }
  }

  /**
   * 时限选择菜单
   */
  @Builder cycleLimitMenu() {
    Column() {
      Row() {
        TextPicker({ range: this.createNumberRange(1, 99), selected: this.thisEvent.cycleDateLimit - 1 })
          .onChange((value: string, index: number) => {
            this.changedCycle = true
            this.thisEvent.cycleDateLimit = index + 1
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /*-----------------------------------------------------有效时间-------------------------------------------------------*/

  private checkTimeValue(time1: number[], time2: number[]): boolean {
    for (let i = 0;i < 5; i++) {
      if (time1[i] != time2[i])
        return time1[i] < time2[i]
    }
    return true
  }

  /**
   * 有效开始时间选择菜单
   */
  @Builder validStartTimeMenu() {
    Column() {
      Column() {
        TimePicker({
          selected: new Date(this.thisEvent.validStartTime[0], this.thisEvent.validStartTime[1] - 1, +this.thisEvent.validStartTime[2], this.thisEvent.validStartTime[3], this.thisEvent.validStartTime[4])
        })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .onChange((value: TimePickerResult) => {
            let temp = [this.thisEvent.validStartTime[0], this.thisEvent.validStartTime[1], this.thisEvent.validStartTime[2], value.hour, value.minute]
            if (this.checkTimeValue(temp, this.thisEvent.validEndTime)) {
              this.thisEvent.validStartTime = temp
            } else {
              prompt.showToast({
                message: (Object)($r('app.string.timeWrong')),
                duration: 500,
              });
            }
            console.info('select current time is: ' + value.hour + ':' + value.minute)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 有效结束时间选择菜单
   */
  @Builder validEndTimeMenu() {
    Column() {
      if (this.thisEvent.cycleState == 0) {
        Column() {
          DatePicker({
            start: new Date(this.thisEvent.validStartTime[0], this.thisEvent.validStartTime[1] - 1, +this.thisEvent.validStartTime[2], this.thisEvent.validStartTime[3], this.thisEvent.validStartTime[4]),
            selected: new Date(this.thisEvent.validEndTime[0], this.thisEvent.validEndTime[1] - 1, this.thisEvent.validEndTime[2], this.thisEvent.validEndTime[3], this.thisEvent.validEndTime[4])
          })
            .onChange((value: DatePickerResult) => {
              let temp = [value.year, value.month + 1, value.day, this.thisEvent.validEndTime[3], this.thisEvent.validEndTime[4]]
              if (this.checkTimeValue(this.thisEvent.validStartTime, temp)) {
                this.thisEvent.validEndTime = temp
              } else {
                prompt.showToast({
                  message: (Object)($r('app.string.timeWrong')),
                  duration: 500,
                });
              }
              console.info('select current date is: ' + value.year + '-' + (value.month + 1) + '-' + value.day)
            })
            .width('100%')
            .height('100%')
        }
        .padding(12)
        .width(this.screenType == 'lg' ? 280 : 240)
        .height(this.screenType == 'lg' ? 160 : 200)

        Column().height(6).width('100%').backgroundColor($r('app.color.background'))
      }

      Column() {
        TimePicker({
          selected: new Date(this.thisEvent.validEndTime[0], this.thisEvent.validEndTime[1] - 1, +this.thisEvent.validEndTime[2], this.thisEvent.validEndTime[3], this.thisEvent.validEndTime[4])
        })
          .useMilitaryTime(this.DefaultTimeFormat == 0)
          .onChange((value: TimePickerResult) => {
            let temp = [this.thisEvent.validEndTime[0], this.thisEvent.validEndTime[1], this.thisEvent.validEndTime[2], value.hour, value.minute]
            if (this.checkTimeValue(this.thisEvent.validStartTime, temp)) {
              this.thisEvent.validEndTime = temp
            } else {
              prompt.showToast({
                message: (Object)($r('app.string.timeWrong')),
                duration: 500,
              });
            }
            console.info('select current time is: ' + value.hour + ':' + value.minute)
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .width(this.screenType == 'lg' ? 280 : 240)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  /*-------------------------------------------------------次数--------------------------------------------------------*/

  /**
   * 次数选择菜单
   */
  @Builder countNumberMenu() {
    Column() {
      Row() {
        TextPicker({ range: this.createNumberRange(1, 99), selected: this.thisEvent.countNumber - 1 })
          .onChange((value: string, index: number) => {
            this.thisEvent.countNumber = index + 1
          })
          .width('100%')
          .height('100%')
      }
      .padding(12)
      .height(this.screenType == 'lg' ? 160 : 200)
    }
    .justifyContent(FlexAlign.Start)
  }

  private closeThis() {
    this.editEvent = false
    this.setToStart()
    this.showEventAddPanel = false
  }

  build() {
    Panel(this.showEventAddPanel) {
      Column() {
        Column() {
          Row() {
            Column() {
              Text(this.editEvent ? "编辑待办" : $r('app.string.createEvent'))
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
                  if (this.thisEvent.name == '') {
                    prompt.showToast({
                      message: (Object)($r('app.string.eventEntryNull')),
                      duration: 2000,
                    });
                  } else {
                    if (this.editEvent) {
                      if (this.changedCycle) {
                        AlertDialog.show(
                          {
                            title: '编辑待办',
                            message: '您对重复信息进行了修改，保存后不会保留已完成的事项信息，是否保存？',
                            primaryButton: {
                              value: $r('app.string.cancel'),
                              fontColor: this.accentColor,
                              action: () => {
                              }
                            },
                            secondaryButton: {
                              value: $r('app.string.confirm'),
                              fontColor: this.accentColor,
                              action: () => {
                                editThisEvent(this.thisEvent.id1, this.thisEvent, true)
                                this.closeThis()
                              }
                            },
                            cancel: () => {
                            }
                          }
                        )
                      } else {
                        editThisEvent(this.thisEvent.id1, this.thisEvent, false)
                        this.closeThis()
                      }
                    } else {
                      createEvent(this.thisEvent)
                      this.closeThis()
                    }
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
                this.editEvent = false
                this.setToStart()
                this.showEventAddPanel = false
              })
              .height(24)
            }
          }
          .height(28)
          .margin({ bottom: 16 })

          Column() {
            Column() {
              Row() {
                if (this.showEventAddPanel) {
                  Column() {
                    TextInput({ placeholder: $r('app.string.doSomething'), text: this.thisEvent.name })
                      .onChange((value: string) => {
                        this.thisEvent.name = value
                      })
                      .caretColor(this.accentColor)
                      .backgroundColor($r('app.color.divider'))
                      .placeholderColor($r('app.color.text_level3'))
                      .fontColor($r('app.color.text_level1'))
                  }
                  .justifyContent(FlexAlign.Center)
                  .height(56)
                  .layoutWeight(1)
                }

                Button() {
                  Image(this.folderIcon).height(24).width(24)
                }
                .height(40)
                .width(40)
                .backgroundColor($r('app.color.divider'))
                .bindMenu(this.FoldrMenu)
                .margin({ left: 8 })
              }
            }
            .width('100%')

            Column() {
              Row() {
                Button() {
                  Image(this.thisEvent.isCollect ? $r('app.media.ic_choose_collect_on_Marking') : $r('app.media.ic_new_highlights'))
                    .height(24)
                    .width(24)
                }
                .onClick(() => {
                  this.thisEvent.isCollect = !this.thisEvent.isCollect
                })
                .height(40)
                .width(40)
                .backgroundColor($r('app.color.divider'))
                .margin({ right: 8 })

                Button() {
                  Image(this.thisEvent.isImportant ? $r('app.media.ic_target_warning') : $r('app.media.ic_new_warning'))
                    .height(24)
                    .width(24)
                }
                .onClick(() => {
                  this.thisEvent.isImportant = !this.thisEvent.isImportant
                })
                .height(40)
                .width(40)
                .backgroundColor($r('app.color.divider'))
                .margin({ right: 8 })

                Button() {
                  Text($r('app.string.Today'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_level1'))
                }
                .layoutWeight(1)
                .height(40)
                .backgroundColor(
                    this.isTheDay([(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]) &&
                    this.thisEvent.cycleState == 0 ?
                  this.translucentSaturationAccentColor : $r('app.color.divider')
                )
                .margin({ right: 8 })
                .onClick(() => {
                  this.thisEvent.setDate((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()), this.DefineCycleLength)
                  this.CODE_DISTURBANCE()
                })

                Button() {
                  Text($r('app.string.Tomorrow'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_level1'))
                }
                .layoutWeight(1)
                .height(40)
                .backgroundColor(
                    this.isTheDay(this.getNextDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()))) &&
                    this.thisEvent.cycleState == 0 ?
                  this.translucentSaturationAccentColor : $r('app.color.divider')
                )
                .margin({ right: 8 })
                .onClick(() => {
                  let newDate: number[] = this.getNextDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()))
                  this.thisEvent.setDate(newDate[0], newDate[1], newDate[2], this.DefineCycleLength)
                  this.CODE_DISTURBANCE()
                })

                Button() {
                  Column() {
                    Text(this.thisEvent.getShowDate())
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_level1'))
                  }
                  .padding({
                    left: this.screenType == 'sm' ? (this.isLongDate ? 6 : 12) : 24,
                    right: this.screenType == 'sm' ? (this.isLongDate ? 6 : 12) : 24
                  })
                }
                .backgroundColor(
                    !this.isTheDay([(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]) &&
                    !this.isTheDay(this.getNextDay((new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate()))) &&
                    this.thisEvent.cycleState == 0 ?
                  this.translucentSaturationAccentColor : $r('app.color.divider')
                )
                .borderRadius(20)
                .bindMenu(this.DateMenu())
              }
            }
            .width('100%')
          }
          .margin({ bottom: 8 })

          Divider().color($r('app.color.divider'))
            .margin({ bottom: 8 })

          Column() {
            Scroll() {
              Column() {

                Stack() {
                  Scroll() {
                    if (this.showEventAddPanel) {
                      TextArea({ placeholder: $r('app.string.Remark'), text: this.thisEvent.comment })
                        .onChange((value: string) => {
                          this.thisEvent.comment = value
                        })
                        .caretColor(this.accentColor)
                        .backgroundColor($r('app.color.divider'))
                        .height(this.isLargeComment ? 264 : 40)
                        .constraintSize({
                          maxHeight: this.isLargeComment ? Infinity : 40
                        })
                        .placeholderColor($r('app.color.text_level3'))
                        .fontColor($r('app.color.text_level1'))
                    }
                  }
                  .scrollBar(BarState.Off)
                  .borderRadius(20)
                  .height(this.isLargeComment ? 264 : 40)
                  .onTouch(() => {
                    this.isShowMore = [false, false, false, false]
                    this.isLargeComment = true
                  })
                  .animation({
                    duration: 200, // 动画时长
                    curve: Curve.EaseOut, // 动画曲线
                    delay: 0, // 动画延迟
                    iterations: 1, // 播放次数
                  })

                  if (this.isLargeComment) {
                    Image($r('app.media.ic_spinner_level2'))
                      .width(24)
                      .height(24)
                      .onClick(() => {
                        this.isLargeComment = false
                      })
                      .offset({ x: -6, y: -6 })
                      .rotate({ x: 0, y: 0, z: 1, angle: 180 })
                  }
                }
                .alignContent(Alignment.BottomEnd)

                Column() {
                  Column() {
                    this.listItem($r('app.media.ic_new_cycle'), $r('app.string.cycle'), this.thisEvent.getCycleInfo(this.FirstDayOfWeek), this.isShowMore[0])
                  }.onClick(() => {
                    if (!this.isShowMore[0]) {
                      this.isShowMore = [true, false, false, false]
                    } else {
                      this.isShowMore[0] = false
                      this.thisEvent.cycleYearShow = false
                    }
                  })

                  Column() {
                    this.listItem_little($r('app.string.cycleState'), this.cycleStateRes[this.thisEvent.cycleState], this.isShowMore[0] && !this.thisEvent.cycleYearShow)
                  }.bindMenu(this.cycleStateMenu())

                  Column() {
                    this.listItem_little($r('app.string.cycleStartTime'), this.thisEvent.getDateInfoThis(this.thisEvent.cycleStartDate), this.isShowMore[0] && this.thisEvent.cycleState != 0 && !this.thisEvent.cycleYearShow)
                  }.bindMenu(this.cycleStartTimeMenu())

                  Column() {
                    this.listItem_little($r('app.string.cycleEndTime'), this.thisEvent.getDateInfoThis(this.thisEvent.cycleEndDate), this.isShowMore[0] && this.thisEvent.cycleState != 0 && !this.thisEvent.cycleYearShow)
                  }.bindMenu(this.cycleEndTimeMenu())

                  Column() {
                    this.listItem_little($r('app.string.cycleTime'), this.thisEvent.getUserCyclePeriod(), this.isShowMore[0] && this.thisEvent.cycleState == 1 && !this.thisEvent.cycleYearShow)
                  }.bindMenu(this.cyclePeriodMenu())

                  Column() {
                    this.listItem_little($r('app.string.cycleSpecificTime'), this.thisEvent.getUserCycleData(this.FirstDayOfWeek), this.isShowMore[0] && this.thisEvent.cycleState == 1 && (this.thisEvent.cycleUnit == 2 || this.thisEvent.cycleUnit == 3))
                  }.bindMenu(this.cycleDataMenu())

                  Column() {
                    this.listItem_little($r('app.string.cycleSpecificTime'), this.thisEvent.getUserCycleData(this.FirstDayOfWeek), this.isShowMore[0] && this.thisEvent.cycleState == 1 && this.thisEvent.cycleUnit == 4)
                  }.onClick(() => {
                    if (this.isShowMore[0] && this.thisEvent.cycleState == 1 && this.thisEvent.cycleUnit == 4)
                      this.thisEvent.cycleYearShow = !this.thisEvent.cycleYearShow
                  })

                  Column() {
                    this.cycleDataYearMenu(this.isShowMore[0] && this.thisEvent.cycleYearShow)
                  }

                  Column() {
                    this.listItem_little($r('app.string.timeLimit'), this.thisEvent.cycleDateLimit.toString() + ' 天', this.isShowMore[0] && this.thisEvent.cycleState != 0)
                  }.bindMenu(this.cycleLimitMenu())
                }

                Column() {
                  Column() {
                    this.listItem($r('app.media.ic_new_effectiveTime'), $r('app.string.validTime'), this.thisEvent.getValidTimeInfo(this.DefaultTimeFormat == 0), this.isShowMore[1])
                  }.onClick(() => {
                    if (!this.isShowMore[1]) {
                      this.isShowMore = [false, true, false, false]
                    } else {
                      this.isShowMore[1] = false
                    }
                  })

                  Column() {
                    this.listItem_little($r('app.string.validStartTime'), this.getTimeInfo(this.thisEvent.validStartTime, false), this.isShowMore[1])
                  }.bindMenu(this.validStartTimeMenu())

                  Column() {
                    this.listItem_little($r('app.string.validEndTime'), this.getTimeInfo(this.thisEvent.validEndTime, this.thisEvent.cycleState == 0), this.isShowMore[1])
                  }.bindMenu(this.validEndTimeMenu())
                }

                Column() {
                  Column() {
                    this.listItem($r('app.media.ic_new_clock'), $r('app.string.clock'), this.thisEvent.getClockInfo(this.DefaultTimeFormat == 0), this.isShowMore[2])
                  }.onClick(() => {
                    if (!this.isShowMore[2]) {
                      this.isShowMore = [false, false, true, false]
                    } else {
                      this.isShowMore[2] = false
                    }
                  })

                  Column() {
                    this.listItem_little($r('app.string.clockState'), this.clockStateRes[this.thisEvent.clockState], this.isShowMore[2])
                  }.bindMenu(this.clockStateMenu())

                  Column() {
                    this.listItem_little($r('app.string.leadTime'), '提前' + (this.thisEvent.clockTimeLong[0] > 0 ? this.thisEvent.clockTimeLong[0] + '时' : '') + this.thisEvent.clockTimeLong[1] + '分',
                      this.isShowMore[2] && this.thisEvent.clockState == 1)
                  }.bindMenu(this.clockTimeLongMenu())

                  Column() {
                    this.listItem_little($r('app.string.fixedTime'), this.getTimeInfo(this.thisEvent.clockTime), this.isShowMore[2] && this.thisEvent.clockState == 2)
                  }.bindMenu(this.clockTimeMenu())
                }

                Column() {
                  Column() {
                    this.listItem($r('app.media.ic_new_number'), $r('app.string.times'), this.thisEvent.countNumber.toString() + ' 次', this.isShowMore[3], this.isShowMore[3])
                  }.bindMenu(this.countNumberMenu())
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
      }
      .onClick(() => {
      })
    }
    .onChange((width: number, height: number, mode: PanelMode) => {
      console.info('width: ' + width.toString() + ', height: ' + height.toString() + ', mode: ' + mode.toString())
      this.mode = mode
    })
    .miniHeight(172)
    .type(PanelType.Minibar)
    .mode(this.mode)
    .backgroundColor($r('app.color.foreground'))
  }
}