"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const logger_1 = require("./logger");
/**
 * A thin wrapper around `vscode.env.clipboard`
 */
class Clipboard {
    static async Copy(text) {
        try {
            await vscode.env.clipboard.writeText(text);
        }
        catch (e) {
            this.logger.error(e, `Error copying to clipboard. err=${e}`);
        }
    }
    static async Paste() {
        return vscode.env.clipboard.readText();
    }
}
exports.Clipboard = Clipboard;
Clipboard.logger = logger_1.Logger.get('Clipboard');

//# sourceMappingURL=clipboard.js.map
