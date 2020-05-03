"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const wall = require("../commands/wall");
const node = require("../node");
const quit = require("./quit");
class WriteQuitAllCommand extends node.CommandBase {
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
            bang: this.arguments.bang,
        };
        let quitArgs = {
            // wq! fails when no file name is provided
            bang: false,
        };
        const wallCmd = new wall.WallCommand(writeArgs);
        await wallCmd.execute();
        quitArgs.quitAll = true;
        const quitCmd = new quit.QuitCommand(quitArgs);
        await quitCmd.execute();
    }
}
exports.WriteQuitAllCommand = WriteQuitAllCommand;

//# sourceMappingURL=writequitall.js.map
