import { Backup } from '../dao/controller/InitAndTable';
import { backUpPath, backUpPathEx } from '../model/BackUpContact';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';
import util from '@ohos.util';
import fileio from '@ohos.file.fs';
import featureAbility from '@ohos.ability.featureAbility';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';

PersistentStorage.PersistProp('BackUpSwitch', false)
PersistentStorage.PersistProp('AutoBackUpSwitch', false)

/**
 * 查询权限
 */
export async function getPermission_WRITE_MEDIA(): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA'];
  var context: Context = getContext(this) as common.Context;
  let atManager = abilityAccessCtrl.createAtManager();
  let PermissionRequestResult = await atManager.requestPermissionsFromUser(context, array);
  let authResults0 = PermissionRequestResult.authResults[0];
  let authResults1 = PermissionRequestResult.authResults[1];
  console.log("====>requestData====> " + authResults0 + ' ,' + authResults1);
  let ret: boolean = ((authResults0 == 0) && (authResults1 == 0))
  if (!ret) {
    AppStorage.Set('BackUpSwitch', false)
    AppStorage.Set('AutoBackUpSwitch', false)
  }
  return ret
}

/**
 * 获取媒体资源
 */
export async function getMediaLibrary(): Promise<any> {
  let BackUpSwitch: boolean = AppStorage.Get<boolean>('BackUpSwitch')
  if (!BackUpSwitch) return []

  let ret = []
  return ret
}

/**
 * 打开并选择媒体资源
 */
export async function openMediaAndSelect(): Promise<string> {
  let types = ['image/png'];
  let ret: string = '';
  return ret;
}

/**
 * 读取文件
 * @param data 文件内容
 */
export async function readFile(data: mediaLibrary.FileAsset): Promise<string> {
  let fd = await data.open('rw')
  console.log('open successfully: ' + fd)
  let file = fileio.fdopenStreamSync(fd, "r+")
  let readString = ''
  return readString
}

/**
 * 根据时间获取文件名
 */
function getTimeDate(): string {
  let ret: string = (new Date().getTime()).toString() + '.png'
  return ret
}

async function deleteRedundancyFile() {
  let BackUpSwitch: boolean = AppStorage.Get<boolean>('BackUpSwitch')
  if (!BackUpSwitch) return []

}

/**
 * 写入文件
 * @param data 文件内容
 */
export async function writeFile(data: string) {
  let fileName = getTimeDate()

}

const backUpImpl: Backup = new Backup()

/**
 * 导入文件
 * @param data 文件内容
 */
export async function importFile(data: mediaLibrary.FileAsset): Promise<[boolean, string]> {
  return null;
}

/**
 * 以promise形式获取备份信息
 */
async function getBackupObject(): Promise<object> {
  return new Promise((resolve) => {
    backUpImpl.exportData((obj: object) => {
      resolve(obj)
    })
  })
}

/**
 * 备份文件
 */
export async function backupFile() {
  //  let data: object = { "text": new Date() }
  let value = await getPermission_WRITE_MEDIA()
  if (value) {
    let data: object = await getBackupObject()
    let str: string = JSON.stringify(data)
    console.log('backup value: ' + str);
    await writeFile(str)
    await deleteRedundancyFile()
  }
}

/**
 * 删除文件
 * @param data
 */
export async function deleteFile(data: mediaLibrary.FileAsset) {
  console.log('delete: ' + JSON.stringify(data));
  data.trash(true).then(function () {
    console.info("trash successfully");
  }).catch(function (err) {
    console.info("trash failed with error:" + err);
  });
}
