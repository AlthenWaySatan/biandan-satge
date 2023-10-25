import { initTable } from './InitAndTable';
import Logger from '../utils/log/Logger';
import { resultToShowTaskArray } from '../../model/ShowTaskData';
import { formatTime } from '../utils/FormatDateTime';
import { formatDate } from '../utils/FormatDateTime';
import TaskTable from '../database/tables/TaskTable';
import { resultToEventInfo } from '../../model/EventInfo';
import { EventInfo } from '../../model/EventInfo';
import { RdbCommon } from '../../model/RdbCommon';
import ShowTaskTable from '../database/tables/ShowTaskTable';
import { ShowTaskData } from '../../model/ShowTaskData';
import { TaskData } from '../../model/TaskData';
import { ShowTaskInterface } from './Interface/ShowTaskInterface';

export class ShowTaskImpl implements ShowTaskInterface {
//    private showTaskTable = new ShowTaskTable();
//    private taskTable = new TaskTable();

    constructor(context) {
        initTable.showTaskTable.getRdbStore(context);
    }

    /**
     * 向showTask表中插入一项显示事项
     * @param showTaskData
     * @para callback(id2,flag,reason)
     */
    insert(showTaskData: ShowTaskData, callback: Function): void {
        initTable.showTaskTable.insertData(showTaskData, (id2, flag, reason) => {
            if (flag) {
                showTaskData.id2 = id2;
                Logger.info("ShowTaskImpl", " insert newShowTaskData success:" + JSON.stringify(showTaskData));
            }
            callback(id2, flag, reason);
        });
    }

    /**
     * 删除一个事项,若其是个不循环事项，则创建表也删除;若是个循环事项，则只删除显示事项
     * @para id2
     * @para callback(flag,reason)
     */
    deleteSingleShow(id2: number, callback: Function) {
        let showTaskId2: number = id2;
        this.queryID1ByID2(showTaskId2, (id1, isLoop, unitTimeNumber) => {
            if (id1 <= -1) {
                callback(false, "未知错误");
                return;
            }

            let taskId1 = id1;
            let taskIsLoop = isLoop;
            initTable.showTaskTable.deleteDate(showTaskId2, (flag1, reason1) => {
                if (flag1 && (!taskIsLoop)) {
                    Logger.info("ShowTaskImpl", "delete showTask success! id2:" + id2);
                    //开始删除task中的事项
                    initTable.taskTable.deleteDate(taskId1, (flag2, reason2) => {
                        if (flag2) {
                            Logger.info("ShowTaskImpl", "delete Task success! id1:" + taskId1);
                            callback(true, "事项删除成功")
                            return;
                        }
                        callback(flag2, reason2)
                    })
                    return;
                }
                callback(flag1, reason1)
            })
        });
    }

    /**
     * 删除整个循环事项
     * @para id2
     * @para callback(flag,reason)
     */
    deleteAll(id2: number, callback: Function): void {
        let showTaskId2: number = id2;
        this.queryID1ByID2(showTaskId2, (id1, isLoop, unitTimeNumber) => {
            if (id1 <= -1) {
                callback(false, "未知错误");
                return;
            }

            let taskId1 = id1;
            initTable.showTaskTable.deleteDate(0, (flag1, reason1) => {
                if (flag1) {
                    Logger.info("ShowTaskImpl", "delete AllLoopTask success! by id2:" + id2);
                    //开始删除task中的事项
                    initTable.taskTable.deleteDate(taskId1, (flag2, reason2) => {
                        if (flag2) {
                            Logger.info("TaskImpl", "delete task success! id1:" + taskId1);
                            callback(true, "事项删除成功")
                            return;
                        }
                        callback(flag2, reason2)
                    })
                    return;
                }
                callback(flag1, reason1)
            }, taskId1);
        });
    }

    /*
    * 更新showTask中的信息
    * 完成次数+1
    * 需判断这个显示事件是否已完成
    * @param recentFinishedTime 'xxxx-xx-xx xx:xx:xx' 单引号 年-月-日 时:分:秒
    * @para callback(flag,reason)
     */
    addCompleteCount(id2: number, dateTime: Date, callback: Function): void {
        let showTaskId2: number = id2;
        let recentFinishedTime: string = formatDate(dateTime) + " " + formatTime(dateTime);
        this.queryID1ByID2(showTaskId2, (id1: number, isLoop: boolean, unitTimeNumber: number) => {
            this.queryShowTaskById2(showTaskId2, (showTaskData: ShowTaskData) => {
                if (showTaskData != null) {
                    showTaskData.completedCount = showTaskData.completedCount + 1;
                    showTaskData.recentFinishedTime = recentFinishedTime;
                    if (showTaskData.completedCount >= unitTimeNumber) {
                        showTaskData.isFinish = true;
                    }
                    let promise = initTable.showTaskTable.update(showTaskData);
                    promise.then((ret) => {
                        Logger.info("ShowTaskImpl", "addCompleteCount success rowCount: " + ret);
                        callback(true, " ");
                    }).catch((err) => {
                        Logger.error("ShowTaskImpl", "addCompleteCount() failed, err: " + err);
                        callback(false, "更改失败！");
                    })
                } else {
                    callback(false, "未知错误");
                }
            })

        })
    }

    /*
    * 更新showTask中的信息
    * 取消完成 完成次数-1
    * 修改这个显示事件为未完成
    * @para callback(flag,reason)
     */
    cancelCompleteCount(id2: number, callback: Function) {
        let showTaskId2: number = id2;
        this.queryShowTaskById2(showTaskId2, (showTaskData: ShowTaskData) => {
            if (showTaskData != null) {
                showTaskData.completedCount = showTaskData.completedCount - 1;
                if (showTaskData.completedCount <= 0) {
                    showTaskData.completedCount = 0;
                }
                showTaskData.isFinish = false;
                let promise = initTable.showTaskTable.update(showTaskData);
                promise.then((ret) => {
                    Logger.info("ShowTaskImpl", "cancelCompleteCount success rowCount: " + ret);
                    callback(true, " ");
                }).catch((err) => {
                    Logger.error("ShowTaskImpl", "cancelCompleteCount() failed, err: " + err);
                    callback(false, "更改失败！");
                })
            } else {
                callback(false, "未知错误");
            }
        })
    }


    /**
     * 顺延当天显示事项
     * @param id2
     * @param endTime 用于转化为validEndTime
     * @para callback(flag,reason)
     */
    deferredTaskToday(id2: number, endTime: Date, callback: Function): void {
        let showTaskId2: number = id2;
        let newValidEndTime: string = formatTime(endTime);
        this.queryShowTaskById2(showTaskId2, (showTaskData: ShowTaskData) => {
            if (showTaskData != null) {
                showTaskData.validEndTime = newValidEndTime;
                let promise = initTable.showTaskTable.update(showTaskData);
                promise.then((ret) => {
                    Logger.info("ShowTaskImpl", "deferredTaskToday success rowCount: " + ret + " - newValidEndTime:" + showTaskData.validEndTime);
                    callback(true, " ");
                }).catch((err) => {
                    Logger.error("ShowTaskImpl", "deferredTaskToday() failed, err: " + err);
                    callback(false, "顺延失败！");
                })
            } else {
                callback(false, "未知错误");
            }
        })
    }

    /**
     * 顺延以前的显示事件
     * @param id2
     * @param endTime 用于转化为endTime(yyyy-mm-dd)
     * @para callback(flag,reason)
     */
    deferredTaskBefore(id2: number, endTime: Date, callback: Function): void {
        let showTaskId2: number = id2;
        let newEndTime: string = formatDate(endTime);
        let newValidEndTime: string = formatTime(endTime);

        this.queryShowTaskById2(showTaskId2, (showTaskData: ShowTaskData) => {
            if (showTaskData != null) {
                showTaskData.endTime = newEndTime;
                showTaskData.validEndTime = newValidEndTime;
                let promise = initTable.showTaskTable.update(showTaskData);
                promise.then((ret) => {
                    Logger.info("ShowTaskImpl", "deferredTaskToday success rowCount: " + ret + " - newEndTime:" + showTaskData.endTime + " - newValidEndTime:" + showTaskData.validEndTime);
                    callback(true, " ");
                }).catch((err) => {
                    Logger.error("ShowTaskImpl", "deferredTaskToday() failed, err: " + err);
                    callback(false, "顺延失败！");
                })
            } else {
                callback(false, "未知错误");
            }
        })
    }

    /**
     * 根据id2查询showTask详细信息
     * callback(showTaskData/null)
     */
    queryShowTaskById2(id2: number, callback: Function) {
        initTable.showTaskTable.queryContext(RdbCommon.QUERY_showTask_BY_ID2, (resultSet, countRow) => {
            if (countRow > 0) {
                let showTaskArray: Array<ShowTaskData> = resultToShowTaskArray(resultSet);
                callback(showTaskArray[0]);
            } else {
                callback(null);
            }

        }, id2.toString());
    }

    /**
     * 根据id1查询所有相关showTask详细信息
     * callback(Array<showTaskData>/null)
     */
    queryAllShowTaskById1(id1: number, callback: Function) {
        initTable.showTaskTable.queryContext(RdbCommon.QUERY_All_showTask_BY_ID1, (resultSet, countRow) => {
            if (countRow > 0) {
                let showTaskArray: Array<ShowTaskData> = resultToShowTaskArray(resultSet);
                callback(showTaskArray);
            } else {
                callback(null);
            }

        }, id1.toString());
    }

    queryAllShowTaskById1Promise(id1: number): Promise<any> {
        return new Promise((reslove) => {
            this.queryAllShowTaskById1(id1, (showTaskArray: Array<ShowTaskData>) => {
                reslove(showTaskArray);
            })
        })
    }

    /**
     * 根据id1获取其标题、全部对应显示事项的各个时间与提醒
     * @param id1
     * @param callback(taskTitle,Array<ShowTaskData>)
     * remindDateTime如果是非循环事件，那么应该由TaskData的remindDate和remindTime拼接；
     * 如果是循环事件，那么应该由ShowTaskData的startTime和TaskData的remindTime拼接；
     */
    queryRemindById1(id1: number, callback: Function) {
        initTable.taskTable.queryContext(RdbCommon.QUERY_TASK_INFORMATION_3, (resultSet, countRow) => {
            if (countRow > 0) {
                resultSet.goToFirstRow();
                let taskTitle: string = resultSet.getString(resultSet.getColumnIndex("taskTitle"))
                let isLoop: boolean = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false
                let remindDate: string = resultSet.getString(resultSet.getColumnIndex("remindDate"))
                let remindTime: string = resultSet.getString(resultSet.getColumnIndex("remindTime"))
                let isRemind = resultSet.getDouble(resultSet.getColumnIndex("isRemind")) ? true : false

                if (isRemind == true) {
                    this.queryAllShowTaskById1(id1, (showTaskArray: Array<ShowTaskData>) => {
                        if (showTaskArray != null) {
                            if (isLoop == false) {
                                for (let i = 0;i < showTaskArray.length; i++) {
                                    showTaskArray[i].remindDateTime = remindDate + " " + remindTime;
                                }
                            } else {
                                for (let i = 0;i < showTaskArray.length; i++) {
                                    showTaskArray[i].remindDateTime = showTaskArray[i].startTime + " " + remindTime;
                                }
                            }
                            callback(taskTitle, showTaskArray)
                            return;
                        }
                        callback(null, null)
                    })
                }
                return;
            }
            callback(null, null)
        }, id1.toString())

    }

    /**
     * 查询所有,获取其标题、全部对应显示事项的各个时间与提醒
     * @param callback(Array<[taskTitle,Array<ShowTaskData>]>)
     * remindDateTime如果是非循环事件，那么应该由TaskData的remindDate和remindTime拼接；
     * 如果是循环事件，那么应该由ShowTaskData的startTime和TaskData的remindTime拼接；
     */
    async queryRemindAll(callback: Function) {
        let allRemind: Array<[string, Array<ShowTaskData>]> = [];
        let resultSet = await initTable.taskTable.promiseQueryContext(RdbCommon.QUERY_TASK_All, "0")
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow()
            for (let i = 0;i < resultSet.rowCount; i++) {
                let id1: number = resultSet.getDouble(resultSet.getColumnIndex("id1"))
                let taskTitle: string = resultSet.getString(resultSet.getColumnIndex("taskTitle"))
                let isLoop: boolean = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false
                let remindDate: string = resultSet.getString(resultSet.getColumnIndex("remindDate"))
                let remindTime: string = resultSet.getString(resultSet.getColumnIndex("remindTime"))
                let isRemind = resultSet.getDouble(resultSet.getColumnIndex("isRemind")) ? true : false

                if (isRemind == true) {
                    let showTaskArray = await this.queryAllShowTaskById1Promise(id1);
                    if (showTaskArray != null) {
                        if (isLoop == false) {
                            for (let i = 0;i < showTaskArray.length; i++) {
                                showTaskArray[i].remindDateTime = remindDate + " " + remindTime;
                            }
                        } else {
                            for (let i = 0;i < showTaskArray.length; i++) {
                                showTaskArray[i].remindDateTime = showTaskArray[i].startTime + " " + remindTime;
                            }
                        }
                        //                        Logger.info("ShowTaskImpl", "queryRemindAll taskTitle:" + taskTitle + "-[0]remindDateTime" + showTaskArray[0].remindDateTime);
                        allRemind.push([taskTitle, showTaskArray])
                    }

                }
                resultSet.goToNextRow();
                Logger.info("ShowTaskImpl", "allRemind[" + i + "]:" + JSON.stringify(allRemind[i]));
            }
            callback(allRemind)
            return;
        }
        callback(null)
    }

    /**
     * 查询id2对应的id1/isLoop/unitTimeNumber
     * @param 1d2
     * @para callback(id1,isLoop,unitTimeNumber)
     */
    queryID1ByID2(id2: number, callback: Function) {
        initTable.showTaskTable.queryContext(RdbCommon.QUERY_ID1_BY_ID2, (resultSet, countRow) => {
            if (countRow <= 0) {
                callback(-1, false, -1);
                return;
            }
            resultSet.goToFirstRow();
            let tmp: [number, boolean, number] = [0, false, 1];
            tmp[0] = resultSet.getDouble(resultSet.getColumnIndex("id1"));
            tmp[1] = resultSet.getDouble(resultSet.getColumnIndex("isLoop")) ? true : false;
            tmp[2] = resultSet.getDouble(resultSet.getColumnIndex("unitTimeNumber"));
            Logger.info("ShowTaskImpl", "queryID1ByID2 tmp VALUE:" + tmp[0] + "-" + tmp[1] + "-" + tmp[2]);
            callback(tmp[0], tmp[1], tmp[2])
        }, id2.toString());
    }

    /**
     * 根据日期（年，月，日，时，分）
     * 和分类（0:全部；-1:默认；-2:我的收藏；-3:重要；整数：待办id3）查询待办内容
     * @param date(year,month,day,hour,minutes)
     * @param classify(0/-1/-2/-3/id3)
     * @param callback(finishedCount,notFinishedCount,
     *                 Array<EventInfo>,Array<EventInfo>,Array<EventInfo>)
     */
    queryDisplayTaskContext(dateTime: Date, classify: number, callback: Function) {
        let finishedCount: number = -1;
        let notFinishedCount: number = -1;
        let pendingEventInfo: Array<EventInfo> = [];
        let outdatedEventInfo: Array<EventInfo> = [];
        let finishedEventInfo: Array<EventInfo> = [];
        let date: string = formatDate(dateTime);
        let today: string = formatDate(new Date());
        let todayTime: string = formatTime(new Date());
        let conditionSql: string = " ";
        let value: number = 0;

        //分类（0:全部；-1:默认；-2:我的收藏；-3:重要；整数：待办id3）查询待办内容
        switch (classify) {
            case 0:
                conditionSql = RdbCommon.AND_CONDITION_all;
                value = 0;
                break;
            case -1:
            //默认分类的id3编号是——1
                conditionSql = RdbCommon.AND_CONDITION_id3;
                value = 1;
                break;
            case -2:
                conditionSql = RdbCommon.AND_CONDITION_isCollectible;
                value = 1;
                break;
            case -3:
                conditionSql = RdbCommon.AND_CONDITION_isImportant;
                value = 1;
                break;
            default:
                conditionSql = RdbCommon.AND_CONDITION_id3;
                value = classify;
                break;
        }

        initTable.showTaskTable.queryNumber(RdbCommon.QUERY_COUNT_BY_DateClassify + RdbCommon.WHERE_CONDITION_showTask_isFinish + RdbCommon.AND_CONDITION_showTask_Date + conditionSql,
            (count1) => {
                finishedCount = count1;
                Logger.info("ShowTaskImpl", "queryDisplayTaskContext finishedCount:" + finishedCount);

                initTable.showTaskTable.queryNumber(RdbCommon.QUERY_COUNT_BY_DateClassify + RdbCommon.WHERE_CONDITION_showTask_isFinish + RdbCommon.AND_CONDITION_showTask_Date + conditionSql,
                    (count2) => {
                        notFinishedCount = count2;
                        Logger.info("ShowTaskImpl", "queryDisplayTaskContext notFinishedCount:" + notFinishedCount);

                        //分类 未完成未过期事件
                        initTable.showTaskTable.queryContext(RdbCommon.QUERY_EventInfo_BY_DateClassify + RdbCommon.WHERE_CONDITION_showTask_isFinish
                        + RdbCommon.AND_CONDITION_showTask_Date + RdbCommon.AND_CONDITION_Valid + conditionSql + RdbCommon.ORDER_BY_TIME_asc,
                            (resultSet, countRow) => {
                                if (countRow > 0) {
                                    pendingEventInfo = resultToEventInfo(resultSet);
                                }

                                //分类 未完成已过期事件
                                initTable.showTaskTable.queryContext(RdbCommon.QUERY_EventInfo_BY_DateClassify + RdbCommon.WHERE_CONDITION_showTask_isFinish
                                + RdbCommon.AND_CONDITION_showTask_Date + RdbCommon.AND_CONDITION_OutEndTime + conditionSql + RdbCommon.ORDER_BY_TIME_asc,
                                    (resultSet, countRow) => {
                                        if (countRow > 0) {
                                            outdatedEventInfo = resultToEventInfo(resultSet);
                                        }

                                        //分类 已完成事件
                                        initTable.showTaskTable.queryContext(RdbCommon.QUERY_EventInfo_BY_DateClassify + RdbCommon.WHERE_CONDITION_showTask_isFinish
                                        + RdbCommon.AND_CONDITION_showTask_Date + conditionSql + RdbCommon.ORDER_BY_TIME_asc,
                                            (resultSet, countRow) => {
                                                if (countRow > 0) {
                                                    finishedEventInfo = resultToEventInfo(resultSet);
                                                }

                                                callback(finishedCount, notFinishedCount, pendingEventInfo, outdatedEventInfo, finishedEventInfo)

                                            }, "1", date, date, value.toString());
                                    }, "0", date, date, today, today, todayTime, value.toString());
                            }, "0", date, date, today, today, todayTime, value.toString());
                    }, "0", date, date, value.toString());
            }, "1", date, date, value.toString());
    }


    /**
     * Task表每插入一项，若不循环事件，则插入一项即可；若是循环事件，需转化插入多项
     * taskData.loopSet = 0-仅一次;1-自定义;2-每个非周末;3-每个周末;4-每天;5-艾宾浩斯
     * @param taskData
     * @param callback(flag)
     */
    transformAndInsert(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter transformAndInsert ! <----");
        if (!taskData.isLoop) {
            this.onlyOneTime(taskData, callback);
        } else {
            switch (taskData.loopSet.valueOf()) {
                case 0:
                    taskData.isLoop = false;
                    this.onlyOneTime(taskData, callback);
                    break;
                case 1:
                    this.customDates(taskData, callback);
                    break;
                case 2:
                    this.eachWorkday(taskData, callback);
                    break;
                case 3:
                    this.everyWeekend(taskData, callback);
                    break;
                case 4:
                    this.everyDay(taskData, callback);
                    break;
                case 5:
                    this.ebbinghaus(taskData, callback);
                    break;
                default:
                    Logger.error("ShowTaskImpl", "transformAndInsert err!");
                    initTable.taskTable.deleteDate(taskData.id1, () => {
                    });
                    callback(false)
                    break;

            }
        }
    }

    /**
     * 仅一次
     * @param taskData
     * @param callback(flag)
     */
    onlyOneTime(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter onlyOneTime ! <----");
        let showTaskData = new ShowTaskData(0, new Date(), new Date(), new Date(), new Date(), 0, new Date(), 0, false)
        showTaskData.startTime = taskData.startTime;
        showTaskData.endTime = taskData.endTime;
        showTaskData.validStartTime = taskData.validStartTime;
        showTaskData.validEndTime = taskData.validEndTime;
        showTaskData.recentFinishedTime = "";
        showTaskData.id1 = taskData.id1;
        this.insert(showTaskData, (id2, flag, reason) => {
            callback(flag);
        })
    }


    /**
     * 每个工作日-->每周一到周五，不规避合法假期
     * @param taskData
     */
    eachWorkday(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter eachWorkday ! <----");
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);

        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        while (startDate.getTime() <= endDate.getTime()) {
            //日期是周一到周五
            if (1 <= startDate.getDay() && startDate.getDay() <= 5) {
                let newEndDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                let showTaskData: ShowTaskData = new ShowTaskData(0, startDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                    new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                    0, new Date(), taskData.id1, false);
                //        Logger.info("ShowTaskImpl", "eachWorkday startDate-->enter3:" + startDate.toString());
                this.insert(showTaskData, (id2, flag, reason) => {
                    callback(flag);
                })
            }
            startDate = new Date(startDate.setDate(startDate.getDate() + 1));
        }
    }

    /**
     * 每周六或周日
     * @param taskData
     */
    everyWeekend(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter everyWeekend ! <----");
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);

        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        while (startDate.getTime() <= endDate.getTime()) {
            //日期是周六或周日
            if (startDate.getDay() < 1 || startDate.getDay() > 5) {
                let newEndDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                let showTaskData: ShowTaskData = new ShowTaskData(0, startDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                    new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                    0, new Date(), taskData.id1, false);
                this.insert(showTaskData, (id2, flag, reason) => {
                    callback(flag)
                })
            }
            startDate = new Date(startDate.setDate(startDate.getDate() + 1));
        }
    }


    /**
     * 每天
     * @param taskData
     */
    everyDay(taskData: TaskData, callback: Function, day?) {
        Logger.info("ShowTaskImpl", "----> Enter everyDay ! <----");
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);

        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        while (startDate.getTime() <= endDate.getTime()) {
            //日期是每天
            let newEndDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
            let showTaskData: ShowTaskData = new ShowTaskData(0, startDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                0, new Date(), taskData.id1, false);
            //        Logger.info("ShowTaskImpl", "eachWorkday startDate-->enter3:" + startDate.toString());
            this.insert(showTaskData, (id2, flag, reason) => {
                callback(flag)
            })

            if (!day || typeof day == "undefined" || day == undefined) {
                startDate = new Date(startDate.setDate(startDate.getDate() + 1));
            } else {
                startDate = new Date(startDate.setDate(startDate.getDate() + day));
            }
        }
    }

    /**
     * 艾宾浩斯
     *（第1，2，3，5，7，15天要做，之后是每15天要做，一直到循环结束）{1，2，3，5，7，15，30，45，60，75，90，...}
     * @param taskData
     */
    ebbinghaus(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter ebbinghaus ! <----");
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);

        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        let i: number = 1;
        const ebbinghausDay: number[] = [0, 1, 1, 2, 2, 8, 15];
        while (startDate.getTime() <= endDate.getTime()) {
            //日期是按艾宾浩斯顺序
            let newEndDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
            let showTaskData: ShowTaskData = new ShowTaskData(0, startDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                0, new Date(), taskData.id1, false);
            //        Logger.info("ShowTaskImpl", "eachWorkday startDate-->enter3:" + startDate.toString());
            this.insert(showTaskData, (id2, flag, reason) => {
                callback(flag)
            })

            if (i <= 5) {
                startDate = new Date(startDate.setDate(startDate.getDate() + ebbinghausDay[i]));
                i++;
            } else {
                startDate = new Date(startDate.setDate(startDate.getDate() + ebbinghausDay[6]));
            }
        }
    }

    /**
     * 自定义循环
     * @param taskData
     */
    customDates(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter customDates ! <----");
        switch (taskData.loopUnit.valueOf()) {
            case 1:
                this.everyDay(taskData, callback, taskData.loopBaseNumber);
                break;
            case 2:
                this.customWeek(taskData, callback);
                break;
            case 3:
                this.customMouth(taskData, callback);
                break;
            case 4:
                this.customYear(taskData, callback);
                break;
            default:
                Logger.error("ShowTaskImpl", "unKnow loopUnit!");
                initTable.taskTable.deleteDate(taskData.id1, () => {
                });
                callback(false)
                break;

        }
    }

    /**
     * 自定义loopSet=1，loopUnit=2
     * 循环为：每x周星期几、星期几
     */
    customWeek(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter customWeek ! <----");
        let day: number[] = [];
        for (let i = 0;i < taskData.loopDate.length; i++) {
            day.push(parseInt(taskData.loopDate[i]));
        }
        //    Logger.info("ShowTaskImpl", "customWeek loopDate[0]" + taskData.loopDate[0]);
        //    Logger.info("ShowTaskImpl", "customWeek loopDate[1]" + taskData.loopDate[1]);
        //    Logger.info("ShowTaskImpl", "customWeek loopDate[3]" + taskData.loopDate[2]);
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let initStartDate: Date = new Date(date1[0], date1[1], date1[2]);
        //    Logger.info("ShowTaskImpl", "customWeek initStartDate:" + initStartDate.toString());
        //下一次的周一
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        startDate = new Date(startDate.setDate(startDate.getDate() + (7 - startDate.getDay()) + 1 + (7 * (taskData.loopBaseNumber - 1))));
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);
        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();

        let firstEndDate: Date = new Date(date1[0], date1[1], date1[2]);
        firstEndDate = new Date(firstEndDate.setDate(initStartDate.getDate() + (7 - initStartDate.getDay()) + 1));
        while (initStartDate.getTime() < firstEndDate.getTime()) {
            //日期是通过星期几判断
            for (let i = 0;i < day.length; i++) {
                if (initStartDate.getDay() == day[i]) {
                    let newEndDate: Date = new Date(initStartDate.getFullYear(), initStartDate.getMonth(), initStartDate.getDate());
                    let showTaskData: ShowTaskData = new ShowTaskData(0, initStartDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                        new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                        0, new Date(), taskData.id1, false);
                    //        Logger.info("ShowTaskImpl", "customWeek startDate-->enter3:" + startDate.toString());

                    this.insert(showTaskData, (id2, flag, reason) => {
                        if (flag) {
                            Logger.info("ShowTaskImpl", "customWeek event transformAndInsert success！");
                        } else {
                            Logger.info("ShowTaskImpl", "customWeek event transformAndInsert failed!-- " + JSON.stringify(showTaskData));
                        }
                    });
                }
            }
            initStartDate = new Date(initStartDate.setDate(initStartDate.getDate() + 1));
        }

        while (startDate.getTime() <= endDate.getTime()) {
            //日期是通过星期几判断
            for (let i = 0;i < day.length; i++) {
                let newStartDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                if (day[i] == 0) {
                    newStartDate = new Date(newStartDate.setDate(newStartDate.getDate() + 6));
                } else {
                    newStartDate = new Date(newStartDate.setDate(newStartDate.getDate() + day[i] - 1));
                }

                if (newStartDate.getTime() <= endDate.getTime()) {
                    let newEndDate: Date = new Date(newStartDate.getFullYear(), newStartDate.getMonth(), newStartDate.getDate());
                    let showTaskData: ShowTaskData = new ShowTaskData(0, newStartDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                        new Date(date1[0], date1[1], date1[2], time1[0], time2[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                        0, new Date(), taskData.id1, false);

                    this.insert(showTaskData, (id2, flag, reason) => {
                        if (flag) {
                            Logger.info("ShowTaskImpl", "customWeek event transformAndInsert success！");
                        } else {
                            Logger.info("ShowTaskImpl", "customWeek event transformAndInsert failed!-- " + JSON.stringify(showTaskData));
                        }
                    });
                }
            }
            startDate = new Date(startDate.setDate(startDate.getDate() + (7 * taskData.loopBaseNumber)));
            //      Logger.info("ShowTaskImpl", "customWeek startDate-->next:" + startDate.toString());
        }
    }

    /**
     * 自定义loopSet=1，loopUnit=3
     * 循环为：每x月几号...
     */
    customMouth(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter customMouth ! <----");
        let day: number[] = [];
        for (let i = 0;i < taskData.loopDate.length; i++) {
            day.push(parseInt(taskData.loopDate[i]));
        }
        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let initStartDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);
        let startDate: Date = new Date(date1[0], date1[1], 1);
        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        while (startDate.getTime() <= endDate.getTime()) {
            //      Logger.info("ShowTaskImpl", "---customWeek enter startDate:" + startDate.toString());
            //日期是指定的DD
            for (let i = 0;i < day.length; i++) {
                //如果是2/4/6/9/11月份，日期是30号以上，跳过
                let mount: number = startDate.getMonth() + 1;
                if (day[i] > 30 && (mount == 2 || mount == 4 || mount == 6 || mount == 9 || mount == 11)) {
                    continue;
                } else if (day[i] == 30 && mount == 2) {
                    continue;
                }
                //如果是2月份，日期是29号,但不是闰年，跳过
                if (day[i] == 29 && startDate.getMonth() == 1 &&
                !((startDate.getFullYear() % 4 == 0 && startDate.getFullYear() % 100 != 0) || (startDate.getFullYear() % 400 == 0))) {
                    continue;
                }

                let newStartDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), day[i]);
                if (newStartDate.getTime() >= initStartDate.getTime() && newStartDate.getTime() <= endDate.getTime()) {
                    let newEndDate: Date = new Date(newStartDate.getFullYear(), newStartDate.getMonth(), newStartDate.getDate());
                    let showTaskData: ShowTaskData = new ShowTaskData(0, newStartDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                        new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                        0, new Date(), taskData.id1, false);

                    this.insert(showTaskData, (id2, flag, reason) => {
                        if (flag) {
                            Logger.info("ShowTaskImpl", "customMouth event transformAndInsert success！");
                        } else {
                            Logger.info("ShowTaskImpl", "customMouth event transformAndInsert failed!-- " + JSON.stringify(showTaskData));
                        }
                    });
                }
            }
            startDate = new Date(startDate.setMonth(startDate.getMonth() + taskData.loopBaseNumber));
        }
    }

    /**
     * 自定义loopSet=1，loopUnit=4
     * 循环为：每x年几月几日...
     */
    customYear(taskData: TaskData, callback: Function) {
        Logger.info("ShowTaskImpl", "----> Enter customYear ! <----");
        let mouthDay: number[][] = [];
        for (let i = 0;i < taskData.loopDate.length; i++) {
            let date: string[] = taskData.loopDate[i].split("-", 2);
            mouthDay.push([parseInt(date[0]), parseInt(date[1])]);
        }

        let date1: number[] = taskData.getStartTimeDate();
        let date2: number[] = taskData.getEndTimeDate();
        let initStartDate: Date = new Date(date1[0], date1[1], date1[2]);
        let startDate: Date = new Date(date1[0], date1[1], date1[2]);
        let endDate: Date = new Date(date2[0], date2[1], date2[2]);
        let finallyEndDate: Date = new Date(date2[0], date2[1], date2[2]);
        finallyEndDate = new Date(finallyEndDate.setFullYear(finallyEndDate.getFullYear() + taskData.loopBaseNumber));

        let time1: number[] = taskData.getValidStartTime();
        let time2: number[] = taskData.getValidEndTime();
        while (startDate.getTime() <= finallyEndDate.getTime()) {
            //日期是指定的MM-DD
            for (let i = 0;i < mouthDay.length; i++) {
                let newStartDate: Date = new Date(startDate.getFullYear(), mouthDay[i][0] - 1, mouthDay[i][1]);

                if (newStartDate.getTime() >= initStartDate.getTime() && newStartDate.getTime() <= endDate.getTime()) {
                    let newEndDate: Date = new Date(newStartDate.getFullYear(), newStartDate.getMonth(), newStartDate.getDate());
                    let showTaskData: ShowTaskData = new ShowTaskData(0, newStartDate, new Date(newEndDate.setDate(newEndDate.getDate() + taskData.duration - 1)),
                        new Date(date1[0], date1[1], date1[2], time1[0], time1[1]), new Date(date2[0], date2[1], date2[2], time2[0], time2[1]),
                        0, new Date(), taskData.id1, false);

                    this.insert(showTaskData, (id2, flag, reason) => {
                        if (flag) {
                            Logger.info("ShowTaskImpl", "eachWorkDay event transformAndInsert success！");
                        } else {
                            Logger.info("ShowTaskImpl", "eachWorkDay event transformAndInsert failed!-- " + JSON.stringify(showTaskData));
                        }
                    });
                }
            }
            startDate = new Date(startDate.setFullYear(startDate.getFullYear() + taskData.loopBaseNumber));
        }
    }
}


