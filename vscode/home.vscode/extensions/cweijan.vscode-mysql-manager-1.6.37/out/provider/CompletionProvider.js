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
const Constants_1 = require("../common/Constants");
const DatabaseCache_1 = require("../database/DatabaseCache");
class CompletionProvider {
    constructor() {
        this.keywordList = ["SELECT", "UPDATE", "DELETE", "TABLE", "INSERT", "INTO", "VALUES", "FROM", "WHERE", "GROUP BY", "ORDER BY", "HAVING", "LIMIT", "ALTER", "CREATE", "DROP", "FUNCTION", "CASE", "PROCEDURE", "TRIGGER", "INDEX", "CHANGE", "COMMENT", "COLUMN", "ADD", 'SHOW', "PRIVILEGES", "IDENTIFIED", "VIEW", "CURSOR", "EXPLAIN"];
        this.functionList = ["CHAR_LENGTH", "CONCAT", "NOW", "DATE_ADD", "DATE_SUB", "MAX", "COUNT", "MIN", "SUM", "AVG", "LENGTH", "IF", "IFNULL", "MD5", "SHA", "CURRENT_TIME", "CURRENT_DATE", "DATE_FORMAT", "CAST"];
        this.defaultComplectionItems = [];
        this.initDefaultComplectionItem();
    }
    provideCompletionItems(document, position) {
        return __awaiter(this, void 0, void 0, function* () {
            let completionItems = [];
            const prePostion = position.character == 0 ? position : new vscode.Position(position.line, position.character - 1);
            const preChart = document.getText(new vscode.Range(prePostion, position));
            if (preChart != "." && preChart != " ") {
                completionItems = completionItems.concat(this.defaultComplectionItems);
            }
            if ((position.character == 0))
                return completionItems;
            let wordRange = document.getWordRangeAtPosition(prePostion);
            const inputWord = document.getText(wordRange);
            if (inputWord && preChart == '.') {
                let subComplectionItems = this.generateTableComplectionItem(inputWord);
                if (subComplectionItems.length == 0) {
                    subComplectionItems = yield CompletionProvider.generateColumnComplectionItem(inputWord);
                    if (subComplectionItems.length == 0) {
                        let tableReg = new RegExp("\\w+(?=\\s*\\b" + inputWord + "\\b)", 'ig');
                        let currentSql = document.getText();
                        let result = tableReg.exec(currentSql);
                        for (; result != null && subComplectionItems.length == 0;) {
                            subComplectionItems = yield CompletionProvider.generateColumnComplectionItem(result[0]);
                            result = tableReg.exec(currentSql);
                        }
                    }
                }
                completionItems = completionItems.concat(subComplectionItems);
            }
            else {
                completionItems = completionItems.concat(this.generateDatabaseComplectionItem(), this.generateTableComplectionItem());
            }
            return completionItems;
        });
    }
    resolveCompletionItem(item) {
        return item;
    }
    initDefaultComplectionItem() {
        this.keywordList.forEach(keyword => {
            let keywordComplectionItem = new vscode.CompletionItem(keyword + " ");
            keywordComplectionItem.kind = vscode.CompletionItemKind.Property;
            this.defaultComplectionItems.push(keywordComplectionItem);
        });
        this.functionList.forEach(keyword => {
            let functionComplectionItem = new vscode.CompletionItem(keyword + " ");
            functionComplectionItem.kind = vscode.CompletionItemKind.Function;
            functionComplectionItem.insertText = new vscode.SnippetString(keyword + "($1)");
            this.defaultComplectionItems.push(functionComplectionItem);
        });
    }
    generateDatabaseComplectionItem() {
        let databaseNodes = DatabaseCache_1.DatabaseCache.getDatabaseNodeList();
        return databaseNodes.map(databaseNode => {
            let completionItem = new vscode.CompletionItem(databaseNode.getTreeItem().label);
            completionItem.kind = vscode.CompletionItemKind.Struct;
            return completionItem;
        });
    }
    generateTableComplectionItem(inputWord) {
        let tableNodes = [];
        if (inputWord) {
            DatabaseCache_1.DatabaseCache.getDatabaseNodeList().forEach(databaseNode => {
                if (databaseNode.database == inputWord)
                    tableNodes = DatabaseCache_1.DatabaseCache.getTableListOfDatabase(databaseNode.identify);
            });
        }
        else {
            tableNodes = DatabaseCache_1.DatabaseCache.getTableNodeList();
        }
        return tableNodes.map((tableNode) => {
            let treeItem = tableNode.getTreeItem();
            let completionItem = new vscode.CompletionItem(treeItem.label);
            switch (tableNode.type) {
                case Constants_1.ModelType.TABLE:
                    completionItem.kind = vscode.CompletionItemKind.Function;
                    break;
                case Constants_1.ModelType.VIEW:
                    completionItem.kind = vscode.CompletionItemKind.Module;
                    break;
                case Constants_1.ModelType.PROCEDURE:
                    completionItem.kind = vscode.CompletionItemKind.Reference;
                    break;
                case Constants_1.ModelType.FUNCTION:
                    completionItem.kind = vscode.CompletionItemKind.Method;
                    break;
                case Constants_1.ModelType.TRIGGER:
                    completionItem.kind = vscode.CompletionItemKind.Event;
                    break;
            }
            return completionItem;
        });
    }
    static generateColumnComplectionItem(inputWord) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!inputWord)
                return [];
            let columnNodes = [];
            for (const tableNode of DatabaseCache_1.DatabaseCache.getTableNodeList()) {
                if (tableNode.table == inputWord) {
                    columnNodes = (yield tableNode.getChildren());
                    break;
                }
            }
            return columnNodes.map(columnNode => {
                let completionItem = new vscode.CompletionItem(columnNode.getTreeItem().columnName);
                completionItem.detail = columnNode.getTreeItem().detail;
                completionItem.documentation = columnNode.getTreeItem().document;
                completionItem.kind = vscode.CompletionItemKind.Function;
                return completionItem;
            });
        });
    }
}
exports.CompletionProvider = CompletionProvider;
//# sourceMappingURL=CompletionProvider.js.map