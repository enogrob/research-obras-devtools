"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const error = require("../../error");
const node = require("../node");
//
//  Implements :close
//  http://vimdoc.sourceforge.net/htmldoc/windows.html#:close
//
class CloseCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute() {
        if (this.activeTextEditor.document.isDirty && !this.arguments.bang) {
            throw error.VimError.fromCode(error.ErrorCode.NoWriteSinceLastChange);
        }
        if (vscode.window.visibleTextEditors.length === 1) {
            throw error.VimError.fromCode(error.ErrorCode.CannotCloseLastWindow);
        }
        let oldViewColumn = this.activeTextEditor.viewColumn;
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        if (vscode.window.activeTextEditor !== undefined &&
            vscode.window.activeTextEditor.viewColumn === oldViewColumn) {
            await vscode.commands.executeCommand('workbench.action.previousEditor');
        }
    }
}
exports.CloseCommand = CloseCommand;

//# sourceMappingURL=close.js.map
