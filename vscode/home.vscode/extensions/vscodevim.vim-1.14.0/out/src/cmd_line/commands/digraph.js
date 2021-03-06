"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const configuration_1 = require("./../../configuration/configuration");
const digraphs_1 = require("../../actions/commands/digraphs");
const node = require("../node");
const textEditor_1 = require("../../textEditor");
class DigraphsCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    makeQuickPicks(digraphs) {
        const quickPicks = new Array();
        for (let digraphKey of Object.keys(digraphs)) {
            let [charDesc, charCodes] = digraphs[digraphKey];
            quickPicks.push({
                label: digraphKey,
                description: `${charDesc} (user)`,
                charCodes,
            });
        }
        return quickPicks;
    }
    async execute(vimState) {
        if (this.arguments.arg !== undefined && this.arguments.arg.length > 2) {
            // TODO: Register digraphs in args in state
        }
        const digraphKeyAndContent = this.makeQuickPicks(configuration_1.configuration.digraphs).concat(this.makeQuickPicks(digraphs_1.DefaultDigraphs));
        vscode.window.showQuickPick(digraphKeyAndContent).then(async (val) => {
            if (val) {
                const char = String.fromCharCode(...val.charCodes);
                await textEditor_1.TextEditor.insert(char);
            }
        });
    }
}
exports.DigraphsCommand = DigraphsCommand;

//# sourceMappingURL=digraph.js.map
