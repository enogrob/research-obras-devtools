"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const fs = require("fs");
const Constants_1 = require("../common/Constants");
const OutputChannel_1 = require("../common/OutputChannel");
const util_1 = require("../common/util");
const ConnectionManager_1 = require("./ConnectionManager");
const SqlViewManager_1 = require("./SqlViewManager");
class QueryUnit {
    static getConfiguration() {
        return vscode.workspace.getConfiguration("vscode-mysql");
    }
    static queryPromise(connection, sql) {
        return new Promise((resolve, reject) => {
            // Console.log(`Execute SQL:${sql}`)
            connection.query(sql, (err, rows) => {
                if (err) {
                    OutputChannel_1.Console.log(err);
                    reject("Error: " + err.message);
                }
                else {
                    resolve(rows);
                }
            });
        });
    }
    static runQuery(sql, connectionOptions) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!sql && !vscode.window.activeTextEditor) {
                vscode.window.showWarningMessage("No SQL file selected");
                return;
            }
            let connection;
            if (!connectionOptions && !(connection = yield ConnectionManager_1.ConnectionManager.getLastActiveConnection())) {
                vscode.window.showWarningMessage("No MySQL Server or Database selected");
                return;
            }
            else if (connectionOptions) {
                connectionOptions.multipleStatements = true;
                connection = yield ConnectionManager_1.ConnectionManager.getConnection(connectionOptions);
            }
            let fromEditor = false;
            if (!sql) {
                fromEditor = true;
                const activeTextEditor = vscode.window.activeTextEditor;
                const selection = activeTextEditor.selection;
                if (selection.isEmpty) {
                    sql = this.obtainSql(activeTextEditor);
                }
                else {
                    sql = activeTextEditor.document.getText(selection);
                }
            }
            sql = sql.replace(/--.+/ig, '');
            let executeTime = new Date().getTime();
            connection.query(sql, (err, data) => {
                if (err) {
                    //TODO trans output to query page
                    OutputChannel_1.Console.log(err);
                    return;
                }
                var costTime = new Date().getTime() - executeTime;
                if (fromEditor)
                    vscode.commands.executeCommand(Constants_1.CommandKey.RecordHistory, sql, costTime);
                if (sql.match(this.ddlPattern)) {
                    vscode.commands.executeCommand(Constants_1.CommandKey.Refresh);
                    return;
                }
                if (Array.isArray(data)) {
                    SqlViewManager_1.SqlViewManager.showQueryResult({ sql, data, splitResultView: true, costTime: costTime });
                }
                else {
                    OutputChannel_1.Console.log(`execute sql success:${sql}`);
                }
            });
        });
    }
    static obtainSql(activeTextEditor) {
        var content = activeTextEditor.document.getText();
        if (content.match(this.batchPattern))
            return content;
        var sqlList = content.split(";");
        var doc_cursor = activeTextEditor.document.getText(Constants_1.Cursor.getRangeStartTo(activeTextEditor.selection.active)).length;
        var index = 0;
        for (let sql of sqlList) {
            index += (sql.length + 1);
            if (doc_cursor < index) {
                return sql.trim() + ";";
            }
        }
        return '';
    }
    static createSQLTextDocument(sql = "") {
        return __awaiter(this, void 0, void 0, function* () {
            const textDocument = yield vscode.workspace.openTextDocument({ content: sql, language: "sql" });
            return vscode.window.showTextDocument(textDocument);
        });
    }
    static showSQLTextDocument(sql = "") {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.sqlDocument && !this.sqlDocument.document.isClosed && !this.sqlDocument['_disposed'] && this.sqlDocument.document.isUntitled) {
                this.sqlDocument.edit((editBuilder) => {
                    editBuilder.replace(Constants_1.Cursor.getRangeStartTo(util_1.Util.getDocumentLastPosition(this.sqlDocument.document)), sql);
                });
            }
            else {
                const textDocument = yield vscode.workspace.openTextDocument({ content: sql, language: "sql" });
                this.sqlDocument = yield vscode.window.showTextDocument(textDocument);
            }
            return this.sqlDocument;
        });
    }
    static runFile(connection, fsPath) {
        var stats = fs.statSync(fsPath);
        var startTime = new Date();
        var fileSize = stats["size"];
        let success = true;
        if (fileSize > 1024 * 1024 * 100) {
            success = this.executeByLine(connection, fsPath);
        }
        else {
            var fileContent = fs.readFileSync(fsPath, 'utf8');
            connection.query(fileContent, (err, data) => {
                if (err) {
                    OutputChannel_1.Console.log(err);
                    success = false;
                }
            });
        }
        if (success)
            OutputChannel_1.Console.log(`import success, cost time : ${new Date().getTime() - startTime.getTime()}ms`);
    }
    static executeByLine(connection, fsPath) {
        var readline = require('readline');
        var rl = readline.createInterface({
            input: fs.createReadStream(fsPath.replace("\\", "/")),
            terminal: false
        });
        rl.on('line', (chunk) => {
            let sql = chunk.toString('utf8');
            connection.query(sql, (err, sets, fields) => {
                if (err)
                    OutputChannel_1.Console.log(`execute sql ${sql} fail,${err}`);
            });
        });
        return true;
    }
}
QueryUnit.maxTableCount = QueryUnit.getConfiguration().get("maxTableCount");
QueryUnit.ddlPattern = /^(alter|create|drop)/ig;
QueryUnit.batchPattern = /\s+(TRIGGER|PROCEDURE|FUNCTION)\s+/ig;
exports.QueryUnit = QueryUnit;
//# sourceMappingURL=QueryUnit.js.map