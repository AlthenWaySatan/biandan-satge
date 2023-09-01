/**
 * 待办内容
 */
export class EventInfo {
    id2: number;
    completedCount: number;
    eventState: number;
    title: string;
    isCollectible: boolean;
    isImportant: boolean;
    startTime: string;
    endTime: string;
    validStartTime: string;
    validEndTime: string;
    unitTimeNumber: number;
    isLoop: boolean;
    loopSet: number;
    loopBaseNumber: number;
    loopUnit: number;
    loopDate: string[];
    isRemind: boolean;
    id3: number;
    favoritesColor: string;
    recentFinishedTime: string;

    constructor() {
    }

    getStartTimeDate(): number[] {
        let date: string[] = this.startTime.split("-", 3);
        return [parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2])];
    }

    getEndTimeDate(): number[] {
        let date: string[] = this.endTime.split("-", 3);
        return [parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2])];
    }

    getValidStartTime(): number[] {
        let time: string[] = this.validStartTime.split(":", 2);
        return [parseInt(time[0]), parseInt(time[1])];
    }

    getValidEndTime(): number[] {
        let time: string[] = this.validEndTime.split(":", 2);
        return [parseInt(time[0]), parseInt(time[1])];
    }

    getRecentFinishedTime(): number[] {
        let tmp: string[] = this.recentFinishedTime.split(" ", 2);
        let date: string[] = tmp[0].split("-", 3);
        let time: string[] = tmp[1].split(":", 2);
        return [parseInt(date[0]), parseInt(date[1]), parseInt(date[2]), parseInt(time[0]), parseInt(time[1])];
    }
}

export function resultToEventInfo(resultSet): Array<EventInfo> {
    let eventInfoArray: Array<EventInfo> = [];
    let countRow = resultSet.rowCount;
    resultSet.goToFirstRow();
    for (let i = 0;i < countRow; i++) {
        let tmp: EventInfo = new EventInfo();
        tmp.id2 = resultSet.getDouble(resultSet.getColumnIndex("id2"));
        let isFinish: boolean = resultSet.getDouble(resultSet.getColumnIndex("isFinish")) ? true : false;
        tmp.unitTimeNumber = resultSet.getDouble(resultSet.getColumnIndex("unitTimeNumber"));
        tmp.completedCount = resultSet.getDouble(resultSet.getColumnIndex("completedCount"));
        //  显示待办的状态：eventState（｛0：未完成，1：完成了一部分， 2：已完成｝），
        if (tmp.completedCount >= tmp.unitTimeNumber) {
            isFinish == true;
            tmp.eventState = 2;
        } else if (tmp.completedCount > 0) {
            tmp.eventState = 1;
        } else {
            tmp.eventState = 0;
        }

        tmp.title = resultSet.getString(resultSet.getColumnIndex("taskTitle"));
        tmp.isCollectible = resultSet.getDouble(resultSet.getColumnIndex("isCollectible")) ? true : false;
        tmp.isImportant = resultSet.getDouble(resultSet.getColumnIndex("isImportant")) ? true : false;
        tmp.startTime = resultSet.getString(resultSet.getColumnIndex("startTime"));
        tmp.endTime = resultSet.getString(resultSet.getColumnIndex("endTime"));
        tmp.isLoop = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false;
        tmp.loopSet = resultSet.getDouble(resultSet.getColumnIndex("loopSet"));
        tmp.loopBaseNumber = resultSet.getDouble(resultSet.getColumnIndex("loopBaseNumber"));
        tmp.loopUnit = resultSet.getDouble(resultSet.getColumnIndex("loopUnit"));
        let taskLoopDate: string = resultSet.getString(resultSet.getColumnIndex("loopDate"));
        tmp.loopDate = taskLoopDate.split(",");
        tmp.isRemind = resultSet.getDouble(resultSet.getColumnIndex("isRemind")) ? true : false;
        tmp.id3 = resultSet.getDouble(resultSet.getColumnIndex("id3"));
        if (tmp.id3 <= 1) {
            tmp.id3 = -1;
        }
        tmp.favoritesColor = resultSet.getString(resultSet.getColumnIndex("favoritesColor"));
        tmp.validStartTime = resultSet.getString(resultSet.getColumnIndex("validStartTime"));
        tmp.validEndTime = resultSet.getString(resultSet.getColumnIndex("validEndTime"));
        tmp.recentFinishedTime = resultSet.getString(resultSet.getColumnIndex("recentFinishedTime"));

        console.info("[BianDanAPP] [verbose] tag:EventInfo--ShowTaskImpl msg:resultToEventInfo " + i + ": " + JSON.stringify(tmp));
        eventInfoArray.push(tmp);
        resultSet.goToNextRow();
    }
    return eventInfoArray;
}