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
}