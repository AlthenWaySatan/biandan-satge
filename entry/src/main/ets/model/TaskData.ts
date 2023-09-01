import { formatTime } from '../dao/utils/FormatDateTime';
import { formatDate } from '../dao/utils/FormatDateTime';
/*
创建事件
 */
export class TaskData {
    id1: number;
    taskTitle: string;
    taskContent: string;
    id3: number;
    isCollectible: boolean;
    isImportant: boolean;
    startTime: string;
    endTime: string;
    isLoop: boolean;
    unitTimeNumber: number;
    validStartTime: string;
    validEndTime: string;
    loopSet: number; //0-仅一次;1-自定义;2-每个非周末;3-每个周末;4-每天;5-艾宾浩斯
    loopBaseNumber: number;
    loopUnit: number; //1-天，2-周，3-月，4年
    loopDate: string[];
    duration: number;
    isRemind: boolean;
    remindDate: string;
    remindTime: string;
    isFinish: boolean;


    constructor(id1: number, taskTitle: string, taskContent: string, id3: number,
                isCollectible: boolean, isImportant: boolean,
                startTime: Date, endTime: Date, isLoop: boolean, unitTimeNumber: number,
                validStartTime: Date, validEndTime: Date, loopSet: number, loopBaseNumber: number,
                loopUnit: number, loopDate: string[], duration: number,
                isRemind: boolean, remindDate: Date, remindTime: Date, isFinish: boolean) {
        this.id1 = id1;
        this.taskTitle = taskTitle;
        this.taskContent = taskContent;
        if (id3 <= 1) {
            this.id3 = 1;
        } else {
            this.id3 = id3;
        }
        this.isCollectible = isCollectible;
        this.isImportant = isImportant;
        this.startTime = formatDate(startTime);
        this.endTime = formatDate(endTime);
        this.isLoop = isLoop;
        this.unitTimeNumber = unitTimeNumber;
        if (this.unitTimeNumber <= 0) {
            this.unitTimeNumber = 1;
        }
        this.validStartTime = formatTime(validStartTime);
        this.validEndTime = formatTime(validEndTime);
        this.loopSet = loopSet;
        this.loopBaseNumber = loopBaseNumber;
        this.loopUnit = loopUnit;
        this.loopDate = loopDate;
        this.duration = duration;
        this.isRemind = isRemind;
        this.remindDate = formatDate(remindDate);
        this.remindTime = formatTime(remindTime);
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

    getRemindDate(): number[] {
        let date: string[] = this.remindDate.split("-", 3);
        return [parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2])];
    }

    getRemindTime(): number[] {
        let time: string[] = this.remindTime.split(":", 2);
        return [parseInt(time[0]), parseInt(time[1])];
    }
}

export function resultToTaskData(resultSet): Array<TaskData> {
    let taskArray: Array<TaskData> = [];
    resultSet.goToFirstRow();
    for (let i = 0;i < resultSet.rowCount; i++) {
        let tmp: TaskData = new TaskData(0, " ", " ", 1, false, false,
            new Date(), new Date(), false, 0, new Date(), new Date(),
            0, 0, 0, [""], 1, false, new Date(), new Date(), false);

        tmp.id1 = resultSet.getDouble(resultSet.getColumnIndex("id1"));
        tmp.taskTitle = resultSet.getString(resultSet.getColumnIndex("taskTitle"));
        tmp.taskContent = resultSet.getString(resultSet.getColumnIndex("taskContent"));
        tmp.id3 = resultSet.getDouble(resultSet.getColumnIndex("id3"));
        if (tmp.id3 <= 1) {
            tmp.id3 = -1;
        }
        tmp.isImportant = resultSet.getDouble(resultSet.getColumnIndex('isImportant')) ? true : false;
        tmp.isCollectible = resultSet.getDouble(resultSet.getColumnIndex("isCollectible")) ? true : false;
        tmp.startTime = resultSet.getString(resultSet.getColumnIndex("startTime"));
        tmp.endTime = resultSet.getString(resultSet.getColumnIndex("endTime"));
        tmp.isLoop = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false;
        tmp.unitTimeNumber = resultSet.getDouble(resultSet.getColumnIndex("unitTimeNumber"));
        tmp.validStartTime = resultSet.getString(resultSet.getColumnIndex("validStartTime"));
        tmp.validEndTime = resultSet.getString(resultSet.getColumnIndex("validEndTime"));
        tmp.loopSet = resultSet.getDouble(resultSet.getColumnIndex("loopSet"));
        tmp.loopBaseNumber = resultSet.getDouble(resultSet.getColumnIndex("loopBaseNumber"));
        tmp.loopUnit = resultSet.getDouble(resultSet.getColumnIndex("loopUnit"));
        let taskLoopDate: string = resultSet.getString(resultSet.getColumnIndex("loopDate"));
        tmp.loopDate = taskLoopDate.split(",");
        tmp.duration = resultSet.getDouble(resultSet.getColumnIndex("duration"));
        tmp.isRemind = resultSet.getDouble(resultSet.getColumnIndex("isRemind")) ? true : false;
        tmp.remindDate = resultSet.getString(resultSet.getColumnIndex("remindDate"));
        tmp.remindTime = resultSet.getString(resultSet.getColumnIndex("remindTime"));
        tmp.isFinish = resultSet.getDouble(resultSet.getColumnIndex("isFinish")) ? true : false;

        console.info("[BianDanAPP] [verbose] tag:TaskData--TaskImpl msg:resultToTaskData " + i + ": " + JSON.stringify(tmp));
        taskArray.push(tmp);
        resultSet.goToNextRow();
    }
    return taskArray;
}

export function resultToTArray(resultSet): Array<any> {
    //    id1: number;
    //    taskTitle: string;
    //    taskContent: string;
    //    id3: number;
    //    isCollectible: boolean;
    //    isImportant: boolean;
    //    startTime: string;
    //    endTime: string;
    //    isLoop: boolean;
    //    unitTimeNumber: number;
    //    validStartTime: string;
    //    validEndTime: string;
    //    loopSet: number; //0-仅一次;1-自定义;2-每个非周末;3-每个周末;4-每天;5-艾宾浩斯
    //    loopBaseNumber: number;
    //    loopUnit: number; //1-天，2-周，3-月，4年
    //    loopDate: string[];
    //    duration: number;
    //    isRemind: boolean;
    //    remindDate: string;
    //    remindTime: string;
    //    isFinish: boolean;
    let taskArray: Array<[number, string, string, number, boolean, boolean,
        string, string, boolean, number,
        string, string, number, number, number, string[], number
        , boolean, string, string, boolean]> = [];
    resultSet.goToFirstRow();
    for (let i = 0;i < resultSet.rowCount; i++) {
        let tmp: [number, string, string, number, boolean, boolean,
            string, string, boolean, number,
            string, string, number, number, number, string[], number
            , boolean, string, string, boolean]
            = [0, "", "", 1, false, false,
            "", "", false, 0,
            "", "", 0, 0, 0, [], 1,
            false, "", "", false];

        tmp[0] = resultSet.getDouble(resultSet.getColumnIndex("id1"));
        tmp[1] = resultSet.getString(resultSet.getColumnIndex("taskTitle"));
        tmp[2] = resultSet.getString(resultSet.getColumnIndex("taskContent"));
        tmp[3] = resultSet.getDouble(resultSet.getColumnIndex("id3"));
        if (tmp[3] <= 1) {
            tmp[3] = -1;
        }
        tmp[4] = resultSet.getDouble(resultSet.getColumnIndex('isImportant')) ? true : false;
        tmp[5] = resultSet.getDouble(resultSet.getColumnIndex("isCollectible")) ? true : false;
        tmp[6] = resultSet.getString(resultSet.getColumnIndex("startTime"));
        tmp[7] = resultSet.getString(resultSet.getColumnIndex("endTime"));
        tmp[8] = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false;
        tmp[9] = resultSet.getDouble(resultSet.getColumnIndex("unitTimeNumber"));
        tmp[10] = resultSet.getString(resultSet.getColumnIndex("validStartTime"));
        tmp[11] = resultSet.getString(resultSet.getColumnIndex("validEndTime"));
        tmp[12] = resultSet.getDouble(resultSet.getColumnIndex("loopSet"));
        tmp[13] = resultSet.getDouble(resultSet.getColumnIndex("loopBaseNumber"));
        tmp[14] = resultSet.getDouble(resultSet.getColumnIndex("loopUnit"));
        let taskLoopDate: string = resultSet.getString(resultSet.getColumnIndex("loopDate"));
        tmp[15] = taskLoopDate.split(",");
        tmp[16] = resultSet.getDouble(resultSet.getColumnIndex("duration"));
        tmp[17] = resultSet.getDouble(resultSet.getColumnIndex("isRemind")) ? true : false;
        tmp[18] = resultSet.getString(resultSet.getColumnIndex("remindDate"));
        tmp[19] = resultSet.getString(resultSet.getColumnIndex("remindTime"));
        tmp[20] = resultSet.getDouble(resultSet.getColumnIndex("isFinish")) ? true : false;

        console.info("[BianDanAPP] [verbose] tag:TaskData--TaskImpl msg:resultToTaskData " + i + ": " + JSON.stringify(tmp));
        taskArray.push(tmp);
        resultSet.goToNextRow();
    }
    return taskArray;
}

