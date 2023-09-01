import { getResource, getResource_little } from '../../control/EventsController';
import { EventsList_little } from '../element/EventsList'
import { get_accent, get_translucentSaturation_accent } from '../../control/AccentController';

@Component
export struct CalendarDate {
  @Link @Watch('getResource') date: number[]
  @StorageLink('showDate') showDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
  @StorageLink('folderId') folderId: number = 0
  @StorageLink('openCalendar') openCalendar: boolean = false
  @Link isHidden: boolean;
  @State showResource0: number = 0;
  @State showResource1: number = 0;
  @State showResource: [string, Resource, number][] = []
  private accentColor: Resource
  private translucentSaturationAccentColor: Resource

  private getResource() {
    getResource_little(this.date[0], this.date[1], this.date[2], this.folderId).then((ret) => {
      this.showResource = ret[2]
      this.showResource0 = ret[0];
      this.showResource1 = ret[1];
      console.log('getResource_little ', this.showResource);
    })
  }

  aboutToAppear() {
    this.accentColor = get_accent()
    this.translucentSaturationAccentColor = get_translucentSaturation_accent()
    this.getResource()
  }

  build() {
    Column() {
      Column() {
        Column() {
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
          }.width('100%')
          .padding(3)
          .borderRadius(8)
          .backgroundColor($r('app.color.foreground'))

          Column() {
            Column() {
              if (!this.isHidden && (this.showDate[1] == this.date[1])) {
                EventsList_little({
                  doneNum: $showResource0,
                  showResource: $showResource,
                  titleColor: (this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) &&
                              (new Date().getDate() == this.date[2] && new Date().getMonth() + 1 == this.date[1]) ?
                  $r('app.color.foreground') : $r('app.color.text_level1')
                })
              }
            }
            //            .justifyContent(FlexAlign.End)
            .height('100%')
            .width('100%')
          }
          .padding(3)
          .width('100%')
          .layoutWeight(1)
        }
        .height('100%')
        .borderRadius(8)
        .backgroundColor((this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) &&
                         (new Date().getDate() == this.date[2] && new Date().getMonth() + 1 == this.date[1]) ?
        this.translucentSaturationAccentColor : $r('app.color.foreground'))
        .border({
          width: (this.showDate[2] == this.date[2] && this.showDate[1] == this.date[1]) ? 2 : 0,
          color: this.translucentSaturationAccentColor
        })

        //        Text((this.date.getMonth() + 1).toString() + ' ' + this.date.getDate())
      }
      .backgroundColor($r('app.color.foreground'))
      .height('100%')
      .width('100%')
      .borderRadius(8)
      .onClick(() => {
        this.showDate[1] = this.date[1]
        this.showDate[2] = this.date[2]
        getResource(this.showDate[0], this.showDate[1], this.showDate[2], this.folderId);
        this.openCalendar = true
      })
    }
    .padding(3)
    .height('100%')
    .layoutWeight(1)
  }
}
