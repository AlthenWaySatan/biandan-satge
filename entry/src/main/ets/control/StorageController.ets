import data_preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';

/**
 * 轻量级数据库插入数据
 * @param name
 * @param key
 * @param value
 */
export function setStorage(name:string, key: string, value: string) {
    let context: Context = getContext(this) as common.Context;
    data_preferences.getPreferences(context, name).then((preferences) => {
        console.log('myFormAbility 设置（' + name + ',' + key + '):' + value);
        preferences.put(key, value)
        preferences.flush()
    })
}

/**
 * 轻量级数据库获取数据
 * @param name
 * @param key
 * @param type 获取类型
 */
export async function getStorage(name:string, key: string): Promise<string> {
    let context: Context = getContext(this) as common.Context;
    return new Promise((resolve) => {
        data_preferences.getPreferences(context, name).then((preferences) => {
            preferences.get(key, "string").then((value) => {
                resolve(String(value));
                console.log('myFormAbility 查询（' + name + ',' + key + '):' + value);
            })
        })
    })
}

/**
 * 轻量级数据库获取数据
 * @param name
 * @param key
 * @param type 获取类型
 */
export async function getAllStorage(name:string): Promise<string[]> {
    let context: Context = getContext(this) as common.Context;
    return new Promise((resolve) => {
        data_preferences.getPreferences(context, name).then((preferences) => {
            preferences.getAll().then((value) => {
                resolve(Object.keys(value));
                console.log('myFormAbility 查询所有（' + name + '):' + value);
            })
        })
    })
}

/**
 * 轻量级数据库查询是否存在
 * @param name
 * @param key
 */
export async function hasStorage(name:string, key: string): Promise<boolean> {
    let context: Context = getContext(this) as common.Context;
    return new Promise((resolve) => {
        data_preferences.getPreferences(context, name).then((preferences) => {
            preferences.has(key).then((value) => {
                resolve(value);
                console.log('myFormAbility 是否存在（' + name + ',' + key + '):' + value);
            })
        })
    })
}

/**
 * 删除轻量级数据库
 * @param name
 */
export function deleteStorage(name:string, key: string) {
    let context: Context = getContext(this) as common.Context;
    data_preferences.getPreferences(context, name).then((preferences) => {
        preferences.delete(key).then(() => {
            console.log('myFormAbility 删除（' + name + ',' + key + '):');
        })
    })
}