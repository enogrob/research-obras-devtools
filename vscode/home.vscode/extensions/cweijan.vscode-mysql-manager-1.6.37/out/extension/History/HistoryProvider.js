"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const OutputChannel_1 = require("../../common/OutputChannel");
const QueryUnit_1 = require("../../database/QueryUnit");
class HistoryManager {
    constructor(context) {
        this.context = context;
    }
    showHistory() {
        if (!this.context) {
            OutputChannel_1.Console.log("histroy manager is not init!");
            return;
        }
        ;
        var historyPath = this.context.globalStoragePath + '/history.sql';
        if (fs.existsSync(historyPath)) {
            QueryUnit_1.QueryUnit.showSQLTextDocument(fs.readFileSync(historyPath, { encoding: 'utf8' }));
        }
        else {
            OutputChannel_1.Console.log("history is empty.");
        }
    }
    recordHistory(sql) {
        if (!this.context) {
            OutputChannel_1.Console.log("histroy manager is not init!");
            return;
        }
        ;
        return new Promise(() => {
            var gsPath = this.context.globalStoragePath;
            if (!fs.existsSync(gsPath)) {
                fs.mkdirSync(gsPath);
            }
            fs.appendFileSync(gsPath + '/history.sql', `/*${this.getNowDate()}*/ ${sql}\n`, { encoding: 'utf8' });
        });
    }
    static getNowDate() {
        const date = new Date();
        let month = date.getMonth() + 1;
        let strDate = date.getDate();
        if (month <= 9) {
            month = "0" + month;
        }
        if (strDate <= 9) {
            strDate = "0" + strDate;
        }
        return date.getFullYear() + "-" + month + "-" + strDate + " "
            + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
    }
}
exports.HistoryManager = HistoryManager;
//# sourceMappingURL=HistoryProvider.js.map