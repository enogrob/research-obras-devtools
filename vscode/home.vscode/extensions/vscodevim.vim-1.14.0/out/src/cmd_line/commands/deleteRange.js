"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const position_1 = require("../../common/motion/position");
const register_1 = require("../../register/register");
const textEditor_1 = require("../../textEditor");
const node = require("../node");
const token = require("../token");
class DeleteRangeCommand extends node.CommandBase {
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
    async deleteRange(start, end, vimState) {
        start = start.getLineBegin();
        end = end.getLineEnd();
        end = position_1.Position.FromVSCodePosition(end.with(end.line, end.character + 1));
        const isOnLastLine = end.line === textEditor_1.TextEditor.getLineCount() - 1;
        if (end.character === textEditor_1.TextEditor.getLineAt(end).text.length + 1) {
            end = end.getDownWithDesiredColumn(0);
        }
        if (isOnLastLine && start.line !== 0) {
            start = start.getPreviousLineBegin().getLineEnd();
        }
        let text = vimState.editor.document.getText(new vscode.Range(start, end));
        text = text.endsWith('\r\n') ? text.slice(0, -2) : text.slice(0, -1);
        await textEditor_1.TextEditor.delete(new vscode.Range(start, end));
        let resultPosition = position_1.Position.earlierOf(start, end);
        if (start.character > textEditor_1.TextEditor.getLineAt(start).text.length) {
            resultPosition = start.getLeft();
        }
        else {
            resultPosition = start;
        }
        resultPosition = resultPosition.getLineBegin();
        vimState.editor.selection = new vscode.Selection(resultPosition, resultPosition);
        return text;
    }
    async execute(vimState) {
        if (!vimState.editor) {
            return;
        }
        let cursorPosition = position_1.Position.FromVSCodePosition(vimState.editor.selection.active);
        let text = await this.deleteRange(cursorPosition, cursorPosition, vimState);
        register_1.Register.putByKey(text, this._arguments.register, register_1.RegisterMode.LineWise);
    }
    async executeWithRange(vimState, range) {
        let start;
        let end;
        if (range.left[0].type === token.TokenType.Percent) {
            start = new vscode.Position(0, 0);
            end = new vscode.Position(textEditor_1.TextEditor.getLineCount() - 1, 0);
        }
        else {
            start = range.lineRefToPosition(vimState.editor, range.left, vimState);
            end = range.lineRefToPosition(vimState.editor, range.right, vimState);
        }
        let text = await this.deleteRange(position_1.Position.FromVSCodePosition(start), position_1.Position.FromVSCodePosition(end), vimState);
        register_1.Register.putByKey(text, this._arguments.register, register_1.RegisterMode.LineWise);
    }
}
exports.DeleteRangeCommand = DeleteRangeCommand;

//# sourceMappingURL=deleteRange.js.map
