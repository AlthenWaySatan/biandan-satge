export default class EventResource {
    eventId: number //事项ID
    folderId: number //待办单ID
    state: number //完成状态：0待完成，1正在完成，2已完成
    classify: string //待办单颜色分类
    title: string //标题
    isImportant: boolean //是否重要
    isCollected: boolean //是否收藏
    isClock: boolean //是否提醒
    validStartTime: number[]
    validEndTime: number[]
    cyclicInfo: string //重复信息
    doneTime: number[] //完成时间
    isCyclic: boolean //是否重复
    doneTimes: number //完成次数
    allTimes: number //全部次数
    isChecked: boolean //是否被选择

    constructor(
        thingsId: number,
        folderId: number,
        state: number,
        classify: string,
        title: string,
        isImportant: boolean,
        isCollected: boolean,
        isClock: boolean,
        validStartTime: number[],
        validEndTime: number[],
        cyclicInfo: string,
        doneTime: number[],
        isCyclic: boolean,
        doneTimes: number = 0,
        allTimes: number = 1) {
        this.eventId = thingsId
        this.folderId = folderId
        this.state = state
        this.classify = classify
        this.title = title
        this.isImportant = isImportant
        this.isCollected = isCollected
        this.isClock = isClock
        this.validStartTime = validStartTime
        this.validEndTime = validEndTime
        this.cyclicInfo = cyclicInfo
        this.doneTime = doneTime
        this.isCyclic = isCyclic
        this.doneTimes = doneTimes
        this.allTimes = allTimes
        this.isChecked = false
    }

    /**
     * 获取日期和时间
     */
    private getDateInfo(showTime: number[], thisDate: number[]): string {
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
    private getTimeInfo(showTime: number[], thisDate: number[], timeFormat24: boolean, showDate: boolean = true): string {
        var ret = showDate ? this.getDateInfo(showTime, thisDate) : ''
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

    public getValidTimeInfo(thisDate: number[], timeFormat24: boolean): string {
        var ret = ''

        if ((this.validStartTime[0] == this.validEndTime[0] &&
        this.validStartTime[1] == this.validEndTime[1] &&
        this.validStartTime[2] == this.validEndTime[2])) {
            ret = this.getDateInfo(this.validStartTime, thisDate)
            if (this.validStartTime[3] == 0 && this.validEndTime[3] == 23 &&
            this.validStartTime[4] == 0 && this.validEndTime[4] == 59)
                return ret + '全天'
            else
                return ret + this.getTimeInfo(this.validStartTime, thisDate, timeFormat24, false) + '-' + this.getTimeInfo(this.validEndTime, thisDate, timeFormat24, false)
        }
        return this.getTimeInfo(this.validStartTime, thisDate, timeFormat24) + '-' + this.getTimeInfo(this.validEndTime, thisDate, timeFormat24)
    }

    public getDescription(thisDate: number[], timeFormat24: boolean): string {
        var ret: string = this.getValidTimeInfo(thisDate, timeFormat24) + ' | ' + this.cyclicInfo
        if (!isNaN(this.doneTime[0])) {
            ret = ret + ' | ' + this.getTimeInfo(this.doneTime, thisDate, timeFormat24) + ' ' + '完成'
        }
        if (this.allTimes != 1) {
            ret = this.doneTimes.toString() + '/' + this.allTimes + ' | ' + ret
        }
        return ret
    }

    public checkUrgent(showDate: number[]): boolean {
        return (this.validEndTime[0] == showDate[0]) && (this.validEndTime[1] == showDate[1]) && (this.validEndTime[2] == showDate[2]) &&
        (this.validEndTime[3] != 23 || this.validEndTime[4] != 59)
    }

    public checkQuadrant(isImportant: boolean, isUrgent: boolean, showDate: number[]): boolean {
        return this.isImportant == isImportant && this.checkUrgent(showDate) == isUrgent
    }

    /**
     * 获取前方状态⚪的类型和颜色
     * @param State 状态分类
     * @param Classify 颜色分类
     */
    public getStateResource(): Resource {
        switch (this.state) {
            case 2: {
                switch (this.classify) {
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
                switch (this.classify) {
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
                switch (this.classify) {
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
}