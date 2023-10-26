import { TitleOne_small } from './Title';
import { EventsList } from './EventsList';
import { putOffAll } from '../../control/EventsController'
import ThingsResource from '../../model/EventsResourceContact';
import { get_accent } from '../../control/AccentController';
import { refreshResource } from '../../control/EventsController';
import common from '@ohos.app.ability.common';

@Component
export struct EventsTable {

  //是否编辑模式
  @StorageLink('isEdit') isEdit: boolean = false

  //是否隐藏
  @StorageLink('isHidden') isHidden: boolean[] = [false, false, false]

  //旋转下键三角
  @State IsRotate0: number = 0;
  @State IsRotate1: number = 0;
  @State IsRotate2: number = 0;
  private accentColor: Resource
  @State isRefreshing: boolean = false
  @State isScroll: boolean = false
  private tootleOffset: number = 0

  //当前页签
  @StorageLink('selectPos') selectPos: number = 0;
  //日历是否打开
  @StorageLink('openCalendar') openCalendar: boolean = false
  private miny: number;
  private mint: number;

  aboutToAppear() {
    this.accentColor = get_accent()
    this.tootleOffset = 0
    this.isScroll = false
    this.IsRotate0 = this.isHidden[0] ? -90 : 0
    this.IsRotate1 = this.isHidden[1] ? -90 : 0
    this.IsRotate2 = this.isHidden[2] ? -90 : 0
  }

  /**
   * 隐藏待办卡片
   * @param id 卡片ID
   */
  private hideCard(id: number): void {
    console.info('Click: ' + id.toString())
    if (id == 0) {
      if (this.isHidden[id]) {
        this.IsRotate0 = 0
      }
      else {
        this.IsRotate0 = -90
      }
    } else if (id == 1) {
      if (this.isHidden[id]) {
        this.IsRotate1 = 0
      }
      else {
        this.IsRotate1 = -90
      }
    } else if (id == 2) {
      if (this.isHidden[id]) {
        this.IsRotate2 = 0
      }
      else {
        this.IsRotate2 = -90
      }
    }
    this.isHidden[id] = !this.isHidden[id]
  }

  @Styles Card() {
    .width('100%')
    .backgroundColor($r('app.color.foreground'))
    .borderRadius(16)
  }

  @State counter: number = 0

  build() {
    Column() {
      Refresh({ refreshing: this.isRefreshing }) {
        Scroll() {
          Column() {
            Column() {
              TitleOne_small({
                mainTitle: $r('app.string.Todo_things'),
                rotateAngle: $IsRotate0,
                offHeight: -12
              })
            }
            .onClick(() => this.hideCard(0))

            Column() {
              EventsList({
                type: 0
              })
            }
            .Card()

            Row() {
              Column() {
                TitleOne_small({
                  mainTitle: $r('app.string.Path_things'),
                  rotateAngle: $IsRotate1
                })
              }.onClick(() => this.hideCard(1))
              .layoutWeight(1)

              Column() {
                Button($r('app.string.allPutOff'))
                  .height(22)
                  .width(108)
                  .offset({ x: this.isEdit || this.isHidden[1] ? 108 : 0, y: 0 })
                  .animation({
                    duration: 200, // 动画时长
                    curve: Curve.EaseOut, // 动画曲线
                    delay: 0, // 动画延迟
                    iterations: 1, // 播放次数
                  })
                  .fontColor(this.accentColor)
                  .backgroundColor('#00000000')
                  .onClick(() => {
                    let context: Context = getContext(this) as common.Context
                    putOffAll(context)
                  })
              }
              .padding({ top: 8 })
              .height(48)
              .width(this.isEdit || this.isHidden[1] ? 0 : 108)
            }

            Column() {
              EventsList({
                type: 1,
                isPath: true
              })
            }
            .Card()

            Column() {
              TitleOne_small({
                mainTitle: $r('app.string.Done_things'),
                rotateAngle: $IsRotate2
              })
            }.onClick(() => this.hideCard(2))

            Column() {
              EventsList({
                type: 2,
                isDone: true
              })
            }
            .Card()
          }
          .margin({ bottom: 12 })
        }
        .onScroll((xOffset: number, yOffset: number) => {
          this.tootleOffset += yOffset
          if (this.tootleOffset <= -200 && !this.isRefreshing && !this.isScroll) {
            console.info("yOffset:" + yOffset + ", tootleOffset:" + this.tootleOffset)
            this.isRefreshing = true
            this.isScroll = true
          }
          else if (this.tootleOffset > 0.001 && this.isRefreshing) this.isRefreshing = false
        })
        .onScrollEnd(() => {
          console.info("onScrollEnd")
          this.isScroll = false
        })
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .offset({
          x: 0,
          y: this.isRefreshing ? 60 : 0
        })
        .animation({
          duration: 200, // 动画时长
          curve: Curve.EaseOut, // 动画曲线
        })
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        console.info('Refresh onStatueChange state is ' + refreshStatus)
        if(refreshStatus == 1) {
          this.isRefreshing = true
        } else if(refreshStatus == 0){
          this.isRefreshing = false
        }
      })
      .onRefreshing(async () => {
        let context: Context = getContext(this) as common.Context
        await refreshResource(context)
        setTimeout(() => {
          this.isRefreshing = false
        }, 200)
        console.log('onRefreshing test')
      })
    }
    .onTouch((event: TouchEvent) => {
      if (this.selectPos == 1 && this.openCalendar) {
        if (event.type == TouchType.Down){
          this.miny = event.touches[0].y
          this.mint = new Date().getTime()
        }
        // console.log('miny: ' + this.miny + ', y: ' + event.touches[0].y);
        // console.log('mint: ' + this.mint + ', t: ' + new Date().getTime());
        if (event.type == TouchType.Up && this.miny - event.touches[0].y <= -10 && this.mint - new Date().getTime() >= -200) {
          this.isRefreshing = false
          this.openCalendar = false
        }
      }
    })
  }
}