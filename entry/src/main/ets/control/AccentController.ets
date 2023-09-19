import BarResource from '../model/BarResourceContact';

PersistentStorage.PersistProp('AccentColor0', 0)
PersistentStorage.PersistProp('AccentColor1', '')

export function getAccentColor(accent: string): Resource {
  switch (accent) {
    case '_blue':
      return $r('app.color.accent_blue');
    case '_red':
      return $r('app.color.highSaturation_red');
    case '_green':
      return $r('app.color.highSaturation_green');
    case '_purple':
      return $r('app.color.highSaturation_purple');
    case '_pink':
      return $r('app.color.accent_pink');
    default:
      return $r('app.color.accent');
  }
}

export function get_accent(): Resource {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
//  console.info('get accent ' + AccentColor[1])
  switch (AccentColor1) {
    case '_blue':
      return $r('app.color.accent_blue');
    case '_red':
      return $r('app.color.highSaturation_red');
    case '_green':
      return $r('app.color.highSaturation_green');
    case '_purple':
      return $r('app.color.highSaturation_purple');
    case '_pink':
      return $r('app.color.accent_pink');
    default:
      return $r('app.color.accent');
  }
}

export function get_translucentSaturation_accent(): Resource {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
  switch (AccentColor1) {
    case '_blue':
      return $r('app.color.translucentSaturation_accent_blue');
    case '_red':
      return $r('app.color.highSaturation_red_half');
    case '_green':
      return $r('app.color.highSaturation_green_half');
    case '_purple':
      return $r('app.color.highSaturation_purple_half');
    case '_pink':
      return $r('app.color.translucentSaturation_accent_pink');
    default:
      return $r('app.color.get_translucentSaturation_accent');
  }
}

export function get_allChoose_on_Marking(): Resource {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
  switch (AccentColor1) {
    case '_blue':
      return $r('app.media.ic_choose_allChoose_on_Marking_blue');
    case '_red':
      return $r('app.media.ic_choose_allChoose_on_Marking_red');
    case '_green':
      return $r('app.media.ic_choose_allChoose_on_Marking_green');
    case '_purple':
      return $r('app.media.ic_choose_allChoose_on_Marking_purple');
    case '_pink':
      return $r('app.media.ic_choose_allChoose_on_Marking_pink');
    default:
      return $r('app.media.ic_choose_allChoose_on_Marking');
  }
}

export function get_collect_on_Marking(): Resource {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
  switch (AccentColor1) {
    case '_blue':
      return $r('app.media.ic_choose_collect_on_Marking_blue');
    case '_red':
      return $r('app.media.ic_choose_collect_on_Marking_red');
    case '_green':
      return $r('app.media.ic_choose_collect_on_Marking_green');
    case '_purple':
      return $r('app.media.ic_choose_collect_on_Marking_purple');
    case '_pink':
      return $r('app.media.ic_choose_collect_on_Marking_pink');
    default:
      return $r('app.media.ic_choose_collect_on_Marking');
  }
}

export function get_add_Marking(): Resource {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
  switch (AccentColor1) {
    case '_blue':
      return $r('app.media.ic_add_Marking_blue');
    case '_red':
      return $r('app.media.ic_add_Marking_red');
    case '_green':
      return $r('app.media.ic_add_Marking_green');
    case '_purple':
      return $r('app.media.ic_add_Marking_purple');
    case '_pink':
      return $r('app.media.ic_add_Marking_pink');
    default:
      return $r('app.media.ic_add_Marking');
  }
}

export function get_barResource(): BarResource[] {
  let AccentColor1:string = AppStorage.Get<string>("AccentColor1");
  switch (AccentColor1) {
    case '_blue':
      return [
        new BarResource($r('app.media.ic_todo_on_blue'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on_blue'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on_blue'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on_blue'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
    case '_red':
      return [
        new BarResource($r('app.media.ic_todo_on_red'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on_red'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on_red'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on_red'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
    case '_green':
      return [
        new BarResource($r('app.media.ic_todo_on_green'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on_green'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on_green'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on_green'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
    case '_purple':
      return [
        new BarResource($r('app.media.ic_todo_on_purple'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on_purple'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on_purple'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on_purple'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
    case '_pink':
      return [
        new BarResource($r('app.media.ic_todo_on_pink'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on_pink'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on_pink'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on_pink'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
    default:
      return [
        new BarResource($r('app.media.ic_todo_on'), $r('app.media.ic_todo_off'), $r('app.string.Todo'), 0),
        new BarResource($r('app.media.ic_calendar_on'), $r('app.media.ic_calendar_off'), $r('app.string.Calendar'), 1),
        new BarResource($r('app.media.ic_4quadrant_on'), $r('app.media.ic_4quadrant_off'), $r('app.string.Four_quadrant'), 2),
        new BarResource($r('app.media.ic_setting_on'), $r('app.media.ic_setting_off'), $r('app.string.Setting'), 3)
      ]
  }
}