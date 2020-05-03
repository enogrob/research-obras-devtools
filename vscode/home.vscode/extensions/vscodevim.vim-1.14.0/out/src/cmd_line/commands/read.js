"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const child_process_1 = require("child_process");
const fs_1 = require("fs");
const textEditor_1 = require("../../textEditor");
const node = require("../node");
//
//  Implements :read and :read!
//  http://vimdoc.sourceforge.net/htmldoc/insert.html#:read
//  http://vimdoc.sourceforge.net/htmldoc/insert.html#:read!
//
class ReadCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    neovimCapable() {
        return true;
    }
    async execute() {
        const textToInsert = await this.getTextToInsert();
        if (textToInsert) {
            await textEditor_1.TextEditor.insert(textToInsert);
        }
    }
    async getTextToInsert() {
        if (this.arguments.file && this.arguments.file.length > 0) {
            return this.getTextToInsertFromFile();
        }
        else if (this.arguments.cmd && this.arguments.cmd.length > 0) {
            return this.getTextToInsertFromCmd();
        }
        else {
            throw Error('Invalid arguments');
        }
    }
    async getTextToInsertFromFile() {
        // TODO: Read encoding from ++opt argument.
        return new Promise((resolve, reject) => {
            try {
                fs_1.readFile(this.arguments.file, 'utf8', (err, data) => {
                    if (err) {
                        reject(err);
                    }
                    else {
                        resolve(data);
                    }
                });
            }
            catch (e) {
                reject(e);
            }
        });
    }
    async getTextToInsertFromCmd() {
        return new Promise((resolve, reject) => {
            try {
                child_process_1.exec(this.arguments.cmd, (err, stdout, stderr) => {
                    if (err) {
                        reject(err);
                    }
                    else {
                        resolve(stdout);
                    }
                });
            }
            catch (e) {
                reject(e);
            }
        });
    }
}
exports.ReadCommand = ReadCommand;

//# sourceMappingURL=read.js.map
