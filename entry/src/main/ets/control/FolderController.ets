import { UpdateVersionNumber } from './TerminalsSyncController';
import TaskImpl from '../dao/controller/TaskImpl';
import { refreshResource } from './EventsController';
import { TaskInterface } from '../dao/controller/Interface/TaskInterface';
import { FavoritesData } from '../model/FavoritesData';
import { FavoritesImpl } from '../dao/controller/FavoritesImpl';
import { FavoritesInterface } from '../dao/controller/Interface/FavoritesInterface';
import FolderResource from '../model/FolderResourceContact';
import EventResource from '../model/EventsResourceContact';
import prompt from '@ohos.prompt'
import common from '@ohos.app.ability.common';

/**
 * 获取待办单
 */
export function getFolderResource(context: Context) {

  let systemFolderResource = AppStorage.Get<FolderResource[]>("systemFolderResource");
  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");

  if(systemFolderResource.length < 4) {
    systemFolderResource = [
      new FolderResource(0, $r('app.media.ic_folder'), '', '全部待办', 0),
      new FolderResource(-1, $r('app.media.ic_folder_filled'), '', '未分类', 0),
      new FolderResource(-2, $r('app.media.ic_collect'), '', '我的收藏', 0),
      new FolderResource(-3, $r('app.media.ic_important'), '', '重要待办', 0)
    ]
  }

  const favoritesTaskImpl: FavoritesInterface = new FavoritesImpl();
  const taskImpl: TaskInterface = new TaskImpl();

  taskImpl.queryNumber((counter: number[]) => {
    systemFolderResource[0].counter = counter[0]
    systemFolderResource[1].counter = counter[1]
    systemFolderResource[2].counter = counter[2]
    systemFolderResource[3].counter = counter[3]
    AppStorage.Set<FolderResource[]>("systemFolderResource", systemFolderResource)
  }, context)

  favoritesTaskImpl.queryAllAndNumber(context).then((folderResource: FavoritesData[]) => {

    userFolderResource = []

    if (folderResource == null) folderResource = []
    console.log('1-1.获取待办单(length): ' + folderResource.length.toString());
    for (let i = 0;i < folderResource.length; i++) {
      console.log('1-1.获取待办单: ' + folderResource[i].id3);
      if (folderResource[i].id3 == 1)
        systemFolderResource[1].counter = folderResource[i].count
      else {
        userFolderResource.push(
          new FolderResource(
          folderResource[i].id3,
          getFolderIcon(folderResource[i].favoritesColor),
          folderResource[i].favoritesColor,
          folderResource[i].favoritesName,
          folderResource[i].count,
          ),
        )
      }
    }

    //    userFolderResource = [
    //      new FolderResource(1, $r('app.media.ic_folder_filled_red'), 'red', '待办单1', 3),
    //      new FolderResource(2, $r('app.media.ic_folder_filled_lightBlue'), 'lightBlue', '待办单2', 4)
    //    ]

    AppStorage.Set<FolderResource[]>("systemFolderResource", systemFolderResource)
    AppStorage.Set<FolderResource[]>("userFolderResource", userFolderResource)
  })
}

/**
 * 获取待办单标题
 */
export function getFolderTitle(): string | Resource {
  let folderId = AppStorage.Get<number>("folderId")
  let systemFolderResource = AppStorage.Get<FolderResource[]>("systemFolderResource");
  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");

  if (folderId <= 0)
    return systemFolderResource[-folderId].title;
  else {
    let id = userFolderResource.findIndex((item) => item.id == folderId)
    return userFolderResource[id].title;
  }
}

/**
 * 获取待办单标题
 */
export async function getFormFolderTitle(folderId: number, context: Context): Promise<string | Resource> {
  let systemFolderResource : FolderResource[]  = [
    new FolderResource(0, $r('app.media.ic_folder'), '', '全部待办', 0),
    new FolderResource(-1, $r('app.media.ic_folder_filled'), '', '未分类', 0),
    new FolderResource(-2, $r('app.media.ic_collect'), '', '我的收藏', 0),
    new FolderResource(-3, $r('app.media.ic_important'), '', '重要待办', 0)
  ]
  let userFolderResource : FolderResource[]  = []

  const favoritesTaskImpl: FavoritesInterface = new FavoritesImpl();
  return new Promise((resolve) => {
    if (folderId <= 0)
      resolve(systemFolderResource[-folderId].title) ;
    else {
      favoritesTaskImpl.queryAllAndNumber(context).then((folderResource: FavoritesData[]) => {
        userFolderResource = []
        if (folderResource == null) folderResource = []
        console.log('1-1.获取待办单(length): ' + folderResource.length.toString());
        for (let i = 0;i < folderResource.length; i++) {
          console.log('1-1.获取待办单: ' + folderResource[i].id3);
          if (folderResource[i].id3 == 1)
            systemFolderResource[1].counter = folderResource[i].count
          else {
            userFolderResource.push(
              new FolderResource(
                folderResource[i].id3,
                getFolderIcon(folderResource[i].favoritesColor),
                folderResource[i].favoritesColor,
                folderResource[i].favoritesName,
                folderResource[i].count,
              ),
            )
          }
        }
        let id = userFolderResource.findIndex((item) => item.id == folderId)
        resolve (userFolderResource[id].title);
    })
  }
  })

}

/**
 * 添加待办单计数量
 * @param folderId 待办单ID
 * @param value 添加的值
 */
export function addFolderCounter(folderId: number, value: number) {
  let systemFolderResource = AppStorage.Get<FolderResource[]>("systemFolderResource");
  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");

  if (folderId > 0)
    userFolderResource[userFolderResource.findIndex((item) => item.id == folderId)].counter += value
  else
    systemFolderResource[systemFolderResource.findIndex((item) => item.id == folderId)].counter += value

  console.log('addFolderCounter: folderId:' + folderId.toString() + ', value:' + value.toString())

  AppStorage.Set<FolderResource[]>("systemFolderResource", systemFolderResource)
  AppStorage.Set<FolderResource[]>("userFolderResource", userFolderResource)
}

/**
 * 获取待办单的颜色分类
 * @param folderId 待办单ID
 */
export function getFolderClassify(folderId: number): string {
  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");

  if (folderId > 0)
    return userFolderResource[userFolderResource.findIndex((item) => item.id == folderId)].classify
  else
    return ''
}

/**
 * 获取待办单的图标
 * @param classify 待办单的颜色分类
 */
export function getFolderIcon(classify: string): Resource {
  switch (classify) {
    case 'red': {
      return $r('app.media.ic_folder_filled_red');
    }
    case 'orange': {
      return $r('app.media.ic_folder_filled_orange');
    }
    case 'yellow': {
      return $r('app.media.ic_folder_filled_yellow');
    }
    case 'green': {
      return $r('app.media.ic_folder_filled_green');
    }
    case 'lakeBlue': {
      return $r('app.media.ic_folder_filled_lakeBlue');
    }
    case 'lightBlue': {
      return $r('app.media.ic_folder_filled_lightBlue');
    }
    case 'darkBlue': {
      return $r('app.media.ic_folder_filled_darkBlue');
    }
    case 'purple': {
      return $r('app.media.ic_folder_filled_purple');
    }
    default: {
      return $r('app.media.ic_folder_filled');
    }
  }
}

/**
 * 添加待办单
 * @param classify 颜色分类
 * @param title 标题
 */
export function addNewFolder(classify: string, title: string, context: Context) {
  const favoritesTaskImpl: FavoritesInterface = new FavoritesImpl();

  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");
  let icon: Resource = $r('app.media.ic_folder_filled')
  icon = getFolderIcon(classify)

  favoritesTaskImpl.insert(new FavoritesData(0, title, classify),
    (id3: number, flag: boolean, reason: string) => {
      console.log('2-1.新建待办单：{颜色分类：' + classify + '，名字：' + title + '}')
      console.log('2-1.新建待办单callback：id3：' + id3.toString() + '，flag：' + flag.toString() + '}')
      if (flag) {
        let newFolder: FolderResource = new FolderResource(id3, icon, classify, title, 0)
        userFolderResource.push(newFolder)
        AppStorage.Set<FolderResource[]>("userFolderResource", userFolderResource)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '添加待办单失败，' + reason,
          duration: 1000,
        });
      }
    }, context)
}

/**
 * 编辑待办单
 * @param folderId 待办单ID
 * @param classify 颜色分类
 * @param title 标题
 */
export function editNewFolder(folderId: number, classify: string, title: string, context: Context) {
  let userFolderResource = AppStorage.Get<FolderResource[]>("userFolderResource");
  let icon: Resource = $r('app.media.ic_folder_filled')
  icon = getFolderIcon(classify)
  console.log('4-3.修改待办单：{待办单ID：' + folderId + '，颜色分类：' + classify + '，名字：' + title + '}')

  const favoritesTaskImpl: FavoritesInterface = new FavoritesImpl();
  favoritesTaskImpl.changeFavorites(folderId, title, classify,
    (flag: boolean, reason: string) => {
      console.log('4-3.修改待办单：{待办单ID：' + folderId + '，颜色分类：' + classify + '，名字：' + title + '}')
      if (flag) {
        let id = userFolderResource.findIndex((item) => item.id == folderId)
        userFolderResource[id] = new FolderResource(folderId, icon, classify, title, userFolderResource[id].counter)
        let eventsShowResource:EventResource[][] = JSON.parse(AppStorage.Get<string>("eventsShowResource"));
        for (let i = 0;i < 3; i++)
          for (let j = 0;j < eventsShowResource[i].length; j++)
            if (eventsShowResource[i][j].folderId == folderId) {
              eventsShowResource[i][j].classify = classify
            }
        AppStorage.Set<string>("eventsShowResource", JSON.stringify(eventsShowResource))
        AppStorage.Set<FolderResource[]>("userFolderResource", userFolderResource)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '修改待办单失败，' + reason,
          duration: 1000,
        });
      }
    }, context)
}

/**
 * 删除一个待办单
 * @param folderId 待办单ID
 * @param isDirectly 是否直接删除，不处理内容
 */
export function deleteAFolder(folderId: number, isDirectly: boolean, context: Context) {
  const favoritesTaskImpl: FavoritesInterface = new FavoritesImpl();
  if (isDirectly) {
    favoritesTaskImpl.deleteFavorites(folderId, (flag: boolean, reason: string) => {
      console.log('4-1.完全删除待办单：{待办单ID：' + folderId + '}')
      if (flag) {
        refreshResource(context)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '删除待办单失败，' + reason,
          duration: 1000,
        });
      }
    }, context)
  } else {
    favoritesTaskImpl.deleteFavoritesAndMove(folderId, (flag: boolean, reason: string) => {
      console.log('4-2.删除待办单并移动内容到未分类：{待办单ID：' + folderId + '}')
      if (flag) {
        refreshResource(context)
        UpdateVersionNumber()
      } else {
        prompt.showToast({
          message: '删除待办单失败，' + reason,
          duration: 1000,
        });
      }
    }, context)
  }
}
