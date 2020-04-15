"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const QueryUnit_1 = require("./database/QueryUnit");
const MysqlTreeDataProvider_1 = require("./provider/MysqlTreeDataProvider");
const CompletionProvider_1 = require("./provider/CompletionProvider");
const DatabaseCache_1 = require("./database/DatabaseCache");
const SqlViewManager_1 = require("./database/SqlViewManager");
const SqlFormatProvider_1 = require("./provider/SqlFormatProvider");
const HistoryManager_1 = require("./extension/HistoryManager");
const Constants_1 = require("./common/Constants");
const TableHoverProvider_1 = require("./provider/TableHoverProvider");
function activate(context) {
    DatabaseCache_1.DatabaseCache.initCache(context);
    SqlViewManager_1.SqlViewManager.initExtesnsionPath(context.extensionPath);
    var historyManager = new HistoryManager_1.HistoryManager(context);
    var mysqlTreeDataProvider = new MysqlTreeDataProvider_1.MySQLTreeDataProvider(context);
    const treeview = vscode.window.createTreeView("github.cweijan.mysql", {
        treeDataProvider: mysqlTreeDataProvider
    });
    treeview.onDidCollapseElement(event => {
        DatabaseCache_1.DatabaseCache.storeElementState(event.element, vscode.TreeItemCollapsibleState.Collapsed);
    });
    treeview.onDidExpandElement(event => {
        DatabaseCache_1.DatabaseCache.storeElementState(event.element, vscode.TreeItemCollapsibleState.Expanded);
    });
    context.subscriptions.push(vscode.languages.registerDocumentRangeFormattingEditProvider('sql', new SqlFormatProvider_1.SqlFormatProvider()), vscode.languages.registerHoverProvider('sql', new TableHoverProvider_1.TableHoverProvider()), vscode.languages.registerCompletionItemProvider('sql', new CompletionProvider_1.CompletionProvider(), ' ', '.'), vscode.commands.registerCommand(Constants_1.CommandKey.Refresh, () => {
        mysqlTreeDataProvider.init();
    }), vscode.commands.registerCommand("mysql.hisotry.open", () => {
        historyManager.showHistory();
    }), vscode.commands.registerCommand(Constants_1.CommandKey.RecordHistory, (sql, costTime) => {
        historyManager.recordHistory(sql, costTime);
    }), vscode.commands.registerCommand("mysql.addDatabase", (connectionNode) => {
        connectionNode.createDatabase();
    }), vscode.commands.registerCommand("mysql.deleteDatabase", (databaseNode) => {
        databaseNode.deleteDatatabase();
    }), vscode.commands.registerCommand("mysql.addConnection", () => {
        SqlViewManager_1.SqlViewManager.showConnectPage();
    }), vscode.commands.registerCommand("mysql.changeTableName", (tableNode) => {
        tableNode.changeTableName();
    }), vscode.commands.registerCommand("mysql.index.template", (tableNode) => {
        tableNode.indexTemplate();
    }), vscode.commands.registerCommand("mysql.table.truncate", (tableNode) => {
        tableNode.truncateTable();
    }), vscode.commands.registerCommand("mysql.table.drop", (tableNode) => {
        tableNode.dropTable();
    }), vscode.commands.registerCommand("mysql.changeColumnName", (columnNode) => {
        columnNode.changeColumnName();
    }), vscode.commands.registerCommand("mysql.column.add", (columnNode) => {
        columnNode.addColumnTemplate();
    }), vscode.commands.registerCommand("mysql.column.update", (columnNode) => {
        columnNode.updateColumnTemplate();
    }), vscode.commands.registerCommand("mysql.column.drop", (columnNode) => {
        columnNode.dropColumnTemplate();
    }), vscode.commands.registerCommand("mysql.deleteConnection", (connectionNode) => {
        connectionNode.deleteConnection(context);
    }), vscode.commands.registerCommand("mysql.runQuery", () => {
        QueryUnit_1.QueryUnit.runQuery();
    }), vscode.commands.registerCommand("mysql.newQuery", (databaseOrConnectionNode) => {
        databaseOrConnectionNode.newQuery();
    }), vscode.commands.registerCommand("mysql.template.sql", (tableNode, run) => {
        tableNode.selectSqlTemplate(run);
    }), vscode.commands.registerCommand("mysql.data.import", (iNode) => {
        vscode.window.showOpenDialog({ filters: { 'Sql': ['sql'] }, canSelectMany: false, openLabel: "Select sql file to import", canSelectFiles: true, canSelectFolders: false }).then(filePath => {
            iNode.importData(filePath[0].fsPath);
        });
    }), vscode.commands.registerCommand("mysql.data.export", (iNode) => {
        vscode.window.showOpenDialog({ canSelectMany: false, openLabel: "Select export file path", canSelectFiles: false, canSelectFolders: true }).then(folderPath => {
            iNode.backupData(folderPath[0].fsPath);
        });
    }), vscode.commands.registerCommand("mysql.template.delete", (tableNode) => {
        tableNode.deleteSqlTemplate();
    }), vscode.commands.registerCommand("mysql.copy.insert", (tableNode) => {
        tableNode.insertSqlTemplate();
    }), vscode.commands.registerCommand("mysql.copy.update", (tableNode) => {
        tableNode.updateSqlTemplate();
    }), vscode.commands.registerCommand("mysql.show.procedure", (procedureNode) => {
        procedureNode.showSource();
    }), vscode.commands.registerCommand("mysql.show.function", (functionNode) => {
        functionNode.showSource();
    }), vscode.commands.registerCommand("mysql.show.trigger", (triggerNode) => {
        triggerNode.showSource();
    }), vscode.commands.registerCommand("mysql.user.sql", (userNode) => {
        userNode.selectSqlTemplate();
    }), vscode.commands.registerCommand("mysql.template.procedure", (procedureGroup) => {
        procedureGroup.createTemplate();
    }), vscode.commands.registerCommand("mysql.template.view", (viewGroup) => {
        viewGroup.createTemplate();
    }), vscode.commands.registerCommand("mysql.template.trigger", (triggerGroup) => {
        triggerGroup.createTemplate();
    }), vscode.commands.registerCommand("mysql.template.function", (functionGroup) => {
        functionGroup.createTemplate();
    }), vscode.commands.registerCommand("mysql.template.user", (userGroup) => {
        userGroup.createTemplate();
    }), vscode.commands.registerCommand("mysql.delete.user", (userNode) => {
        userNode.drop();
    }), vscode.commands.registerCommand("mysql.delete.view", (viewNode) => {
        viewNode.drop();
    }), vscode.commands.registerCommand("mysql.delete.procedure", (procedureNode) => {
        procedureNode.drop();
    }), vscode.commands.registerCommand("mysql.delete.function", (functionNode) => {
        functionNode.drop();
    }), vscode.commands.registerCommand("mysql.delete.trigger", (triggerNode) => {
        triggerNode.drop();
    }), vscode.commands.registerCommand("mysql.change.user", (userNode) => {
        userNode.changePasswordTemplate();
    }));
}
exports.activate = activate;
function deactivate() {
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map