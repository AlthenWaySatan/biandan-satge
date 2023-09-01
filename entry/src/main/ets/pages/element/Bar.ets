import BarResource from '../../model/BarResourceContact';
import { changeAllChoice } from '../../control/EventsController';

import { get_accent } from '../../control/AccentController';

@Component
export struct lgBar {
  private barResource: {
    iconOn: Resource,
    iconOff: Resource,
    text: Resource,
    id: number
  }[]
  @StorageLink('selectPos') selectPos: number = 0;
  @StorageLink('isEdit') isEdit: boolean = false
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent()
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
              Column() {
                this.BarIcon({icon: (this.selectPos == item.id ? item.iconOn : item.iconOff)})
                this.BarTextBut({text: item.text, color: (this.selectPos == item.id ? this.accentColor : $r('app.color.text_level3'))})
              }
              .justifyContent(FlexAlign.Center)
              .layoutWeight(1)
              .height("100%")
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
  private barResource: BarResource[]
  @StorageLink('selectPos') selectPos: number = 0;
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent()
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
          Row() {
            this.BarIcon({icon: (this.selectPos == item.id ? item.iconOn : item.iconOff)})
            this.BarTextRig({text: item.text, color: (this.selectPos == item.id ? this.accentColor : $r('app.color.text_level3'))})
          }
          .justifyContent(FlexAlign.Center)
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
  private barResource: BarResource[]
  @StorageLink('selectPos') selectPos: number = 0;
  private accentColor: Resource

  aboutToAppear() {
    this.accentColor = get_accent()
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
          Column() {
            this.BarIcon({icon: (this.selectPos == item.id ? item.iconOn : item.iconOff)})
            this.BarTextBut({text: item.text, color: (this.selectPos == item.id ? this.accentColor : $r('app.color.text_level3'))})
          }
          .height("100%")
          .padding({ top: 7 })
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