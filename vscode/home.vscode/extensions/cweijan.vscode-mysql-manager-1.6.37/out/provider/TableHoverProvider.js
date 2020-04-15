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
const DatabaseCache_1 = require("../database/DatabaseCache");
class TableHoverProvider {
    provideHover(document, position, token) {
        return __awaiter(this, void 0, void 0, function* () {
            const tableName = document.getText(document.getWordRangeAtPosition(position));
            for (const tableNode of DatabaseCache_1.DatabaseCache.getTableNodeList()) {
                if (tableNode.table == tableName) {
                    let columnNodes = (yield tableNode.getChildren());
                    let hoverContent = `${tableNode.database}.${tableName}:`;
                    for (const columnNode of columnNodes) {
                        hoverContent += `
${columnNode.column.COLUMN_NAME} ${columnNode.column.COLUMN_TYPE} ${columnNode.column.COLUMN_COMMENT ? 'comment ' + columnNode.column.COLUMN_COMMENT : ''} `;
                    }
                    let markdownStr = new vscode.MarkdownString();
                    markdownStr.appendCodeblock(hoverContent, 'sql');
                    return new vscode.Hover(markdownStr);
                }
            }
            return null;
        });
    }
}
exports.TableHoverProvider = TableHoverProvider;
//# sourceMappingURL=TableHoverProvider.js.map