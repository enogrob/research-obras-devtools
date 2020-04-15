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
const fs = require("fs");
const vscode = require("vscode");
const OutputChannel_1 = require("../common/OutputChannel");
const ConnectionManager_1 = require("./ConnectionManager");
const MysqlTreeDataProvider_1 = require("../provider/MysqlTreeDataProvider");
const Constants_1 = require("../common/Constants");
const QueryUnit_1 = require("./QueryUnit");
class ViewOption {
    constructor() {
        this.splitResultView = false;
    }
}
exports.ViewOption = ViewOption;
class SqlViewManager {
    static initExtesnsionPath(extensionPath) {
        this.extensionPath = extensionPath;
    }
    static showQueryResult(viewOption) {
        if (this.resultWebviewPanel) {
            if (this.resultWebviewPanel.visible) {
                this.resultWebviewPanel.webview.postMessage(viewOption);
                this.resultWebviewPanel.reveal(vscode.ViewColumn.Two, true);
                return;
            }
            else {
                this.resultWebviewPanel.dispose();
            }
        }
        viewOption.viewPath = "result";
        viewOption.viewTitle = "Query";
        this.createWebviewPanel(viewOption).then(webviewPanel => {
            this.resultWebviewPanel = webviewPanel;
            webviewPanel.webview.postMessage(viewOption);
            webviewPanel.onDidDispose(() => { this.resultWebviewPanel = undefined; });
            webviewPanel.webview.onDidReceiveMessage((params) => {
                if (params.type == Constants_1.OperateType.execute) {
                    QueryUnit_1.QueryUnit.runQuery(params.sql);
                }
            });
        });
    }
    static showConnectPage() {
        this.createWebviewPanel({
            viewPath: "connect",
            viewTitle: "connect",
            splitResultView: false
        }).then(webviewPanel => {
            webviewPanel.webview.onDidReceiveMessage((params) => {
                if (params.type === 'CONNECT_TO_SQL_SERVER') {
                    ConnectionManager_1.ConnectionManager.getConnection(params.connectionOption).then(() => {
                        MysqlTreeDataProvider_1.MySQLTreeDataProvider.instance.addConnection(params.connectionOption);
                        webviewPanel.dispose();
                    }).catch((err) => {
                        webviewPanel.webview.postMessage({
                            type: 'CONNECTION_ERROR',
                            err
                        });
                    });
                }
            });
        });
    }
    static createWebviewPanel(viewOption) {
        let columnType = viewOption.splitResultView ? vscode.ViewColumn.Two : vscode.ViewColumn.One;
        return new Promise((resolve, reject) => {
            fs.readFile(`${this.extensionPath}/resources/webview/${viewOption.viewPath}.html`, 'utf8', (err, data) => __awaiter(this, void 0, void 0, function* () {
                if (err) {
                    OutputChannel_1.Console.log(err);
                    reject(err);
                    return;
                }
                const webviewPanel = yield vscode.window.createWebviewPanel("mysql.sql.result", viewOption.viewTitle, { viewColumn: columnType, preserveFocus: true }, { enableScripts: true, retainContextWhenHidden: true });
                webviewPanel.webview.html = data.replace(/\$\{webviewPath\}/gi, vscode.Uri.file(`${this.extensionPath}/resources/webview`)
                    .with({ scheme: 'vscode-resource' }).toString());
                webviewPanel.webview.onDidReceiveMessage(viewOption.receiveListener);
                webviewPanel.onDidDispose(viewOption.disposeListener);
                resolve(webviewPanel);
            }));
        });
    }
}
exports.SqlViewManager = SqlViewManager;
//# sourceMappingURL=SqlViewManager.js.map