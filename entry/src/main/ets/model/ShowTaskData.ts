import { formatTime } from '../dao/utils/FormatDateTime';
import { formatDate } from '../dao/utils/FormatDateTime';
/*
显示事件
 */
export class ShowTaskData {
    id2: number;
    startTime: string;
    endTime: string;
    validStartTime: string;
    validEndTime: string;
    completedCount: number;
    recentFinishedTime: string;
    id1: number;
    isFinish: boolean;
    remindDateTime?: string;

    constructor(id2: number, startTime: Date, endTime: Date,
                validStartTime: Date, validEndTime: Date,
                completedCount: number, recentFinishedTime: Date,
                id1: number, isFinish: boolean) {
        this.id2 = id2;
        this.startTime = formatDate(startTime);
        this.endTime = formatDate(endTime);
        this.validStartTime = formatTime(validStartTime);
        this.validEndTime = formatTime(validEndTime);
        this.completedCount = completedCount;
        this.recentFinishedTime = formatDate(recentFinishedTime) + " " + formatTime(recentFinishedTime);
        this.id1 = id1;
        this.isFinish = isFinish;
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
        return [parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2]),
        parseInt(time[0]), parseInt(time[1])];
    }

    getRemindDateTime(): number[] {
        let tmp: string[] = this.remindDateTime.split(" ", 2);
        let date: string[] = tmp[0].split("-", 3);
        let time: string[] = tmp[1].split(":", 2);
        return [parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2]),
        parseInt(time[0]), parseInt(time[1])];
    }
}

export function resultToShowTaskArray(resultSet): Array<ShowTaskData> {
    let showTaskArray: Array<ShowTaskData> = [];
    let countRow = resultSet.rowCount;
    resultSet.goToFirstRow();
    for (let i = 0;i < countRow; i++) {
        let tmp: ShowTaskData = new ShowTaskData(0, new Date(), new Date(), new Date(), new Date(),
            0, new Date(), 0, false);
        tmp.id2 = resultSet.getDouble(resultSet.getColumnIndex("id2"));
        tmp.startTime = resultSet.getString(resultSet.getColumnIndex("startTime"));
        tmp.endTime = resultSet.getString(resultSet.getColumnIndex("endTime"));
        tmp.validStartTime = resultSet.getString(resultSet.getColumnIndex("validStartTime"));
        tmp.validEndTime = resultSet.getString(resultSet.getColumnIndex("validEndTime"));
        tmp.completedCount = resultSet.getDouble(resultSet.getColumnIndex("completedCount"));
        tmp.recentFinishedTime = resultSet.getString(resultSet.getColumnIndex("recentFinishedTime"));
        tmp.id1 = resultSet.getDouble(resultSet.getColumnIndex("id1"));
        tmp.isFinish = resultSet.getDouble(resultSet.getColumnIndex("isFinish")) ? true : false;

        console.info("[BianDanAPP] [verbose] tag:ShowTaskData--ShowTaskImpl msg:resultToShowTaskArray " + i + ": " + JSON.stringify(tmp));
        showTaskArray.push(tmp);
        resultSet.goToNextRow();
    }
    return showTaskArray;
}

export function resultToSTArray(resultSet): Array<any> {
    //    id2: number;
    //    startTime: string;
    //    endTime: string;
    //    validStartTime: string;
    //    validEndTime: string;
    //    completedCount: number;
    //    recentFinishedTime: string;
    //    id1: number;
    //    isFinish: boolean;
    let showTaskArray: Array<[number, string, string, string, string, number, string, number, boolean]> = [];
    let countRow = resultSet.rowCount;
    resultSet.goToFirstRow();
    for (let i = 0;i < countRow; i++) {
        let tmp: [number, string, string, string, string, number, string, number, boolean]
            = [0, "", "", "", "", 0, "", 0, false];
        tmp[0] = resultSet.getDouble(resultSet.getColumnIndex("id2"));
        tmp[1] = resultSet.getString(resultSet.getColumnIndex("startTime"));
        tmp[2] = resultSet.getString(resultSet.getColumnIndex("endTime"));
        tmp[3] = resultSet.getString(resultSet.getColumnIndex("validStartTime"));
        tmp[4] = resultSet.getString(resultSet.getColumnIndex("validEndTime"));
        tmp[5] = resultSet.getDouble(resultSet.getColumnIndex("completedCount"));
        tmp[6] = resultSet.getString(resultSet.getColumnIndex("recentFinishedTime"));
        tmp[7] = resultSet.getDouble(resultSet.getColumnIndex("id1"));
        tmp[8] = resultSet.getDouble(resultSet.getColumnIndex("isFinish")) ? true : false;

        console.info("[BianDanAPP] [verbose] tag:ShowTaskData--ShowTaskImpl msg:resultToShowTaskArray " + i + ": " + JSON.stringify(tmp));
        showTaskArray.push(tmp);
        resultSet.goToNextRow();
    }
    return showTaskArray;


}

