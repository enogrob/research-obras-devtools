"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const position_1 = require("./common/motion/position");
const configuration_1 = require("./configuration/configuration");
const mode_1 = require("./mode/mode");
/**
 * Collection of helper functions around vscode.window.activeTextEditor
 */
class TextEditor {
    // TODO: Refactor args
    /**
     * Verify that a tab is even open for the TextEditor to act upon.
     *
     * This class was designed assuming there will usually be an active editor
     * to act upon, which is usually true with editor hotkeys.
     *
     * But there are cases where an editor won't be active, such as running
     * code on VSCodeVim activation, where you might see the error:
     * > [Extension Host] Here is the error stack:
     * > TypeError: Cannot read property 'document' of undefined
     */
    static get isActive() {
        return vscode.window.activeTextEditor != null;
    }
    /**
     * @deprecated Use InsertTextTransformation (or InsertTextVSCodeTransformation) instead.
     */
    static async insert(text, at = undefined, letVSCodeHandleKeystrokes = undefined) {
        // If we insert "blah(" with default:type, VSCode will insert the closing ).
        // We *probably* don't want that to happen if we're inserting a lot of text.
        if (letVSCodeHandleKeystrokes === undefined) {
            letVSCodeHandleKeystrokes = text.length === 1;
        }
        if (!letVSCodeHandleKeystrokes) {
            // const selections = vscode.window.activeTextEditor!.selections.slice(0);
            await vscode.window.activeTextEditor.edit((editBuilder) => {
                if (!at) {
                    at = position_1.Position.FromVSCodePosition(vscode.window.activeTextEditor.selection.active);
                }
                editBuilder.insert(at, text);
            });
            // maintain all selections in multi-cursor mode.
            // vscode.window.activeTextEditor!.selections = selections;
        }
        else {
            await vscode.commands.executeCommand('default:type', { text });
        }
    }
    /**
     * @deprecated Use InsertTextTransformation (or InsertTextVSCodeTransformation) instead.
     */
    static async insertAt(text, position) {
        return vscode.window.activeTextEditor.edit((editBuilder) => {
            editBuilder.insert(position, text);
        });
    }
    /**
     * @deprecated Use DeleteTextTransformation or DeleteTextRangeTransformation instead.
     */
    static async delete(range) {
        return vscode.window.activeTextEditor.edit((editBuilder) => {
            editBuilder.delete(range);
        });
    }
    static getDocumentVersion() {
        return vscode.window.activeTextEditor.document.version;
    }
    static getDocumentName() {
        return vscode.window.activeTextEditor.document.fileName;
    }
    /**
     * @deprecated. Use ReplaceTextTransformation instead.
     */
    static async replace(range, text) {
        return vscode.window.activeTextEditor.edit((editBuilder) => {
            editBuilder.replace(range, text);
        });
    }
    static readLineAt(lineNo) {
        if (lineNo === null) {
            lineNo = vscode.window.activeTextEditor.selection.active.line;
        }
        if (lineNo >= vscode.window.activeTextEditor.document.lineCount) {
            throw new RangeError();
        }
        return vscode.window.activeTextEditor.document.lineAt(lineNo).text;
    }
    static getLineCount(textEditor) {
        var _a;
        textEditor = textEditor !== null && textEditor !== void 0 ? textEditor : vscode.window.activeTextEditor;
        return (_a = textEditor === null || textEditor === void 0 ? void 0 : textEditor.document.lineCount) !== null && _a !== void 0 ? _a : -1;
    }
    static getLineLength(line) {
        if (line < 0 || line > TextEditor.getLineCount()) {
            throw new Error(`getLineLength() called with out-of-bounds line ${line}`);
        }
        return TextEditor.readLineAt(line).length;
    }
    static getLine(lineNumber) {
        return vscode.window.activeTextEditor.document.lineAt(lineNumber);
    }
    static getLineAt(position) {
        return vscode.window.activeTextEditor.document.lineAt(position);
    }
    static getCharAt(position) {
        const line = TextEditor.getLineAt(position);
        return line.text[position.character];
    }
    static getSelection() {
        return vscode.window.activeTextEditor.selection;
    }
    static getText(selection) {
        return vscode.window.activeTextEditor.document.getText(selection);
    }
    /**
     *  Retrieves the current word at position.
     *  If current position is whitespace, selects the right-closest word
     */
    static getWord(position) {
        let start = position;
        let end = position.getRight();
        const char = TextEditor.getText(new vscode.Range(start, end));
        if (this.whitespaceRegExp.test(char)) {
            start = position.getWordRight();
        }
        else {
            start = position.getWordLeft(true);
        }
        end = start.getCurrentWordEnd(true).getRight();
        const word = TextEditor.getText(new vscode.Range(start, end));
        if (this.whitespaceRegExp.test(word)) {
            return undefined;
        }
        return word;
    }
    static getTabCharacter(editor) {
        if (editor.options.insertSpaces) {
            // This will always be a number when we're getting it from the options
            const tabSize = editor.options.tabSize;
            return ' '.repeat(tabSize);
        }
        return '\t';
    }
    static isFirstLine(position) {
        return position.line === 0;
    }
    static isLastLine(position) {
        return position.line === vscode.window.activeTextEditor.document.lineCount - 1;
    }
    static getIndentationLevel(line) {
        let tabSize = configuration_1.configuration.tabstop;
        const lineCheck = line.match(/^\s*/);
        const firstNonWhiteSpace = lineCheck ? lineCheck[0].length : 0;
        let visibleColumn = 0;
        if (firstNonWhiteSpace >= 0) {
            for (const char of line.substring(0, firstNonWhiteSpace)) {
                switch (char) {
                    case '\t':
                        visibleColumn += tabSize;
                        break;
                    case ' ':
                        visibleColumn += 1;
                        break;
                    default:
                        break;
                }
            }
        }
        else {
            return -1;
        }
        return visibleColumn;
    }
    static setIndentationLevel(line, screenCharacters) {
        let tabSize = configuration_1.configuration.tabstop;
        if (screenCharacters < 0) {
            screenCharacters = 0;
        }
        let indentString = '';
        if (configuration_1.configuration.expandtab) {
            indentString += new Array(screenCharacters + 1).join(' ');
        }
        else {
            if (screenCharacters / tabSize > 0) {
                indentString += new Array(Math.floor(screenCharacters / tabSize) + 1).join('\t');
            }
            indentString += new Array((screenCharacters % tabSize) + 1).join(' ');
        }
        const lineCheck = line.match(/^\s*/);
        const firstNonWhiteSpace = lineCheck ? lineCheck[0].length : 0;
        return indentString + line.substring(firstNonWhiteSpace, line.length);
    }
    static getPositionAt(offset) {
        const pos = vscode.window.activeTextEditor.document.positionAt(offset);
        return position_1.Position.FromVSCodePosition(pos);
    }
    static getOffsetAt(position) {
        return vscode.window.activeTextEditor.document.offsetAt(position);
    }
    static getDocumentBegin() {
        return new position_1.Position(0, 0);
    }
    static getDocumentEnd(textEditor) {
        const lineCount = TextEditor.getLineCount(textEditor);
        const line = lineCount > 0 ? lineCount - 1 : 0;
        const char = TextEditor.getLineLength(line);
        return new position_1.Position(line, char);
    }
    /**
     * @returns the Position of the first character on the given line which is not whitespace.
     */
    static getFirstNonWhitespaceCharOnLine(line) {
        return new position_1.Position(line, TextEditor.readLineAt(line).match(/^\s*/)[0].length);
    }
    /**
     * Iterate over every line in the block defined by the two positions (Range) passed in.
     * If no range is given, the primary cursor will be used as the block.
     *
     * This is intended for visual block mode.
     */
    static *iterateLinesInBlock(vimState, range, options = { reverse: false }) {
        const { reverse } = options;
        if (range === undefined) {
            range = vimState.cursors[0];
        }
        const topLeft = mode_1.visualBlockGetTopLeftPosition(range.start, range.stop);
        const bottomRight = mode_1.visualBlockGetBottomRightPosition(range.start, range.stop);
        const [itrStart, itrEnd] = reverse
            ? [bottomRight.line, topLeft.line]
            : [topLeft.line, bottomRight.line];
        const runToLineEnd = vimState.desiredColumn === Number.POSITIVE_INFINITY;
        for (let lineIndex = itrStart; reverse ? lineIndex >= itrEnd : lineIndex <= itrEnd; reverse ? lineIndex-- : lineIndex++) {
            const line = TextEditor.getLine(lineIndex).text;
            const endCharacter = runToLineEnd
                ? line.length + 1
                : Math.min(line.length, bottomRight.character + 1);
            yield {
                line: line.substring(topLeft.character, endCharacter),
                start: new position_1.Position(lineIndex, topLeft.character),
                end: new position_1.Position(lineIndex, endCharacter),
            };
        }
    }
    /**
     * Iterates through words on the same line, starting from the current position.
     */
    static *iterateWords(start) {
        const text = TextEditor.getLineAt(start).text;
        let wordEnd = start.getCurrentWordEnd(true);
        do {
            const word = text.substring(start.character, wordEnd.character + 1);
            yield {
                start: start,
                end: wordEnd,
                word: word,
            };
            if (wordEnd.getRight().isLineEnd()) {
                return;
            }
            start = start.getWordRight();
            wordEnd = start.getCurrentWordEnd(true);
        } while (true);
    }
}
exports.TextEditor = TextEditor;
TextEditor.whitespaceRegExp = new RegExp('^ *$');

//# sourceMappingURL=textEditor.js.map
