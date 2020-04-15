"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const vscode = require("vscode");
class HistoryManager {
    constructor(context) {
        this.context = context;
    }
    showHistory() {
        var historyPath = this.context.globalStoragePath + '/history.sql';
        var openPath = vscode.Uri.file(historyPath);
        vscode.workspace.openTextDocument(openPath).then(doc => {
            vscode.window.showTextDocument(doc);
        });
    }
    recordHistory(sql, costTime) {
        if (!sql)
            return;
        return new Promise(() => {
            var gsPath = this.context.globalStoragePath;
            if (!fs.existsSync(gsPath)) {
                fs.mkdirSync(gsPath);
            }
            fs.appendFileSync(gsPath + '/history.sql', `/* ${this.getNowDate()} [${costTime} ms] */ ${sql.replace(/[\r\n]/g, " ")}\n`, { encoding: 'utf8' });
        });
    }
    getNowDate() {
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
            + this.pad(date.getHours(), 2) + ":" + this.pad(date.getMinutes(), 2) + ":" + this.pad(date.getSeconds(), 2);
    }
    pad(n, width, z) {
        z = z || '0';
        n = n + '';
        return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
    }
}
exports.HistoryManager = HistoryManager;
//# sourceMappingURL=HistoryManager.js.map