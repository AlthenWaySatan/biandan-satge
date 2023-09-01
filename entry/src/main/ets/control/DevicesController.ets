import distributedData from '@ohos.data.distributedKVStore';
import common from '@ohos.app.ability.common';
import deviceInfo from '@ohos.deviceInfo';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';

PersistentStorage.PersistProp('TerminalsSyncSwitch', false)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', false)
PersistentStorage.PersistProp('LocalVersionNumber', 0)
PersistentStorage.PersistProp('LocalDevicesCode', '')

const Device_Key: string = 'device'

export async function getPermission_DISTRIBUTED_DATASYNC(): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.DISTRIBUTED_DATASYNC'];
  var context: Context = getContext(this) as common.Context;
  let atManager = abilityAccessCtrl.createAtManager();
  let PermissionRequestResult = await atManager.requestPermissionsFromUser(context, array);
  let authResults0 = PermissionRequestResult.authResults[0];
  console.log("====>requestData====> " + authResults0 + ' ,');
  let ret: boolean = ((authResults0 == 0))
  if (!ret) {
    AppStorage.Set('TerminalsSyncSwitch', false)
    AppStorage.Set('AutoTerminalsSyncSwitch', false)
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

  const storeId = 'Devices'
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

/**
 * 打开数据库监听
 * @param callback 回调函数
 */
export async function OpenSyncListener_devices(callback: Function) {
  const kvStore = await getKVStore()
  kvStore.on('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    callback()
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 关闭数据库监听
 */
export async function CloseSyncListener_devices() {
  const kvStore = await getKVStore()
  kvStore.off('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 清空数据库
 */
export async function clearTerminalsList() {
  let TerminalsSyncSwitch = AppStorage.Get<boolean>('TerminalsSyncSwitch')
  if (!TerminalsSyncSwitch) return;
  const kvStore = await getKVStore()
  kvStore.put(Device_Key, '')
}

/**
 * 获取随机代码
 */
function getLocalDevicesId(): string {
  let thisCode = AppStorage.Get<string>('LocalDevicesCode')
  if (thisCode.length == 16)
    return thisCode
  let outString = '';
  let inOptions = 'abcdefghijklmnopqrstuvwxyz0123456789';
  for (let i = 0; i < 16; i++) {
    outString += inOptions.charAt(Math.floor(Math.random() * inOptions.length));
  }
  AppStorage.Set<string>('LocalDevicesCode', outString)
  return outString
}

/**
 * 获取本地设备信息
 */
export function getLocalTerminals(): object {
  return {
    'type': deviceInfo.deviceType,
    'name': deviceInfo.marketName,
    'id': getLocalDevicesId()
  }
}

/**
 * 获取组网内设备信息
 */
export async function getTerminalsList(): Promise<object[]> {
  let TerminalsSyncSwitch = AppStorage.Get<boolean>('TerminalsSyncSwitch')
  if (!TerminalsSyncSwitch)
    return []
  const kvStore = await getKVStore()
  let thisDevice = getLocalTerminals()
  return new Promise((resolve) => {
    kvStore.get(Device_Key, function (err, DeviceList) {
      console.log("get success Device_Key: " + DeviceList);
      console.log("get error: " + err);
      let deviceList: object[] = (DeviceList == undefined) ? [] : JSON.parse(DeviceList)
      if (!deviceList.some(item => JSON.stringify(item) === JSON.stringify(thisDevice))) {
        deviceList.push(thisDevice)
        DeviceList = JSON.stringify(deviceList)
        console.log("[Sync] get new Device_Key: " + DeviceList);
        kvStore.put(Device_Key, DeviceList)
      }
      resolve(deviceList)
    });
  })
}
