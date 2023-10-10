import { RebuildNotification } from './NotificationController';
import { get_accent } from './AccentController';
import prompt from '@ohos.promptAction';
import { Backup } from '../dao/controller/InitAndTable';
import distributedData from '@ohos.data.distributedKVStore';
import { refreshResource } from './EventsController';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';


PersistentStorage.PersistProp('TerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('LocalVersionNumber', 0)

const Version_Key: string = 'version'
const Data_Key: string = 'data'
const Length_Key: string = 'length'
const MaxLength: number = 400000;

export async function getPermission_DISTRIBUTED_DATASYNC(): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.DISTRIBUTED_DATASYNC'];
  var context: Context = getContext(this) as common.Context;
  let atManager = abilityAccessCtrl.createAtManager();
  let PermissionRequestResult = await atManager.requestPermissionsFromUser(context, array);
  let authResults0 = PermissionRequestResult.authResults[0];
  console.log("====>requestData====> " + authResults0 + ' ,');
  let ret: boolean = ((authResults0 == 0))
  if (!ret) {
    AppStorage.Set('TerminalsSyncSwitch', 0)
    AppStorage.Set('AutoTerminalsSyncSwitch', 0)
  }
  return ret
}

async function getKVStore(): Promise<any> {
  var context: Context = getContext(this) as common.Context;
  const kvManagerConfig = {
    context: context,
    bundleName: 'cn.biandangroup.biandanas'
  }
  let kvManager = distributedData.createKVManager(kvManagerConfig)

  const storeId = 'LatestVersion'
  const options = {
    createIfMissing: true,
    encrypt: false,
    backup: false,
    autoSync: true,
    //    autoSync: false,
    kvStoreType: distributedData.KVStoreType.SINGLE_VERSION,
    securityLevel: distributedData.SecurityLevel.S2,
  };
  let kvStore = await kvManager.getKVStore(storeId, options)
  return kvStore
}

const backUpImpl: Backup = new Backup()

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
 * 打开数据库监听
 */
export async function OpenSyncListener() {
  const kvStore = await getKVStore()
  kvStore.on('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    let TerminalsSyncSwitch = AppStorage.Get<number>('TerminalsSyncSwitch')
    if (!TerminalsSyncSwitch) return;
    let newVersion: number = AppStorage.Get<number>('LocalVersionNumber')
    kvStore.get(Version_Key, function (err, SyncVersion) {
      console.log("get success Version_Key: " + SyncVersion);
      console.log("get error: " + err);
      if (SyncVersion != undefined && SyncVersion > newVersion) {
        AlertDialog.show({
          title: '检测到数据更新',
          message: '有数据可以从其他设备同步，请接收。',
          primaryButton: {
            value: $r('app.string.cancel'),
            fontColor: get_accent(),
            action: () => {
              prompt.showToast({
                message: '已取消，可在 设置-同步 界面重新拉取同步',
                duration: 1000,
              });
            }
          },
          secondaryButton: {
            value: $r('app.string.confirm'),
            fontColor: get_accent(),
            action: () => {
              getNewAndImportData()
              refreshResource()
            }
          },
          cancel: () => {
            prompt.showToast({
              message: '已取消，可在 设置-同步 界面重新拉取同步',
              duration: 1000,
            });
          }
        })
      }
    });
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 关闭数据库监听
 */
export async function CloseSyncListener() {
  const kvStore = await getKVStore()
  kvStore.off('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 导出数据新版本到数据库
 * @param showPrompt 是否前台导出
 */
export async function ExportNewVersion(showPrompt: boolean = false) {
  const kvStore = await getKVStore()

  let data: object = await getBackupObject()
  let str: string = JSON.stringify(data)
  console.log('[Sync] backup value: ' + str);

  let newVersion: number = AppStorage.Get<number>('LocalVersionNumber')

  console.log('[Sync] newVersion: ' + newVersion);
  kvStore.get(Version_Key, function (err, SyncVersion) {
    console.log("get success Version_Key: " + SyncVersion);
    console.log("get error: " + err);
    if (SyncVersion == undefined || SyncVersion < newVersion) {
      console.log('[Sync] newVersion: ' + newVersion);
      kvStore.put(Version_Key, newVersion)

      let i: number = 0;
      for (; i < str.length; i += MaxLength) {
        kvStore.put(Data_Key + (i.toString()), str.substring(i, i + MaxLength))
        //        result.push(str.substring(i, i + MaxLength));
      }
      kvStore.put(Length_Key, str.length)
      //      kvStore.put(Data_Key, str)

      if (showPrompt)
        prompt.showToast({
          message: '发送成功，快去看看吧！',
          duration: 1000,
        });
    } else {
      if (showPrompt)
        prompt.showToast({
          message: '发送失败，发送数据不为最新',
          duration: 1000,
        });
    }
  });
}


/**
 * 从数据库导入数据新版本
 */
async function ImportNewVersion(): Promise<[boolean, number, string]> {
  let TerminalsSyncSwitch = AppStorage.Get<number>('TerminalsSyncSwitch')
  if (!TerminalsSyncSwitch)
    return [false, 0, '']

  const kvStore = await getKVStore()

  let newVersion: number = AppStorage.Get<number>('LocalVersionNumber')

  console.log('[Sync] newVersion: ' + newVersion);

  return new Promise((resolve) => {
    kvStore.get(Version_Key, async function (err, SyncVersion) {
      console.log("get success Version_Key: " + SyncVersion);
      console.log("get error: " + err);
      if (SyncVersion != undefined && SyncVersion > newVersion) {
        let end: number = await kvStore.get(Length_Key)
        let obj: string = ''
        for (let i = 0; i < end; i += MaxLength) {
          obj += await kvStore.get(Data_Key + (i.toString()))
        }
        console.log("get success Data_Key: " + obj);
        console.log("get error: " + err);
        console.log('[Sync] import: ' + JSON.stringify(obj));
        let ret = JSON.parse(obj)
        console.log('[Sync] import value: ' + JSON.stringify(ret));
        backUpImpl.importData(ret, (flag: boolean, reason: string) => {
          resolve([flag, SyncVersion, reason])
        })
      } else {
        resolve([false, SyncVersion, '未接收到新数据'])
      }
    });
  })
}

/**
 * 为当前数据版本编号
 * @param newVersionNumber 指定数据版本
 */
export function UpdateVersionNumber(newVersionNumber: number = new Date().getTime()) {
  if (newVersionNumber <= AppStorage.Get<number>('LocalVersionNumber'))
    return;
  console.log('[Sync] UpdateVersionNumber:' + newVersionNumber)
  AppStorage.Set<number>('LocalVersionNumber', newVersionNumber)
}

/**
 * 获取新的数据并导入
 * @param showFail 是否展示失败提醒
 */
export async function getNewAndImportData(showFail: boolean = true) {
  let TerminalsSyncSwitch = AppStorage.Get<number>('TerminalsSyncSwitch')
  if (!TerminalsSyncSwitch) return;
  let ret: [boolean, number, string] = await ImportNewVersion()
  if (ret[0]) {
    UpdateVersionNumber(ret[1])
    await RebuildNotification()
    prompt.showToast({
      message:  '接收数据成功',
      duration: 1000,
    });
  } else if (showFail) {
    prompt.showToast({
      message: '接收数据失败，' + ret[2],
      duration: 1000,
    });
  }
}