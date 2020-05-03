"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const node = require("../node");
//
//  Implements :wall (write all)
//  http://vimdoc.sourceforge.net/htmldoc/editing.html#:wall
//
class WallCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute() {
        // TODO : overwrite readonly files when bang? == true
        await vscode.workspace.saveAll(false);
    }
}
exports.WallCommand = WallCommand;

//# sourceMappingURL=wall.js.map
