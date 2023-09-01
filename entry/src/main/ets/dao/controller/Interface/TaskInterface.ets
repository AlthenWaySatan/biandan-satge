import { TaskData } from '../../../model/TaskData';

export interface TaskInterface {
  /**
   * 添加一个事项，插入Task表，并转化插入showTask表
   * @param taskData
   * @param callback(id1,flag,reason)
   */
  insert(taskData: TaskData, callback: Function): void

  /**
   * 删除事项
   * @param id1
   * @param callback(flag,reason)
   */
  deleteTask(id1: number, callback: Function): void

  /**
   * 更新事项的收藏属性
   * @param id1
   * @param isCollectible：true 收藏 / false 不收藏
   * @param callback(flag,reason)
   * （重复取消收藏需要返回false）
   */
  changeCollectible(id1: number, isCollectible: boolean, callback: Function)

  /**
   * 更新事项的分类属性
   * @param id1
   * @param id3 分类的id3
   * @param callback(flag,reason)
   */
  changeFavorites(id1: number, id3: number, callback: Function): void

  /**
   * 更新整个事项的完成状态isFinish
   * @param id1
   * @param isFinish: true 完成 / false 未完成
   */
  changeIsFinish(id1: number, isFinish: boolean): void

  /**
   * 编辑非重复事项的信息，同时修改showTask表对应的信息
   * @param taskData 有id1
   * @param callback(flag,reason)
   */
  updateNotLoopTask(newTaskData: TaskData, callback: Function): void

  /**
   * 编辑重复事项的信息，先删除全部相关showTask再重新插入
   * @param taskData 有id1
   * @param callback(flag,reason)
   */
  updateLoopTask(newTaskData: TaskData, callback: Function): void

  /**
   * 获取Task的详细信息
   * @param id1
   * callback(taskData/null)
   */
  queryTask(id1: number, callback: Function)


  /**
   * 获取全部事项、默认事项、收藏事项的数量
   * @param callback([全部待办数，未分类数，我的收藏数，重要待办数])
   */
  queryNumber(callback: Function): void

  /**
   * 根据id3查询是否存在该分类
   * callback(true/false)
   */
  queryById3(id3: number, callback: Function)


}