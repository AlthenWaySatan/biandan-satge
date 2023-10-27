import { Backup } from '../dao/controller/InitAndTable';
import { backUpPath } from '../model/BackUpContact';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';
import util from '@ohos.util';
import fileio from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import document from '@ohos.document';

const filesFetchOptions = {
  selections: mediaLibrary.FileKey.RELATIVE_PATH + ' = ? AND ' +
  mediaLibrary.FileKey.DISPLAY_NAME + ' LIKE ?',
  selectionArgs: [backUpPath, "%.png"],
  order: mediaLibrary.FileKey.DATE_ADDED + " DESC"
};

PersistentStorage.PersistProp('BackUpSwitch', 0)
PersistentStorage.PersistProp('AutoBackUpSwitch', 0)

/**
 * 查询权限
 */
export async function getPermission_WRITE_MEDIA(context: Context): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA'];
  let atManager = abilityAccessCtrl.createAtManager();
  let PermissionRequestResult = await atManager.requestPermissionsFromUser(context, array);
  let authResults0 = PermissionRequestResult.authResults[0];
  let authResults1 = PermissionRequestResult.authResults[1];
  console.log("====>requestData====> " + authResults0 + ' ,' + authResults1);
  let ret: boolean = ((authResults0 == 0) && (authResults1 == 0))
  if (!ret) {
    AppStorage.Set('BackUpSwitch', 0)
    AppStorage.Set('AutoBackUpSwitch', 0)
  }
  return ret
}

/**
 * 获取媒体资源
 */
export async function getMediaLibrary(context: Context): Promise<mediaLibrary.FileAsset[]> {
  let BackUpSwitch: number = AppStorage.Get<number>('BackUpSwitch')
  if (BackUpSwitch == 0) return []

  let media = mediaLibrary.getMediaLibrary(context);
  console.log('filesFetchOptions = ' + JSON.stringify(filesFetchOptions))
  let fetchFileResult = await media.getFileAssets(filesFetchOptions)
  console.log('fetchFileResult = ' + JSON.stringify(fetchFileResult) + ' ,number: ' + fetchFileResult.getCount()
    .toString())
  let ret: mediaLibrary.FileAsset[] = []
  let count: number = 0
  if (fetchFileResult.getCount() > 0)
    for (let i = await fetchFileResult.getFirstObject();!fetchFileResult.isAfterLast(); i = await fetchFileResult.getNextObject()) {
      if (!await i.isTrash()) {
        if (++count <= 10) {
          ret.push(i)
        } else {
          break
        }
      }
    }
  fetchFileResult.close()
  console.log(JSON.stringify(ret))
  return ret
}

/**
 * 打开并选择媒体资源
 */
export async function openMediaAndSelect(): Promise<string> {
  let types = ['image/png'];
  let ret: string = await document.choose(types);
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
  let buffer = new ArrayBuffer(data.size);
  let readLen = await file.read(buffer)
  let bufferUint8 = new Uint8Array(buffer.slice(0, readLen))
  let textDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true });
  let readString = textDecoder.decode(bufferUint8, { stream: false });
  console.log("IO Read:" + JSON.stringify(readString));
  data.close(fd)
  return readString
}

/**
 * 根据时间获取文件名
 */
function getTimeDate(): string {
  let ret: string = (new Date().getTime()).toString() + '.png'
  return ret
}

async function deleteRedundancyFile(context: Context) {
  let BackUpSwitch: number = AppStorage.Get<number>('BackUpSwitch')
  if (BackUpSwitch == 0) return []

  let media = mediaLibrary.getMediaLibrary(context);
  console.log('filesFetchOptions = ' + JSON.stringify(filesFetchOptions))
  let fetchFileResult = await media.getFileAssets(filesFetchOptions)
  console.log('fetchFileResult = ' + JSON.stringify(fetchFileResult) + ' ,number: ' + fetchFileResult.getCount()
    .toString())
  let count: number = 0
  if (fetchFileResult.getCount() > 0)
    for (let i = await fetchFileResult.getFirstObject();!fetchFileResult.isAfterLast(); i = await fetchFileResult.getNextObject()) {
      if (!await i.isTrash()) {
        if (count < 10) {
          ++count
        } else {
          deleteFile(i)
        }
      }
    }
}

/**
 * 写入文件
 * @param data 文件内容
 */
export async function writeFile(data: string, context: Context) {
  let fileName = getTimeDate()
  let media = mediaLibrary.getMediaLibrary(context);
  let mediaType = mediaLibrary.MediaType.FILE;
  console.info('ready to createAsset , parameters :  mediaType = ' + mediaType + ', fileName = ' + fileName + ', backUpPath = ' + backUpPath);
  let fileAsset = await media.createAsset(mediaType, fileName, backUpPath)
  console.info('createAsset successfully, message = ' + JSON.stringify(fileAsset));
  let fd = await fileAsset.open('rw')
  console.log('open successfully: ' + fd)
  fileio.writeSync(fd, data)
  fileAsset.close(fd)
}

const backUpImpl: Backup = new Backup()

/**
 * 导入文件
 * @param data 文件内容
 */
export async function importFile(data: mediaLibrary.FileAsset, context: Context): Promise<[boolean, string]> {
  let value = await getPermission_WRITE_MEDIA(context)
  if (value) {
    console.log('import: ' + JSON.stringify(data));
    let obj: string = await readFile(data)
    let ret = JSON.parse(obj)
    console.log('import value: ' + JSON.stringify(ret));
    return new Promise((resolve) => {
      backUpImpl.importData(ret, (flag: boolean, reason: string) => {
        resolve([flag, reason])
      }, context)
    })
  }
}

/**
 * 以promise形式获取备份信息
 */
async function getBackupObject(context: Context): Promise<object> {
  return new Promise((resolve) => {
    backUpImpl.exportData((obj: object) => {
      resolve(obj)
    }, context)
  })
}

/**
 * 备份文件
 */
export async function backupFile(context: Context) {
  //  let data: object = { "text": new Date() }
  let value = await getPermission_WRITE_MEDIA(context)
  if (value) {
    let data: object = await getBackupObject(context)
    let str: string = JSON.stringify(data)
    console.log('backup value: ' + str);
    await writeFile(str, context)
    await deleteRedundancyFile(context)
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
