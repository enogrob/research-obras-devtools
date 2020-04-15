"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const sqlFormatter = require("sql-formatter");
class SqlFormatProvider {
    provideDocumentRangeFormattingEdits(document, range, options, token) {
        return [new vscode.TextEdit(range, sqlFormatter.format(document.getText(range)))];
    }
}
exports.SqlFormatProvider = SqlFormatProvider;
//# sourceMappingURL=SqlFormatProvider.js.map