/*
事件分类
 */
export class FavoritesData {
    id3: number;
    favoritesName: string;
    favoritesColor: string;
    count?: number;

    constructor(id3: number, favoritesName: string, favoritesColor: string) {
        this.id3 = id3;
        this.favoritesName = favoritesName;
        this.favoritesColor = favoritesColor;
    }
}

export function resultToFavoritesData(resultSet): Array<FavoritesData> {
    let favoritesArray: Array<FavoritesData> = [];
    let countRow = resultSet.rowCount;
    resultSet.goToFirstRow();
    for (let i = 0;i < countRow; i++) {
        let tmp: FavoritesData = new FavoritesData(0, " ", " ");
        tmp.id3 = resultSet.getDouble(resultSet.getColumnIndex("id3"));
        tmp.favoritesName = resultSet.getString(resultSet.getColumnIndex("favoritesName"));
        tmp.favoritesColor = resultSet.getString(resultSet.getColumnIndex("favoritesColor"));

        console.info("[BianDanAPP] [verbose] tag:FavoritesData-- msg:resultToFavoritesData " + i + ": " + JSON.stringify(tmp));
        favoritesArray.push(tmp);
        resultSet.goToNextRow();
    }
    return favoritesArray;
}

export function resultToFArray(resultSet): Array<any> {
    let favoritesArray: Array<[number, string, string]> = [];
    let countRow = resultSet.rowCount;
    resultSet.goToFirstRow();
    for (let i = 0;i < countRow; i++) {
        let tmp: [number, string, string] = [0, "", ""];
        tmp[0] = resultSet.getDouble(resultSet.getColumnIndex("id3"));
        tmp[1] = resultSet.getString(resultSet.getColumnIndex("favoritesName"));
        tmp[2] = resultSet.getString(resultSet.getColumnIndex("favoritesColor"));

        console.info("[BianDanAPP] [verbose] tag:FavoritesData-- msg:resultToFavoritesData " + i + ": " + JSON.stringify(tmp));
        favoritesArray.push(tmp);
        resultSet.goToNextRow();
    }

    return favoritesArray;
}