import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import common from '@ohos.app.ability.common';

export async function setBackgroundTask(reason: string, tasks: Function[], context: Context) {
  try {
    let delayInfo = backgroundTaskManager.requestSuspendDelay(reason, () => {
      // task(getContext(this) as common.Context)
      console.log("setBackgroundTask, Request suspension delay will time out. ")
    })
    console.log("setBackgroundTask, The requestId is:", reason, delayInfo.requestId, "The actualDelayTime is:", delayInfo.actualDelayTime);
    for(let task of tasks)
      await task(context);
    setTimeout(() => {
      backgroundTaskManager.cancelSuspendDelay(delayInfo.requestId)
      console.log("setBackgroundTask, backgroundTaskManager cancelSuspendDelay", delayInfo.requestId)
    }, 5000)
  } catch (error) {
    console.log("setBackgroundTask, requestSuspendDelay failed. ", JSON.stringify(error));
  }
}