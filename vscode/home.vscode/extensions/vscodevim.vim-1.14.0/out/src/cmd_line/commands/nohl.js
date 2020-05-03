"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const node = require("../node");
const globalState_1 = require("../../state/globalState");
const statusBar_1 = require("../../statusBar");
class NohlCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute(vimState) {
        globalState_1.globalState.hl = false;
        // Clear the `match x of y` message from status bar
        statusBar_1.StatusBar.clear(vimState);
    }
}
exports.NohlCommand = NohlCommand;

//# sourceMappingURL=nohl.js.map
