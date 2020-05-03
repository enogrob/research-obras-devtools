"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const error = require("../../error");
const node = require("../node");
//
//  Implements :quit
//  http://vimdoc.sourceforge.net/htmldoc/editing.html#:quit
//
class QuitCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute() {
        // NOTE: We can't currently get all open text editors, so this isn't perfect. See #3809
        const duplicatedInSplit = vscode.window.visibleTextEditors.filter((editor) => editor.document === this.activeTextEditor.document).length > 1;
        if (this.activeTextEditor.document.isDirty &&
            !this.arguments.bang &&
            (!duplicatedInSplit || this._arguments.quitAll)) {
            throw error.VimError.fromCode(error.ErrorCode.NoWriteSinceLastChange);
        }
        if (this._arguments.quitAll) {
            await vscode.commands.executeCommand('workbench.action.closeAllEditors');
        }
        else {
            if (!this.arguments.bang) {
                await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
            }
            else {
                await vscode.commands.executeCommand('workbench.action.revertAndCloseActiveEditor');
            }
        }
    }
}
exports.QuitCommand = QuitCommand;

//# sourceMappingURL=quit.js.map
