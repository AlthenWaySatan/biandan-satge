import BarResource from '../../model/BarResourceContact';
import { changeAllChoice } from '../../control/EventsController';

import { get_accent, get_barResource } from '../../control/AccentController';

@Component
export struct lgBar {
  @StorageLink('barResource') @Watch("accentChanged") barResource: BarResource[] = get_barResource()
  @StorageLink('isEdit') isEdit: boolean = false
  @StorageLink('selectPos') @Watch("selectPosChanged") selectPos: number = 0;
  @StorageLink('selectAnimation') selectAnimation: number[] = [0, 0, 0, 0];
  @State accentColor: Resource = get_accent()

  aboutToAppear() {
    this.accentColor = get_accent()
    this.selectAnimation[this.selectPos] = 1;
  }

  accentChanged() {
    this.accentColor = get_accent()
  }

  async selectPosChanged() {
    this.selectAnimation = [0, 0, 0, 0];
    this.selectAnimation[this.selectPos] = 1;
  }

  public barClick(id: number) {
    //    if(this.isEdit) return
    this.selectPos = id;
    console.info(id.toString());
  }

  @Builder BarIcon($$:{icon: Resource}) {
    Image($$.icon)
      .width(24)
      .height(24)
  }

  @Builder BarTextBut($$:{text: Resource, color: Resource}) {
    Text($$.text)
      .size({ width: '100%', height: 14 })
      .textAlign(TextAlign.Center)
      .fontColor($$.color)
      .fontSize(10)
      .fontWeight('Medium')
      .margin({ top: 4 })
  }

  build() {
    Stack() {
      Column() {
        Column() {
          ForEach(this.barResource, (item: BarResource) => {
            Button({ type: ButtonType.Normal }) {

              Stack() {

                Column() {
                  this.BarIcon({icon: item.iconOff})
                  this.BarTextBut({text: item.text, color: $r('app.color.text_level3')})
                }
                .justifyContent(FlexAlign.Center)
                .layoutWeight(1)
                .height("100%")

                Column() {
                  this.BarIcon({icon: item.iconOn})
                  this.BarTextBut({text: item.text, color: this.accentColor})
                }
                .justifyContent(FlexAlign.Center)
                .layoutWeight(1)
                .height("100%")
                .opacity(this.selectAnimation[item.id])
                .animation({
                  delay: 0,
                  duration: 300, // 动画时长
                  curve: Curve.EaseInOut, // 动画曲线
                })

              }
              .width("100%")
              .height("100%")

              // Column() {
              //   this.BarIcon({icon: (this.selectPos == item.id ? item.iconOn : item.iconOff)})
              //   this.BarTextBut({text: item.text, color: (this.selectPos == item.id ? this.accentColor : $r('app.color.text_level3'))})
              // }
              // .justifyContent(FlexAlign.Center)
              // .layoutWeight(1)
              // .height("100%")
            }
            .layoutWeight(1)
            .height(100)
            .borderRadius(4)
            .backgroundColor("#00000000")
            .onClick(this.barClick.bind(this, item.id))
          })
        }
        .height(400)
      }
      .justifyContent(FlexAlign.Center)
      .width(96)
      .height('100%')
      .backgroundColor($r('app.color.bar'))

      if (this.isEdit) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.mask'))
          .onClick(() => {
            this.isEdit = false
            changeAllChoice(false)
          })
      }
    }
  }
}

@Component
export struct mdBar {
  @StorageLink('barResource') @Watch("accentChanged") barResource: BarResource[] = get_barResource()
  @StorageLink('selectPos') @Watch("selectPosChanged") selectPos: number = 0;
  @StorageLink('selectAnimation') selectAnimation: number[] = [0, 0, 0, 0];
  @State accentColor: Resource = get_accent()

  aboutToAppear() {
    this.accentColor = get_accent()
    this.selectAnimation[this.selectPos] = 1;
  }

  accentChanged() {
    this.accentColor = get_accent()
  }

  async selectPosChanged() {
    this.selectAnimation = [0, 0, 0, 0];
    this.selectAnimation[this.selectPos] = 1;
  }

  public barClick(id: number) {
    this.selectPos = id;
    console.info(id.toString());
  }

  @Builder BarIcon($$:{icon: Resource}) {
    Image($$.icon)
      .width(24)
      .height(24)
  }

  @Builder BarTextRig($$:{text: Resource, color: Resource}) {
    Text($$.text)
      .size({ height: 16 })
      .textAlign(TextAlign.Center)
      .fontSize(12)
      .fontColor($$.color)
      .fontWeight('Medium')
      .margin({ left: 8 })
  }

  build() {
    Row() {
      ForEach(this.barResource, (item: BarResource) => {
        Button({ type: ButtonType.Normal }) {
          Stack() {

            Row() {
              this.BarIcon({icon: item.iconOff})
              this.BarTextRig({text: item.text, color: $r('app.color.text_level3')})
            }
            .justifyContent(FlexAlign.Center)

            Row() {
              this.BarIcon({icon: item.iconOn})
              this.BarTextRig({text: item.text, color: this.accentColor})
            }
            .justifyContent(FlexAlign.Center)
            .opacity(this.selectAnimation[item.id])
            .animation({
              delay: 0,
              duration: 300, // 动画时长
              curve: Curve.EaseInOut, // 动画曲线
            })

          }
          .width("100%")
          .height("100%")
          // Row() {
          //   this.BarIcon({icon: (this.selectPos == item.id ? item.iconOn : item.iconOff)})
          //   this.BarTextRig({text: item.text, color: (this.selectPos == item.id ? this.accentColor : $r('app.color.text_level3'))})
          // }
          // .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height("100%")
        .borderRadius(4)
        .backgroundColor("#00000000")
        .onClick(this.barClick.bind(this, item.id))
      })
    }
    .width('100%')
    .height(40)
    .backgroundColor($r('app.color.bar'))
    .padding({ left: 24, right: 24 })
  }
}

@Component
export struct smBar {
  @StorageLink('barResource') @Watch("accentChanged") barResource: BarResource[] = get_barResource()
  @StorageLink('selectPos') @Watch("selectPosChanged") selectPos: number = 0;
  @StorageLink('selectAnimation') selectAnimation: number[] = [0, 0, 0, 0];
  @State accentColor: Resource = get_accent()

  aboutToAppear() {
    this.accentColor = get_accent()
    this.selectAnimation[this.selectPos] = 1;
  }

  accentChanged() {
    this.accentColor = get_accent()
  }

  async selectPosChanged() {
    this.selectAnimation = [0, 0, 0, 0];
    this.selectAnimation[this.selectPos] = 1;
  }

  public barClick(id: number) {
    this.selectPos = id;
    console.info(id.toString());
  }

  @Builder BarIcon($$:{icon: Resource}) {
    Image($$.icon)
      .width(24)
      .height(24)
  }

  @Builder BarTextBut($$: {text: Resource, color: Resource}) {
    Text($$.text)
      .size({ width: '100%', height: 14 })
      .textAlign(TextAlign.Center)
      .fontColor($$.color)
      .fontSize(10)
      .fontWeight('Medium')
      .margin({ top: 4 })
  }

  build() {
    Row() {
      ForEach(this.barResource, (item: BarResource) => {
        Button({ type: ButtonType.Normal }) {
          Stack() {

            Column() {
              this.BarIcon({icon: item.iconOff})
              this.BarTextBut({text: item.text, color: $r('app.color.text_level3')})
            }
            .height("100%")
            .padding({ top: 7 })

            Column() {
              this.BarIcon({icon: item.iconOn})
              this.BarTextBut({text: item.text, color: this.accentColor})
            }
            .height("100%")
            .padding({ top: 7 })
            .opacity(this.selectAnimation[item.id])
            .animation({
              delay: 0,
              duration: 300, // 动画时长
              curve: Curve.EaseInOut, // 动画曲线
            })

          }
          .width("100%")
          .height("100%")
        }
        .layoutWeight(1)
        .height("100%")
        .borderRadius(4)
        .backgroundColor("#00000000")
        .onClick(this.barClick.bind(this, item.id))
      })

    }
    .width('100%')
    .height(54)
    .backgroundColor($r('app.color.bar'))
  }
}