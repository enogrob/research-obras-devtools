"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const mode_1 = require("../../mode/mode");
const textEditor_1 = require("../../textEditor");
const node = require("../node");
const token = require("../token");
class SortCommand extends node.CommandBase {
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
    async execute(vimState) {
        if (mode_1.isVisualMode(vimState.currentMode)) {
            const selection = vimState.editor.selection;
            let start = selection.start;
            let end = selection.end;
            if (start.isAfter(end)) {
                [start, end] = [end, start];
            }
            await this.sortLines(start, end);
        }
        else {
            await this.sortLines(new vscode.Position(0, 0), new vscode.Position(textEditor_1.TextEditor.getLineCount() - 1, 0));
        }
    }
    async sortLines(startLine, endLine) {
        let originalLines = [];
        for (let currentLine = startLine.line; currentLine <= endLine.line && currentLine < textEditor_1.TextEditor.getLineCount(); currentLine++) {
            originalLines.push(textEditor_1.TextEditor.readLineAt(currentLine));
        }
        if (this._arguments.unique) {
            originalLines = [...new Set(originalLines)];
        }
        let lastLineLength = originalLines[originalLines.length - 1].length;
        let sortedLines = this._arguments.ignoreCase
            ? originalLines.sort((a, b) => a.localeCompare(b))
            : originalLines.sort();
        if (this._arguments.reverse) {
            sortedLines.reverse();
        }
        let sortedContent = sortedLines.join('\n');
        await textEditor_1.TextEditor.replace(new vscode.Range(startLine.line, 0, endLine.line, lastLineLength), sortedContent);
    }
    async executeWithRange(vimState, range) {
        let startLine;
        let endLine;
        if (range.left[0].type === token.TokenType.Percent) {
            startLine = new vscode.Position(0, 0);
            endLine = new vscode.Position(textEditor_1.TextEditor.getLineCount() - 1, 0);
        }
        else {
            startLine = range.lineRefToPosition(vimState.editor, range.left, vimState);
            endLine = range.lineRefToPosition(vimState.editor, range.right, vimState);
        }
        await this.sortLines(startLine, endLine);
    }
}
exports.SortCommand = SortCommand;

//# sourceMappingURL=sort.js.map
