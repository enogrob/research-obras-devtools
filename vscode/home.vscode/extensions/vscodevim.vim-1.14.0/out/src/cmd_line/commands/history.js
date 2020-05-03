"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const node_1 = require("../node");
const actions_1 = require("../../actions/commands/actions");
const searchState_1 = require("../../state/searchState");
var HistoryCommandType;
(function (HistoryCommandType) {
    HistoryCommandType[HistoryCommandType["Cmd"] = 0] = "Cmd";
    HistoryCommandType[HistoryCommandType["Search"] = 1] = "Search";
    HistoryCommandType[HistoryCommandType["Expr"] = 2] = "Expr";
    HistoryCommandType[HistoryCommandType["Input"] = 3] = "Input";
    HistoryCommandType[HistoryCommandType["Debug"] = 4] = "Debug";
    HistoryCommandType[HistoryCommandType["All"] = 5] = "All";
})(HistoryCommandType = exports.HistoryCommandType || (exports.HistoryCommandType = {}));
// http://vimdoc.sourceforge.net/htmldoc/cmdline.html#:history
class HistoryCommand extends node_1.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async execute(vimState) {
        switch (this._arguments.type) {
            case HistoryCommandType.Cmd:
                await new actions_1.CommandShowCommandHistory().exec(vimState.cursorStopPosition, vimState);
                break;
            case HistoryCommandType.Search:
                await new actions_1.CommandShowSearchHistory(searchState_1.SearchDirection.Forward).exec(vimState.cursorStopPosition, vimState);
                break;
            // TODO: Implement these
            case HistoryCommandType.Expr:
                throw new Error('Not implemented');
            case HistoryCommandType.Input:
                throw new Error('Not implemented');
            case HistoryCommandType.Debug:
                throw new Error('Not implemented');
            case HistoryCommandType.All:
                throw new Error('Not implemented');
        }
    }
}
exports.HistoryCommand = HistoryCommand;

//# sourceMappingURL=history.js.map
