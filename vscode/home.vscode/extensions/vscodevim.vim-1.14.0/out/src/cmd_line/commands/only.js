"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const node = require("../node");
class OnlyCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute() {
        await vscode.commands.executeCommand('workbench.action.closeEditorsInOtherGroups');
        await vscode.commands.executeCommand('workbench.action.maximizeEditor');
        await vscode.commands.executeCommand('workbench.action.closePanel');
        return;
    }
}
exports.OnlyCommand = OnlyCommand;

//# sourceMappingURL=only.js.map
