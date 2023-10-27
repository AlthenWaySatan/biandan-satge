import distributedData from '@ohos.data.distributedKVStore';
import common from '@ohos.app.ability.common';
import deviceInfo from '@ohos.deviceInfo';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';

PersistentStorage.PersistProp('TerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('AutoTerminalsSyncSwitch', 0)
PersistentStorage.PersistProp('LocalVersionNumber', 0)
PersistentStorage.PersistProp('LocalDevicesCode', '')

const Device_Key: string = 'device'

export async function getPermission_DISTRIBUTED_DATASYNC(context: Context): Promise<boolean> {
  let array: Array<Permissions> = ['ohos.permission.DISTRIBUTED_DATASYNC'];
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

async function getKVStore(context: Context): Promise<any> {
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
export async function OpenSyncListener_devices(callback: Function, context: Context) {
  const kvStore = await getKVStore(context)
  kvStore.on('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    callback()
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 关闭数据库监听
 */
export async function CloseSyncListener_devices(context: Context) {
  const kvStore = await getKVStore(context)
  kvStore.off('dataChange', distributedData.SubscribeType.SUBSCRIBE_TYPE_ALL, function (data) {
    console.log("[Sync] dataChange callback call data: " + JSON.stringify(data));
  });
}

/**
 * 清空数据库
 */
export async function clearTerminalsList(context: Context) {
  let TerminalsSyncSwitch = AppStorage.Get<number>('TerminalsSyncSwitch')
  if (TerminalsSyncSwitch == 0) return;
  const kvStore = await getKVStore(context)
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
export async function getTerminalsList(context: Context): Promise<object[]> {
  let TerminalsSyncSwitch = AppStorage.Get<number>('TerminalsSyncSwitch')
  if (TerminalsSyncSwitch == 0)
    return []
  const kvStore = await getKVStore(context)
  let thisDevice = getLocalTerminals()
  return new Promise((resolve) => {
    kvStore.get(Device_Key, function (err, DeviceList) {
      console.log("get success Device_Key: " + DeviceList);
      // console.log("get success Device_Key: typeof " + typeof (DeviceList) + " " + Object.prototype.toString.call(DeviceList));
      console.log("get error: " + err);
      let deviceList: object[] = (DeviceList == undefined || DeviceList == "") ? [] : JSON.parse(DeviceList)
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
