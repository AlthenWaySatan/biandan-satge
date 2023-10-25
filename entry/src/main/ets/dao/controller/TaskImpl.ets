import { initTable } from './InitAndTable';
import { resultToTaskData } from '../../model/TaskData';
import { ShowTaskData } from '../../model/ShowTaskData';
import { FavoritesData } from '../../model/FavoritesData';
import Logger from "../utils/log/Logger";
import { RdbCommon } from "../../model/RdbCommon";
import { ShowTaskImpl } from "./ShowTaskImpl";
import { ShowTaskInterface } from "./Interface/ShowTaskInterface";
import { TaskData } from "../../model/TaskData";
import { TaskInterface } from "./Interface/TaskInterface";
import common from '@ohos.app.ability.common';

export default class TaskImpl implements TaskInterface {
    private showTaskImpl: ShowTaskInterface = new ShowTaskImpl(getContext(this) as common.Context);

    constructor(context) {
        initTable.taskTable.getRdbStore(context);
    }

    /**
     * 添加一个事项，插入Task表，并转化插入showTask表
     * 先判断
     * @param taskData
     * @param callback(id1,flag,reason)
     */
    insert(taskData: TaskData, callback: Function): void {
        //判断favorites表是否为空，若空，则插入一行表示默认未分类
        this.queryById3(1, (flag: boolean) => {
            if (!flag) {
                initTable.favoritesTable.insertData(new FavoritesData(0, "默认", "black"), (id3, flag1, reason) => {
                    if (flag1) {
                        Logger.info("TaskImpl", "insert default FavoritesData!");
                    }
                })
            }
        })

        //判断taskData.id3是否存在，若不存在，则将其修改为默认分类，taskData.id3=1
        this.queryById3(taskData.id3, (flag: boolean) => {
            if (flag == false) {
                taskData.id3 = 1;
            }
            //      Logger.info("TaskImpl", "---favoritesImpl.queryById3: " + taskData.id3);
            initTable.taskTable.insertData(taskData, (id1, flag, reason) => {
                if (flag) {
                    taskData.id1 = id1;
                    Logger.info("TaskImpl", " insert newTask success:" + JSON.stringify(taskData));
                    this.showTaskImpl.transformAndInsert(taskData, (flag1) => {
                        if (flag1 == false) {
                            flag = false;
                            reason = "创建失败";
                        }
                    })
                }
                callback(id1, flag, reason)
            })
        });
    }


    /**
     * 删除事项
     * @param id1
     * @param callback(flag,reason)
     */
    deleteTask(id1: number, callback: Function): void {
        initTable.taskTable.deleteDate(id1, (flag1, reason1) => {
            if (flag1) {
                Logger.info("TaskImpl", "delete task success! id1:" + id1);
                //删除相关显示事项
                initTable.showTaskTable.deleteDate(0, (flag2, reason2) => {
                    if (flag2) {
                        Logger.info("TaskImpl", "delete showTask success! by id1:" + id1);
                        callback(true, "事项删除成功")
                        return;
                    }
                    callback(flag2, reason2)
                }, id1)
                return;
            }
            callback(flag1, reason1)
        });
    }

    /**
     * 更新事项的收藏属性
     * @param id1
     * @param isCollectible：true 收藏 / false 不收藏
     * @param callback(flag,reason)
     * （重复取消收藏需要返回false）
     */
    changeCollectible(id1: number, isCollectible: boolean, callback: Function) {
        let taskId1: number = id1;
        this.queryTask(taskId1, (taskData: TaskData) => {
            if (taskData != null) {
                //（重复取消收藏需要返回false）
                if (!isCollectible && !taskData.isCollectible) {
                    callback(false, "已取消收藏")
                    return;
                }
                taskData.isCollectible = isCollectible;
                if (taskData.id3 <= 1) {
                    taskData.id3 = 1;
                }
                let promise = initTable.taskTable.update(taskData);
                promise.then((ret) => {
                    Logger.info("TaskImpl", "changeCollectible success id1-" + taskId1 + " -> isCollectible: " + taskData.isCollectible);
                    callback(true, " ");
                }).catch((err) => {
                    Logger.error("TaskImpl", "changeCollectible() failed, err: " + err);
                    callback(false, "更改失败");
                })
            } else {
                callback(false, "查无事项");
            }
        })

    }

    /**
     * 更新事项的分类属性
     * @param id1
     * @param id3 分类的id3
     * @param callback(flag,reason)
     */
    changeFavorites(id1: number, id3: number, callback: Function): void {
        let taskId1: number = id1;
        let favoritesId3: number = id3;
        this.queryTask(taskId1, (taskData: TaskData) => {
            if (taskData != null) {
                taskData.id3 = favoritesId3;
                let promise = initTable.taskTable.update(taskData);
                promise.then((ret) => {
                    Logger.info("TaskImpl", "changeCollectible success rowCount: " + ret + " - id3:" + taskData.id3);
                    callback(true, " ");
                }).catch((err) => {
                    Logger.error("TaskImpl", "changeCollectible() failed, err: " + err);
                    callback(false, "更改失败");
                })
            } else {
                callback(false, "查无事项");
            }
        })

    }

    /**
     * 更新整个事项的完成状态isFinish
     * @param id1
     * @param isFinish: true 完成 / false 未完成
     */
    changeIsFinish(id1: number, isFinish: boolean): void {
    }

    /**
     * 编辑非循环事项的信息，同时修改showTask表对应的信息
     * @param taskData 有id1
     * @param callback(flag,reason)
     */
    updateNotLoopTask(newTask: TaskData, callback: Function) {
        let taskId1 = newTask.id1;
        this.queryTask(taskId1, (oldTask: TaskData) => {
            if (oldTask != null && newTask.isLoop == oldTask.isLoop) {
                //修改task信息
                let promise1 = initTable.taskTable.update(newTask)
                promise1.then((ret) => {
                    Logger.info("TaskImpl", "updateNotLoopTask change task success id1: " + taskId1 + " -> rowCount:" + ret);
                }).catch((err) => {
                    Logger.error("TaskImpl", "updateNotLoopTask() failed, err: " + err);
                    callback(false, "修改非循环事项信息失败")
                    return;
                })

                this.showTaskImpl.queryAllShowTaskById1(taskId1, (showTaskArray: Array<ShowTaskData>) => {
                    if (showTaskArray != null) {
                        for (let i = 0;i < showTaskArray.length; i++) {
                            if (showTaskArray[i].completedCount >= newTask.unitTimeNumber) {
                                showTaskArray[i].isFinish = true;
                            }
                            if (newTask.isLoop == false) {
                                showTaskArray[i].startTime = newTask.startTime;
                                showTaskArray[i].endTime = newTask.endTime;
                                showTaskArray[i].validStartTime = newTask.validStartTime;
                                showTaskArray[i].validEndTime = newTask.validEndTime;
                            }

                            let promise2 = initTable.showTaskTable.update(showTaskArray[i])
                            promise2.then((ret) => {
                                Logger.info("TaskImpl", "updateTask change showTask success by id2: " + showTaskArray[i] + " -> rowCount:" + ret);
                                callback(true, "")
                            }).catch((err) => {
                                Logger.error("TaskImpl", "updateTask() failed, err: " + err);
                                callback(false, "编辑非循环事项失败");
                                return;
                            })
                        }

                    } else {
                        Logger.error("TaskImpl", "showTaskArray is null");
                        callback(false, "未知错误");
                        return;
                    }

                })
            } else {
                callback(false, "error！编辑非循环事项");
            }
        })

    }

    /**
     * 编辑循环事项的信息，先删除全部相关showTask再重新插入
     * @param taskData 有id1
     * @param callback(flag,reason)
     */
    updateLoopTask(newTask: TaskData, callback: Function): void {
        let taskId1 = newTask.id1;
        this.queryTask(taskId1, (oldTask: TaskData) => {
            if (oldTask != null && newTask.isLoop == true) {
                //先删除所有相关showTask
                this.deleteTask(taskId1, (flag1, reason1) => {
                    if (!flag1) {
                        Logger.error("TaskImpl", "updateLoopTask deleteTask failed!");
                        callback(false, "未知错误");
                    }
                });
                //重新插入一个新的task信息
                this.insert(newTask, (id1, flag, reason) => {
                    if (flag) {
                        newTask.id1 = id1;
                        Logger.info("TaskImpl", "updateLoopTask change task success id1: " + id1);
                        callback(true, "")
                    } else {
                        Logger.error("TaskImpl", "updateNotLoopTask() fail to insert newTask");
                        callback(false, "编辑循环事项失败");
                        return;
                    }
                })
            } else {
                callback(false, "error！编辑循环事项");
            }
        })
    }

    /**
     * 获取Task的详细信息
     * @param id1
     * callback(taskData/null)
     */
    queryTask(id1: number, callback: Function) {
        initTable.taskTable.queryContext(RdbCommon.QUERY_TASK_INFORMATION_3, (resultSet, countRow) => {
            if (countRow > 0) {
                let taskArray: Array<TaskData> = resultToTaskData(resultSet);
                callback(taskArray[0]);
            } else {
                callback(null);
            }
        }, id1.toString());
    }

    /**
     * 获取全部事项、默认事项、收藏事项、重要事项的数量
     * @param callback([全部待办数，未分类数，我的收藏数，重要待办数])
     */
    queryNumber(callback: Function) {
        let count: number[] = [0, 0, 0, 0];
        initTable.taskTable.queryNumber(RdbCommon.QUERY_TASK_NUMBER_1 + RdbCommon.QUERY_TASK_NOTNULL, (count0) => {
            count[0] = count0;
            Logger.info("TaskImpl", "queryNumber count[0]:" + count[0]);

            initTable.taskTable.queryNumber(RdbCommon.QUERY_TASK_NUMBER_1 + RdbCommon.QUERY_TASK_default, (count1) => {
                count[1] = count1;
                Logger.info("TaskImpl", "queryNumber count[1]:" + count[1]);

                initTable.taskTable.queryNumber(RdbCommon.QUERY_TASK_NUMBER_1 + RdbCommon.QUERY_TASK_isCollectable, (count2) => {
                    count[2] = count2;
                    Logger.info("TaskImpl", "queryNumber count[2]:" + count[2]);

                    initTable.taskTable.queryNumber(RdbCommon.QUERY_TASK_NUMBER_1 + RdbCommon.QUERY_TASK_isImportant, (count3) => {
                        count[3] = count3;
                        Logger.info("TaskImpl", "queryNumber count[2]:" + count[2]);

                        callback(count);
                    }, "1");
                }, "1");
            }, "1");
        }, "0");
    }

    /**
     * 根据id3查询是否存在该分类
     * callback(true/false)
     */
    queryById3(id3: number, callback: Function) {
        initTable.favoritesTable.queryContext(RdbCommon.QUERY_FAVORITES_byId3, (resultSet, countRow) => {
            let flag: boolean = false;
            if (countRow <= 0) {
                Logger.info("TaskImpl", "queryById3: " + id3 + " exist ->" + flag);
                callback(flag);
            } else {
                flag = true;
                Logger.info("TaskImpl", "queryById3: " + id3 + " exist ->" + flag);
                callback(flag);
            }
        }, id3.toString());
    }
}




