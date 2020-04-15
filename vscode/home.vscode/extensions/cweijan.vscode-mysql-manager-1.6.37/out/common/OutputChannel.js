"user strict";
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
class Console {
    static log(value) {
        Console.outputChannel.show(true);
        Console.outputChannel.appendLine(value + "");
    }
}
Console.outputChannel = vscode.window.createOutputChannel("MySQL");
exports.Console = Console;
//# sourceMappingURL=OutputChannel.js.map