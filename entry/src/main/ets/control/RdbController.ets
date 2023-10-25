import { EventInfo } from '../model/EventInfo';
import { ShowTaskImpl } from '../dao/controller/ShowTaskImpl';
import { ShowTaskInterface } from '../dao/controller/Interface/ShowTaskInterface';
import common from '@ohos.app.ability.common';

export const showTaskImpl: ShowTaskInterface = new ShowTaskImpl(getContext(this) as common.Context);

export async function getEventResource(date: number[], folderId: number): Promise<[number, number, EventInfo[], EventInfo[], EventInfo[]]> {
    if (isNaN(folderId)) folderId = 0
    let thisDate: number[] = [(new Date().getFullYear()), (new Date().getMonth() + 1), (new Date().getDate())]
    if (date[0] != thisDate[0]) {
        if (date[0] < thisDate[0]) date.push(23, 59)
        else date.push(0, 0)
    } else if (date[1] != thisDate[1]) {
        if (date[1] < thisDate[1]) date.push(23, 59)
        else date.push(0, 0)
    } else if (date[2] != thisDate[2]) {
        if (date[2] < thisDate[2]) date.push(23, 59)
        else date.push(0, 0)
    } else {
        date.push((new Date().getHours()), (new Date().getMinutes()));
    }
    console.log('myFormAbility 待办内容：{日期：' + date + ' 分类：' + folderId + '}');

    return new Promise((resolve) => {
        showTaskImpl.queryDisplayTaskContext(new Date(date[0], date[1] - 1, date[2], date[3], date[4]), folderId, (
            finishedCount: number, notFinishedCount: number, TodoArray: EventInfo[], PassArray: EventInfo[], DoneArray: EventInfo[]
        ) => {
            if (TodoArray == null) TodoArray = []
            if (PassArray == null) PassArray = []
            if (DoneArray == null) DoneArray = []

            console.log('1-2.事件内容(number)：' + finishedCount + ', ' + notFinishedCount);
            console.log('1-2.事件内容(length)：' + TodoArray.length + ', ' + PassArray.length + ', ' + DoneArray.length);
            resolve([finishedCount, notFinishedCount, TodoArray, PassArray, DoneArray])
        })
    })
}