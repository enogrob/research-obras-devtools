"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const node = require("../node");
const path = require("path");
const vscode = require("vscode");
const util_1 = require("util");
const logger_1 = require("../../util/logger");
const statusBar_1 = require("../../statusBar");
//
//  Implements :write
//  http://vimdoc.sourceforge.net/htmldoc/editing.html#:write
//
class WriteCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._logger = logger_1.Logger.get('Write');
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute(vimState) {
        if (this.arguments.opt) {
            this._logger.warn('not implemented');
            return;
        }
        else if (this.arguments.file) {
            this._logger.warn('not implemented');
            return;
        }
        else if (this.arguments.append) {
            this._logger.warn('not implemented');
            return;
        }
        else if (this.arguments.cmd) {
            this._logger.warn('not implemented');
            return;
        }
        // defer saving the file to vscode if file is new (to present file explorer) or if file is a remote file
        if (vimState.editor.document.isUntitled || vimState.editor.document.uri.scheme !== 'file') {
            await this.background(vscode.commands.executeCommand('workbench.action.files.save'));
            return;
        }
        try {
            await util_1.promisify(fs.access)(vimState.editor.document.fileName, fs.constants.W_OK);
            return this.save(vimState);
        }
        catch (accessErr) {
            if (this.arguments.bang) {
                try {
                    await util_1.promisify(fs.chmod)(vimState.editor.document.fileName, 666);
                    return this.save(vimState);
                }
                catch (e) {
                    statusBar_1.StatusBar.setText(vimState, e.message);
                }
            }
            else {
                statusBar_1.StatusBar.setText(vimState, accessErr.message);
            }
        }
    }
    async save(vimState) {
        await this.background(vimState.editor.document.save().then(() => {
            let text = '"' +
                path.basename(vimState.editor.document.fileName) +
                '" ' +
                vimState.editor.document.lineCount +
                'L ' +
                vimState.editor.document.getText().length +
                'C written';
            statusBar_1.StatusBar.setText(vimState, text);
        }, (e) => statusBar_1.StatusBar.setText(vimState, e)));
    }
    async background(fn) {
        if (!this._arguments.bgWrite) {
            await fn;
        }
    }
}
exports.WriteCommand = WriteCommand;

//# sourceMappingURL=write.js.map
