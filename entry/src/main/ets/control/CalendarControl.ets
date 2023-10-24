PersistentStorage.PersistProp('FirstDayOfWeek', 0)

export function getStartDate(date: number[]): number[] {
  var dateTime = new Date(date[0], date[1] - 1, 1);
  let FirstDayOfWeek = AppStorage.Get<number>('FirstDayOfWeek')
  if (FirstDayOfWeek == 0)
    dateTime = new Date(dateTime.setDate(dateTime.getDate() - (dateTime.getDay() + 6) % 7));
  else
    dateTime = new Date(dateTime.setDate(dateTime.getDate() - dateTime.getDay()));
  return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
}

/**
* 获取下n天
*/
export function getNextNDay(date: number[], n: number): number[] {
  if (n == 0)
    return date;
  var dateTime = new Date(date[0], date[1] - 1, date[2]);
  dateTime = new Date(dateTime.setDate(dateTime.getDate() + n));
  return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
}

/**
 * 获取上/下个月
 */
export function getNextNMonth(date: number[], n: number): number[] {
  var dateTime = new Date(date[0], date[1] - 1, date[2]);
  dateTime = new Date(dateTime.setMonth(dateTime.getMonth() + n));
  if (dateTime.getMonth() == (date[1] + n + 11) % 12)
    return [(dateTime.getFullYear()), (dateTime.getMonth() + 1), (dateTime.getDate())]
  else
    return [date[0], (date[1] + n + 11) % 12 + 1, 1]
}