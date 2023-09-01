import { FavoritesData } from '../../../model/FavoritesData';

export interface FavoritesInterface {
  /**
   * 向favorites表中插入一项
   * @param favoritesData
   * @param callback(id3,flag,reason)
   */
  insert(favoritesData: FavoritesData, callback: Function)

  /**
   * 删除分类并删除相关事件和显示事件
   * @param id3
   * @param callback(flag,reason)
   */
  deleteFavorites(id3: number, callback: Function)

  /**
   * 根据id3删除待办单并移动内容到未分类id3=1】
   * @param id3
   * @param callback(flag,reason)
   */
  deleteFavoritesAndMove(id3: number, callback: Function)

  /**
   * 更改分类的名称/颜色
   * @param id3
   * @param name
   * @param color
   * @param callback(flag,reason)
   */
  changeFavorites(id3: number, name: string, color: string, callback: Function)

  /**
   * 查询全部待办单的信息和内容数量
   * return(Promise<Array<FavoritesData>>) FavoritesData：[id3,name,color,count]
   */
  queryAllAndNumber():Promise<Array<FavoritesData>>


  /**
   * 根据id3获取所有task的id1
   * @param id3
   * @param callback(Array<number>)
   */
  queryAllId1ById3(id3: number, callback: Function)

}