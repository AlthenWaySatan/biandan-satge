import { TaskData } from './TaskData';
import EventResource from './EventsResourceContact';

const userCyclePeriod: string[] = ['天', '周', '月', '年']
const weekResource: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']

export default class CreateResource {

    id1: number = 0

    name: string = '' //当前标题
    thisFolderId: number = -1 //当前文件夹ID
    isCollect: boolean = false //是否收藏
    isImportant: boolean = false //是否重要
    thisDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())] //当前日期
    comment: string = '' //当前备注
    /**
     * 提醒
     */
    clockState: number = 0 //提醒模式
    clockTime: number[] = [this.thisDate[0], this.thisDate[1], this.thisDate[2], (new Date().getHours()), (new Date().getMinutes())] //提醒时间
    clockTimeLong: number[] = [0, 0] //提醒
    /**
     * 重复
     */
    cycleState: number = 0 //重复模式
    cycleStartDate: number[] = this.thisDate //重复开始时间
    cycleEndDate: number[] //重复结束时间
    cycleBaseNumber: number = 1 //自定义重复基数
    cycleUnit: number = 1 //自定义重复单位
    cycleDate: number[] = [] //重复具体日期
    tempDate: number[] = [1, 1] //临时日期变量
    cycleDateYear: string[] = [] //重复具体日期_年
    cycleYearShow: boolean = false //是否展示重复具体日期_年的选择界面
    cycleDateLimit: number = 1 //时限
    /**
     * 有效时间
     */
    validStartTime: number[] = [this.thisDate[0], this.thisDate[1], this.thisDate[2], 0, 0] //有效开始时间
    validEndTime: number[] = [this.thisDate[0], this.thisDate[1], this.thisDate[2], 23, 59] //有效结束时间
    /**
     * 次数
     */
    countNumber: number = 1 //次数

    constructor(
        cycleEndDate: number[],
        name: string = '',
        thisFolderId: number = -1,
        isCollect: boolean = false,
        isImportant: boolean = false,
        thisDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())],
        comment: string = '',
        /**
         * 提醒
         */
        clockState: number = 0,
        clockTime: number[] = [thisDate[0], thisDate[1], thisDate[2], (new Date().getHours()), (new Date().getMinutes())],
        clockTimeLong: number[] = [0, 0],
        /**
         * 重复
         */
        cycleState: number = 0,
        cycleStartDate: number[] = thisDate,
        cycleBaseNumber: number = 1,
        cycleUnit: number = 1,
        cycleDate: number[] = [],
        tempDate: number[] = [1, 1],
        cycleDateYear: string[] = [],
        cycleYearShow: boolean = false,
        cycleDateLimit: number = 1,
        /**
         * 有效时间
         */
        validStartTime: number[] = [thisDate[0], thisDate[1], thisDate[2], 0, 0],
        validEndTime: number[] = [thisDate[0], thisDate[1], thisDate[2], 23, 59]
    ) {
        this.name = name
        this.thisFolderId = thisFolderId
        this.isCollect = isCollect
        this.isImportant = isImportant
        this.thisDate = thisDate
        this.comment = comment

        this.clockState = clockState
        this.clockTime = clockTime
        this.clockTimeLong = clockTimeLong

        this.cycleState = cycleState
        this.cycleStartDate = cycleStartDate

        this.cycleEndDate = cycleEndDate

        this.cycleBaseNumber = cycleBaseNumber
        this.cycleUnit = cycleUnit
        this.cycleDate = cycleDate
        this.tempDate = tempDate
        this.cycleDateYear = cycleDateYear
        this.cycleYearShow = cycleYearShow
        this.cycleDateLimit = cycleDateLimit

        this.validStartTime = validStartTime
        this.validEndTime = validEndTime
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

    public setDate(year: number, month: number, day: number, defineCycleLength: number) {
        this.thisDate = [year, month, day] //当前日期
        this.clockTime = [this.thisDate[0], this.thisDate[1], this.thisDate[2], (new Date().getHours()), (new Date().getMinutes())] //提醒时间
        this.cycleStartDate = this.thisDate //重复开始时间
        this.cycleEndDate = this.getNextNDay(this.thisDate[0], this.thisDate[1], this.thisDate[2], defineCycleLength) //重复结束时间
        this.validStartTime = [this.thisDate[0], this.thisDate[1], this.thisDate[2], 0, 0] //有效开始时间
        this.validEndTime = [this.thisDate[0], this.thisDate[1], this.thisDate[2], 23, 59] //有效结束时间
    }

    /**
     * 获取日期
     */
    public getShowDate(): string {
        if (this.thisDate[0] == (new Date().getFullYear())) {
            return this.thisDate[1] + '月' + this.thisDate[2] + '日';
        }
        else {
            return this.thisDate[0] + '年' + this.thisDate[1] + '月' + this.thisDate[2] + '日';
        }
    }

    /**
     * 获取日期和时间
     */
    private getTimeInfo(showTime: number[], timeFormat24: boolean, showDate: boolean = true): string {
        var ret = showDate ? this.getDateInfo(showTime) : ''
        if (timeFormat24) {
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

    /**
     * 获取日期
     */
    public getDateInfo(showTime: number[], showToday: boolean = false): string {
        if (showTime[0] != this.thisDate[0])
            return showTime[0] + '年' + showTime[1] + '月' + showTime[2] + '日'
        if (showTime[1] != this.thisDate[1] || showTime[2] != this.thisDate[2])
            return showTime[1] + '月' + showTime[2] + '日'
        if (showToday)
            return '今天'
        return ''
    }
    /**
     * 获取日期
     */
    public getDateInfoThis(showTime: number[]): string {
        if (showTime[0] != new Date().getFullYear())
            return showTime[0] + '年' + showTime[1] + '月' + showTime[2] + '日'
        else if (showTime[1] != new Date().getMonth() + 1 || showTime[2] != new Date().getDate())
            return showTime[1] + '月' + showTime[2] + '日'
        else
            return '今天'
    }
    /**
     * 获取提醒的描述
     */
    public getClockInfo(timeFormat24: boolean): string {
        switch (this.clockState) {
            case 0:
                return '不提醒'
            case 1:
                return '提前' + (this.clockTimeLong[0] > 0 ? this.clockTimeLong[0] + '时' : '') + this.clockTimeLong[1] + '分提醒'
            case 2:
                return this.getTimeInfo(this.clockTime, timeFormat24) + '提醒'
        }
    }

    /**
     * 获取重复的描述
     */
    public getCycleInfo(FirstDayOfWeek: number): string {
        switch (this.cycleState) {
            case 0:
                return '仅一次'
            case 2:
                return '每个非周末'
            case 3:
                return '每个周末'
            case 4:
                return '每天'
            case 5:
                return '艾宾浩斯'
            default:
                return this.getUserCycleData(FirstDayOfWeek)
        }
    }

    /**
     * 获取自定义重复周期
     */
    public getUserCyclePeriod(): string {
        return '每 ' + this.cycleBaseNumber + ' ' + userCyclePeriod[this.cycleUnit - 1]
    }

    /**
     * 获取自定义重复内容
     */
    public getUserCycleData(FirstDayOfWeek: number): string {
        var ret = '每' + userCyclePeriod[this.cycleUnit - 1] + '的'
        if (this.cycleBaseNumber > 1) {
            ret = this.getUserCyclePeriod() + '的'
        }
        if ((this.cycleUnit != 4 && this.cycleDate.length == 0) || (this.cycleUnit == 4 && this.cycleDateYear.length == 0)) {
            ret = ret + '...'
        }
        if (this.cycleUnit == 1) {
            return this.getUserCyclePeriod()
        } else if (this.cycleUnit == 2) {
            let count = this.cycleDate.length
            for (let i = FirstDayOfWeek == 1 ? 0 : 1;i < 7; i++) {
                if (this.cycleDate.indexOf(i) != -1) {
                    ret = ret + weekResource[i];
                    if (-- count != 0)
                        ret = ret + '，'
                }
            }
            if (FirstDayOfWeek != 1) {
                if (this.cycleDate.indexOf(0) != -1) {
                    ret = ret + weekResource[0];
                    if (-- count != 0)
                        ret = ret + '，'
                }
            }
        } else if (this.cycleUnit == 3) {
            if (this.cycleDate.length != 0) {
                ret = ret + '第'
                let count = this.cycleDate.length
                for (let i = 1;i <= 31; i++) {
                    if (this.cycleDate.indexOf(i) != -1) {
                        ret = ret + i.toString();
                        if (-- count != 0)
                            ret = ret + '，'
                    }
                }
                ret = ret + '天'
            }
        } else {
            for (let i = 0;i < this.cycleDateYear.length; i++) {
                ret = ret + this.cycleDateYear[i];
                if (i != this.cycleDateYear.length - 1)
                    ret = ret + '，'
            }
        }
        return ret
    }

    /**
     * 获取有效时间
     */
    public getValidTimeInfo(timeFormat24: boolean): string {
        var ret = ''

        if ((this.validStartTime[0] == this.validEndTime[0] &&
        this.validStartTime[1] == this.validEndTime[1] &&
        this.validStartTime[2] == this.validEndTime[2])) {
            ret = this.getDateInfo(this.validStartTime)
            if (this.validStartTime[3] == 0 && this.validEndTime[3] == 23 &&
            this.validStartTime[4] == 0 && this.validEndTime[4] == 59)
                return ret + '全天'
            else
                return ret + this.getTimeInfo(this.validStartTime, timeFormat24, true) + '-' + this.getTimeInfo(this.validEndTime, timeFormat24, false)
        }
        return this.getTimeInfo(this.validStartTime, timeFormat24) + '-' + this.getTimeInfo(this.validEndTime, timeFormat24)
    }

    private numbersToDate(dateNumber: number[]): Date {
        if (dateNumber.length > 3)
            return new Date(dateNumber[0], dateNumber[1] - 1, dateNumber[2], dateNumber[3], dateNumber[4])
        else
            return new Date(dateNumber[0], dateNumber[1] - 1, dateNumber[2])
    }

    public toTaskData(): TaskData {
        let id1: number = this.id1
        let taskTitle: string = this.name
        let taskContent: string = this.comment
        let id3: number = this.thisFolderId
        let isCollectible: boolean = this.isCollect
        let isImportant: boolean = this.isImportant
        let startTime: Date
        let endTime: Date
        if (this.cycleState != 0) {
            startTime = this.numbersToDate(this.cycleStartDate)
            endTime = this.numbersToDate(this.cycleEndDate)
        } else {
            startTime = this.numbersToDate(this.validStartTime)
            endTime = this.numbersToDate(this.validEndTime)
        }
        let isLoop: boolean = (this.cycleState != 0)
        let unitTimeNumber: number = this.countNumber
        let validStartTime: Date = this.numbersToDate(this.validStartTime)
        let validEndTime: Date = this.numbersToDate(this.validEndTime)
        let loopSet: number = this.cycleState
        let loopBaseNumber: number = this.cycleBaseNumber
        let loopUnit: number = this.cycleUnit
        let loopDate: string[] = []
        if (this.cycleUnit == 4) {
            loopDate = this.cycleDateYear
        } else {
            if (this.cycleDate != null) {
                for (let i = 0;i < this.cycleDate.length; i++) {
                    console.log(this.cycleDate[i].toString())
                    if (!isNaN(this.cycleDate[i])) {
                        loopDate.push(this.cycleDate[i].toString())
                    }
                }
            }
        }
        let duration: number = this.cycleDateLimit
        let isRemind: boolean = this.clockState != 0
        let remindDate: Date = this.numbersToDate(this.clockTime)
        let remindTime: Date = this.numbersToDate(this.clockTime);
        if (this.clockState == 1) {
            let clockTime = this.numbersToDate(this.validStartTime);
            clockTime = new Date(clockTime.getFullYear(), clockTime.getMonth(), clockTime.getDate(),
                clockTime.getHours() - this.clockTimeLong[0],
                clockTime.getMinutes() - this.clockTimeLong[1])
            remindTime = clockTime
        }
        let isFinish: boolean = false
        console.log('======>')

        let ret: TaskData
        ret = new TaskData(id1, taskTitle, taskContent, id3,
            isCollectible, isImportant,
            startTime, endTime, isLoop, unitTimeNumber,
            validStartTime, validEndTime, loopSet, loopBaseNumber,
            loopUnit, loopDate, duration,
            isRemind, remindDate, remindTime, isFinish)

        return ret
    }
}