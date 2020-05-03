"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const node = require("../node");
const quit = require("./quit");
const write = require("./write");
class WriteQuitCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    // Writing command. Taken as a basis from the "write.ts" file.
    async execute(vimState) {
        let writeArgs = {
            opt: this.arguments.opt,
            optValue: this.arguments.optValue,
            bang: this.arguments.bang,
            file: this.arguments.file,
            range: this.arguments.range,
        };
        let writeCmd = new write.WriteCommand(writeArgs);
        await writeCmd.execute(vimState);
        let quitArgs = {
            // wq! fails when no file name is provided
            bang: false,
            range: this.arguments.range,
        };
        let quitCmd = new quit.QuitCommand(quitArgs);
        await quitCmd.execute();
    }
}
exports.WriteQuitCommand = WriteQuitCommand;

//# sourceMappingURL=writequit.js.map
