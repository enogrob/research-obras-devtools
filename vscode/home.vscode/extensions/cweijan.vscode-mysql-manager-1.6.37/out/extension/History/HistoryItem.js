"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const QueryUnit_1 = require("../../database/QueryUnit");
class HistoryItem extends vscode_1.TreeItem {
    show() {
        QueryUnit_1.QueryUnit.showSQLTextDocument(this.label);
    }
    constructor(label) {
        super(label, vscode_1.TreeItemCollapsibleState.None);
        this.tooltip = "execute time : " + HistoryItem.getNowDate();
        this.command = {
            command: "mysql.history.open",
            title: "Open History",
            arguments: [this, true]
        };
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
exports.HistoryItem = HistoryItem;
//# sourceMappingURL=HistoryItem.js.map