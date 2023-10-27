/**
 * 获取日期和时间
 */
import EventResource from '../model/EventsResourceContact'
export function getDateInfo(showTime: number[], thisDate: number[]): string {
  var ret = ''
  if (showTime[0] != thisDate[0]) {
    ret = ret + showTime[0] + '年' + showTime[1] + '月' + showTime[2] + '日'
  }
  else if (showTime[1] != thisDate[1] || showTime[2] != thisDate[2]) {
    ret = ret + showTime[1] + '月' + showTime[2] + '日'
  }
  return ret
}

/**
 * 获取日期和时间
 */
export function getTimeInfo(showTime: number[], thisDate: number[], timeFormat24: boolean, showDate: boolean = true): string {
  var ret = showDate ? getDateInfo(showTime, thisDate) : ''
  if (timeFormat24) {
    return ret + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
  } else {
    if (showTime[3] < 12)
      return ret + '上午' + (showTime[3] < 10 ? '0' : '') + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    else {
      if (showTime[3] == 12)
        return ret + '下午' + showTime[3] + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
      else
        return ret + '下午' + ((showTime[3] - 12) < 10 ? '0' : '') + (showTime[3] - 12) + ':' + (showTime[4] < 10 ? '0' : '') + showTime[4]
    }
  }
}

export function getValidTimeInfo(thisEvent: EventResource, thisDate: number[], timeFormat24: boolean): string {
  var ret = ''

  if ((thisEvent.validStartTime[0] == thisEvent.validEndTime[0] &&
  thisEvent.validStartTime[1] == thisEvent.validEndTime[1] &&
  thisEvent.validStartTime[2] == thisEvent.validEndTime[2])) {
    ret = getDateInfo(thisEvent.validStartTime, thisDate)
    if (thisEvent.validStartTime[3] == 0 && thisEvent.validEndTime[3] == 23 &&
    thisEvent.validStartTime[4] == 0 && thisEvent.validEndTime[4] == 59)
      return ret + '全天'
    else
      return ret + getTimeInfo(thisEvent.validStartTime, thisDate, timeFormat24, false) + '-' + getTimeInfo(thisEvent.validEndTime, thisDate, timeFormat24, false)
  }
  return getTimeInfo(thisEvent.validStartTime, thisDate, timeFormat24) + '-' + getTimeInfo(thisEvent.validEndTime, thisDate, timeFormat24)
}

export function getDescription(thisEvent: EventResource, thisDate: number[], timeFormat24: boolean): string {
  var ret: string = getValidTimeInfo(thisEvent, thisDate, timeFormat24) + ' | ' + thisEvent.cyclicInfo
  if (!isNaN(thisEvent.doneTime[0])) {
    ret = ret + ' | ' + getTimeInfo(thisEvent.doneTime, thisDate, timeFormat24) + ' ' + '完成'
  }
  if (thisEvent.allTimes != 1) {
    ret = thisEvent.doneTimes.toString() + '/' + thisEvent.allTimes + ' | ' + ret
  }
  return ret
}

export function checkUrgent(thisEvent: EventResource, showDate: number[]): boolean {
  return (thisEvent.validEndTime[0] == showDate[0]) && (thisEvent.validEndTime[1] == showDate[1]) && (thisEvent.validEndTime[2] == showDate[2]) &&
  (thisEvent.validEndTime[3] != 23 || thisEvent.validEndTime[4] != 59)
}

export function checkQuadrant(thisEvent: EventResource, isImportant: boolean, isUrgent: boolean, showDate: number[]): boolean {
  // console.log("updateForm ", thisEvent.isImportant,  isImportant, thisEvent.checkUrgent(showDate), isUrgent)
  return thisEvent.isImportant == isImportant && checkUrgent(thisEvent, showDate) == isUrgent
}

/**
 * 获取前方状态⚪的类型和颜色
 * @param State 状态分类
 * @param Classify 颜色分类
 */
export function getStateResource(thisEvent: EventResource): Resource {
  switch (thisEvent.state) {
    case 2: {
      switch (thisEvent.classify) {
        case 'red':
          return $r('app.media.ic_todo_done_red')
        case 'orange':
          return $r('app.media.ic_todo_done_orange')
        case 'yellow':
          return $r('app.media.ic_todo_done_yellow')
        case 'green':
          return $r('app.media.ic_todo_done_green')
        case 'lakeBlue':
          return $r('app.media.ic_todo_done_lakeBlue')
        case 'lightBlue':
          return $r('app.media.ic_todo_done_lightBlue')
        case 'darkBlue':
          return $r('app.media.ic_todo_done_darkBlue')
        case 'purple':
          return $r('app.media.ic_todo_done_purple')
        default:
          return $r('app.media.ic_todo_done_black')
      }
    }
    case 1: {
      switch (thisEvent.classify) {
        case 'red':
          return $r('app.media.ic_todo_finish_red')
        case 'orange':
          return $r('app.media.ic_todo_finish_orange')
        case 'yellow':
          return $r('app.media.ic_todo_finish_yellow')
        case 'green':
          return $r('app.media.ic_todo_finish_green')
        case 'lakeBlue':
          return $r('app.media.ic_todo_finish_lakeBlue')
        case 'lightBlue':
          return $r('app.media.ic_todo_finish_lightBlue')
        case 'darkBlue':
          return $r('app.media.ic_todo_finish_darkBlue')
        case 'purple':
          return $r('app.media.ic_todo_finish_purple')
        default:
          return $r('app.media.ic_todo_finish_black')
      }
    }
    default: {
      switch (thisEvent.classify) {
        case 'red':
          return $r('app.media.ic_todo_wait_red')
        case 'orange':
          return $r('app.media.ic_todo_wait_orange')
        case 'yellow':
          return $r('app.media.ic_todo_wait_yellow')
        case 'green':
          return $r('app.media.ic_todo_wait_green')
        case 'lakeBlue':
          return $r('app.media.ic_todo_wait_lakeBlue')
        case 'lightBlue':
          return $r('app.media.ic_todo_wait_lightBlue')
        case 'darkBlue':
          return $r('app.media.ic_todo_wait_darkBlue')
        case 'purple':
          return $r('app.media.ic_todo_wait_purple')
        default:
          return $r('app.media.ic_todo_wait_black')
      }
    }
  }
}