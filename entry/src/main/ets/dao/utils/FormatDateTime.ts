/**
 * 将Date类型变量格式化为
 * 年月日 YYYY-MM-DD
 */
export function formatDate(date: Date): string {
  let year: string = date.getFullYear().toString();
  let mouth: string = (date.getMonth() + 1).toString();
  let day: string = date.getDate().toString();
  if (date.getMonth() <= 8) {
    mouth = "0" + (date.getMonth() + 1).toString();
  }
  if (date.getDate() <= 9) {
    day = "0" + date.getDate().toString();
  }
  return year + "-" + mouth + "-" + day;
}
/**
 * 将Date类型变量格式化为
 * 时分秒 HH:MM:00
 */
export function formatTime(date: Date): string {
  let hour: string = date.getHours().toString();
  let minute: string = date.getMinutes().toString();
  if (date.getHours() <= 9) {
    hour = "0" + date.getHours().toString();
  }
  if (date.getMinutes() <= 9) {
    minute = "0" + date.getMinutes().toString();
  }
  return hour + ":" + minute + ":00";
}