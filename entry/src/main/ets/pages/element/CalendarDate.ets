import { getResource, getResource_little } from '../../control/EventsController';
import { EventsList_little } from '../element/EventsList'
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';
import common from '@ohos.app.ability.common';

@Component
export struct CalendarDate {
  @State date: number[] = []
  @Link showDate: number[]
  @StorageLink('folderId') @Watch('getResource') folderId: number = 0
  @StorageLink('openCalendar') openCalendar: boolean = false
  @State showResource0: number = 0;
  @State showResource1: number = 0;
  @State showResource: [string, Resource, number][] = []
  @Link accentColor: Resource
  @Link translucentSaturationAccentColor: Resource
  @Link @Watch('getResource') isShow: boolean;
  //
  private getResource() {
    // this.showResource = [0, 10, Array(10).fill(["xxxxx", $r('app.color.foreground'), 0])];
    if (this.isShow)
      setTimeout(async () => {
        let context: Context = getContext(this) as common.Context
        getResource_little(this.date[0], this.date[1], this.date[2], this.folderId, context).then((ret) => {
          this.showResource = ret[2]
          this.showResource0 = ret[0];
          this.showResource1 = ret[1];
          console.log('getResource_little ', this.showResource);
        })
      }, 450)
  }
  aboutToAppear() {
    this.getResource()
  }


  build() {
    Column() {
      Column() {
        Column() {
          Column() {
            Column() {
              if(this.isShow)
              Row() {
                Stack() {
                  Row() {
                    Text(this.date[2].toString())
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                      .fontColor((this.showDate[1] == this.date[1]) ?
                        ((new Date().getDate() == this.date[2] && new Date().getMonth() + 1 == this.date[1]) ? this.accentColor : $r('app.color.text_level1')) : $r('app.color.text_level3'))
                  }
                  .alignItems(VerticalAlign.Bottom)

                  Progress({
                    value: ((this.showResource1 + this.showResource0) == 0) ? 0 : ((this.showResource0) / (this.showResource1 + this.showResource0) * 100),
                    total: 100,
                    type: ProgressType.Ring
                  })
                    .color((this.showDate[1] == this.date[1]) ? this.accentColor : $r('app.color.barIcon_path_off'))
                    .backgroundColor($r('app.color.barIcon_fill_off'))
                    .style({ strokeWidth: 6 })
                }
                .constraintSize({
                  maxWidth: 40,
                  maxHeight: 40
                })
              }
              .width('100%')
              .padding(3)
              .borderRadius(8)
              .backgroundColor($r('app.color.foreground'))

              if(this.isShow)
              Column() {
                EventsList_little({
                  doneNum: $showResource0,
                  showResource: $showResource,
                  titleColor: (this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) &&
                              (new Date().getDate() == this.date[2] && new Date().getMonth() + 1 == this.date[1]) ?
                  $r('app.color.foreground') : $r('app.color.text_level1')
                })
              }
              .padding(3)
              .width('100%')
              .layoutWeight(1)
            }
            .opacity(this.isShow ? 1 : 0)
            .animation({
              duration: 500, // 动画时长
              curve: Curve.EaseInOut, // 动画曲线
            })
          }
          .visibility(this.isShow ? Visibility.Visible : Visibility.None)
        }
        .width('100%')
        .height('100%')
        .borderRadius(8)
        .backgroundColor((this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) &&
                         (new Date().getDate() == this.date[2] && new Date().getMonth() + 1 == this.date[1]) ?
        this.translucentSaturationAccentColor : $r('app.color.foreground'))
        .border({
          width: (this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) ? 2 : 0,
          color: this.translucentSaturationAccentColor
        })
      }
      .backgroundColor($r('app.color.foreground'))
      .borderRadius(8)
      .onClick(() => {
        this.showDate[1] = this.date[1]
        this.showDate[2] = this.date[2]
        let context: Context = getContext(this) as common.Context
        getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId, context);
        this.openCalendar = true
      })
    }
    .padding(3)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
  }
}
