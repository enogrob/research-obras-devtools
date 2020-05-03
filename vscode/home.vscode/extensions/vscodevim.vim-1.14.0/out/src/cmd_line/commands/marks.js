"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const node = require("../node");
const textEditor_1 = require("../../textEditor");
const range_1 = require("../../common/motion/range");
class MarkQuickPickItem {
    constructor(mark) {
        this.picked = false;
        this.alwaysShow = false;
        this.mark = mark;
        this.label = mark.name;
        this.description = textEditor_1.TextEditor.getLineAt(mark.position).text.trim();
        this.detail = `line ${mark.position.line} col ${mark.position.character}`;
    }
}
class MarksCommand extends node.CommandBase {
    constructor(marksFilter) {
        super();
        this.marksFilter = marksFilter;
    }
    async execute(vimState) {
        const quickPickItems = vimState.historyTracker
            .getMarks()
            .filter((mark) => {
            return !this.marksFilter || this.marksFilter.includes(mark.name);
        })
            .map((mark) => new MarkQuickPickItem(mark));
        if (quickPickItems.length > 0) {
            const item = await vscode_1.window.showQuickPick(quickPickItems, {
                canPickMany: false,
            });
            if (item) {
                vimState.cursors = [new range_1.Range(item.mark.position, item.mark.position)];
            }
        }
        else {
            vscode_1.window.showInformationMessage('No marks set');
        }
    }
}
exports.MarksCommand = MarksCommand;

//# sourceMappingURL=marks.js.map
