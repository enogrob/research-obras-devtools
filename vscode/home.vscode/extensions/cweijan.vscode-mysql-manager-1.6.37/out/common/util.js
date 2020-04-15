"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
class Util {
    /**
     * trim array, got from SO.
     * @param origin origin array
     * @param attr duplicate check attribute
     */
    static trim(origin, attr) {
        let seen = new Set();
        return origin.filter(item => {
            let temp = item[attr];
            return seen.has(temp) ? false : seen.add(temp);
        });
    }
    static getDocumentLastPosition(document) {
        let lastLine = document.lineCount - 1;
        return new vscode_1.Position(lastLine, document.lineAt(lastLine).text.length);
    }
}
exports.Util = Util;
//# sourceMappingURL=util.js.map