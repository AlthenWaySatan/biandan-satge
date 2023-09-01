import device from '@system.device';
import window from '@ohos.window';
import router from '@ohos.router';

PersistentStorage.PersistProp('IsFirstIn', true)
PersistentStorage.PersistProp('IsAgreed', false)

@Entry
@Component
struct guide {
  @State statusBarHeight: number = 0
  @State screenDensity: number = 2
  @StorageLink('IsAgreed') IsAgreed: boolean = false

  aboutToAppear() {
    // window.getTopWindow((err, data) => {
      //      var windowClass = data;
      //      var type = window.AvoidAreaType.TYPE_SYSTEM;
      //      windowClass.getAvoidArea(type, (err, data) => {
      //        if (err) {
      //          console.error('Failed to obtain the area. Cause:' + JSON.stringify(err));
      //          return;
      //        }
      //        this.statusBarHeight = data.topRect.height;
      //        console.info("statusBarHeight====>>>> %{private}d", this.statusBarHeight);
      //      });
      //    });
      //    var that = this;
      //    device.getInfo({
      //      success: function (data) {
      //        console.info("Device information obtained successfully. Device screenDensity: %{private}d", data.screenDensity);
      //        that.screenDensity = data.screenDensity;
      //      },
      //      fail: function (code) {
      //        console.info("Failed to obtain device information. Error code: %{private}d", code);
      //      },
    // });
  }

  private endGuide() {
    AppStorage.Set('IsFirstIn', false)
    router.replace({
      url: 'pages/index',
    })
  }

  @Builder stepPage($$:{img: Resource, title: Resource | string, info: Resource | string, icon: boolean}) {
    Column() {
      Column() {
        Button('跳过')
          .height(36)
          .margin({ top: 12, right: 12 })
          .fontColor($r('app.color.text_level2'))
          .backgroundColor('#00000000')
          .onClick(() => {
            this.endGuide()
          })
      }
      .alignItems(HorizontalAlign.End)
      .height(48)
      .width('100%')

      Column() {
        if ($$.icon) {
          Image($$.img)
            .width(120)
            .height(120)
            .borderRadius(30)
        } else {
          Image($$.img)
        }
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 72, bottom: 8 })
      .height('40%')
      .width('70%')

      Column() {
        Text($$.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_level1'))
        Text($$.info)
          .fontColor($r('app.color.text_level2'))
          .fontSize(16)
          .margin({ top: 6 })
          .textAlign(TextAlign.Center)
      }
      .margin({ top: 24, bottom: 8 })
      .width('80%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }

  build() {
    Stepper() {

      StepperItem() {
        Column() {
          Column() {
            Image($r('app.media.icon'))
              .width(120)
              .height(120)
              .borderRadius(30)
          }
          .justifyContent(FlexAlign.Center)
          .margin({ top: 72, bottom: 8 })
          .height('40%')
          .width('70%')

          Column() {
            Text('欢迎使用便单')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_level1'))
            Text('让我们开始吧！')
              .fontColor($r('app.color.text_level2'))
              .fontSize(16)
              .margin({ top: 6 })
              .textAlign(TextAlign.Center)
          }
          .margin({ top: 24, bottom: 8 })
          .width('80%')
          .layoutWeight(1)

          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: this.IsAgreed })
              .size({ width: 16, height: 16 })
              .selectedColor($r('app.color.accent'))
              .onChange((isOn: boolean) => {
                this.IsAgreed = isOn ? true : false
                console.info('Component status:' + this.IsAgreed)
              })
            Row() {
              Text('我已阅读并同意')
                .fontColor($r('app.color.text_level2'))
                .fontSize(16)
              Text('用户协议和隐私声明')
                .fontColor($r('app.color.accent'))
                .fontSize(16)
                .onClick(() => {
                  router.push({
                    url: 'pages/illustrate'
                  })
                })
            }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .height('100%')
        .width('100%')
      }
      .status(this.IsAgreed ? ItemState.Normal : ItemState.Disabled)

      StepperItem() {
        Swiper() {
          this.stepPage({img: $r('app.media.img_todolist'), title: '修改待办事项', info: '点击修改待办，长按进入页面编辑', icon: false})
          this.stepPage({img: $r('app.media.img_todolist2'), title: '完成待办事项', info: '点击完成一次，长按取消一次', icon: false})
          this.stepPage({img: $r('app.media.img_todolist3'), title: '待办事项标记', info: '三种图标对应三种状态：\n待完成，正在完成，已完成\n不同颜色也对应不同分类 ', icon: false})
        }
        .cachedCount(2)
        .indicatorStyle({
          selectedColor: $r('app.color.accent')
        })
      }

      StepperItem() {
        this.stepPage({img: $r('app.media.img_panel'), title: '添加待办事项', info: '上划或点击，显示更多', icon: false})
      }

      StepperItem() {
        Swiper() {
          this.stepPage({img: $r('app.media.img_calendar'), title: '收起日历', info: '在日历界面上划可收起日历视图，下滑展开视图', icon: false})
          this.stepPage({img: $r('app.media.img_calendar2'), title: '切换日历', info: '在日历界面左滑可切换至下一月，右滑切换至上一月', icon: false})
          this.stepPage({img: $r('app.media.img_calendar3'), title: '切换日历', info: '在日历视图收起时左滑可切换至下一周，右滑切换至上一周', icon: false})
        }
        .cachedCount(2)
        .indicatorStyle({
          selectedColor: $r('app.color.accent')
        })
      }

      StepperItem() {
        this.stepPage({img: $r('app.media.img_fourQuadrants'), title: '展开象限', info: '在四象限界面点击对应象限标题展开象限视图', icon: false})
      }

      StepperItem() {
        this.stepPage({img: $r('app.media.img_add'), title: '快捷同步', info: '打开设备同步后，长按添加按钮，可向所有设备同步或接受最新数据', icon: false})
      }

      StepperItem() {
        this.stepPage({img: $r('app.media.icon'), title: '欢迎使用！', info: '一起进入便单的世界！', icon: true})
      }
    }
    .backgroundColor($r('app.color.background'))
    .padding({ top: this.statusBarHeight / this.screenDensity })
    .onFinish(() => {
      // 此处可处理点击最后一页的Finish时的逻辑，例如路由跳转等
      console.info('onFinish');
      this.endGuide()
    })
    .onSkip(() => {
      // 此处可处理点击跳过时的逻辑，例如动态修改Stepper的index值使其跳转到某一步骤页等
      console.info('onSkip');
    })
  }
}