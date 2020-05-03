"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const _ = require("lodash");
const configuration_1 = require("./../../configuration/configuration");
const textEditor_1 = require("./../../textEditor");
const util_1 = require("../../util/util");
/**
 * Controls how a PositionDiff affects the Position it's applied to.
 */
var PositionDiffType;
(function (PositionDiffType) {
    /** Simple line and column offset */
    PositionDiffType[PositionDiffType["Offset"] = 0] = "Offset";
    /**
     * Sets the Position's column to `PositionDiff.character`
     */
    PositionDiffType[PositionDiffType["ExactCharacter"] = 1] = "ExactCharacter";
    /** Brings the Position to the beginning of the line if `vim.startofline` is true */
    PositionDiffType[PositionDiffType["ObeyStartOfLine"] = 2] = "ObeyStartOfLine";
})(PositionDiffType = exports.PositionDiffType || (exports.PositionDiffType = {}));
/**
 * Represents a difference between two Positions.
 * Add it to a Position to get another Position.
 */
class PositionDiff {
    constructor({ line = 0, character = 0, type = PositionDiffType.Offset } = {}) {
        this.line = line;
        this.character = character;
        this.type = type;
    }
    static newBOLDiff(lineOffset = 0) {
        return new PositionDiff({
            line: lineOffset,
            character: 0,
            type: PositionDiffType.ExactCharacter,
        });
    }
    toString() {
        switch (this.type) {
            case PositionDiffType.Offset:
                return `[ Diff: Offset ${this.line} ${this.character} ]`;
            case PositionDiffType.ExactCharacter:
                return `[ Diff: ExactCharacter ${this.line} ${this.character} ]`;
            case PositionDiffType.ObeyStartOfLine:
                return `[ Diff: ObeyStartOfLine ${this.line} ]`;
            default:
                throw new Error(`Unknown PositionDiffType: ${this.type}`);
        }
    }
}
exports.PositionDiff = PositionDiff;
class Position extends vscode.Position {
    constructor(line, character) {
        super(line, character);
    }
    toString() {
        return `[${this.line}, ${this.character}]`;
    }
    static FromVSCodePosition(pos) {
        return new Position(pos.line, pos.character);
    }
    /**
     * @returns the Position of the 2 provided which comes earlier in the document.
     */
    static earlierOf(p1, p2) {
        return p1.isBefore(p2) ? p1 : p2;
    }
    /**
     * @returns the Position of the 2 provided which comes later in the document.
     */
    static laterOf(p1, p2) {
        return p1.isBefore(p2) ? p2 : p1;
    }
    /**
     * @returns the given Positions in the order they appear in the document.
     */
    static sorted(p1, p2) {
        return p1.isBefore(p2) ? [p1, p2] : [p2, p1];
    }
    /**
     * Subtracts another position from this one, returning the difference between the two.
     */
    subtract(other) {
        return new PositionDiff({
            line: this.line - other.line,
            character: this.character - other.character,
        });
    }
    /**
     * Adds a PositionDiff to this position, returning a new position.
     */
    add(diff, { boundsCheck = true } = {}) {
        let resultLine = this.line + diff.line;
        let resultChar;
        if (diff.type === PositionDiffType.Offset) {
            resultChar = this.character + diff.character;
        }
        else if (diff.type === PositionDiffType.ExactCharacter) {
            resultChar = diff.character;
        }
        else if (diff.type === PositionDiffType.ObeyStartOfLine) {
            resultChar = this.withLine(resultLine).obeyStartOfLine().character;
        }
        else {
            throw new Error(`Unknown PositionDiffType: ${diff.type}`);
        }
        if (boundsCheck) {
            resultLine = util_1.clamp(resultLine, 0, textEditor_1.TextEditor.getLineCount() - 1);
            resultChar = util_1.clamp(resultChar, 0, textEditor_1.TextEditor.getLineLength(resultLine));
        }
        return new Position(resultLine, resultChar);
    }
    /**
     * @returns a new Position with the same character and the given line.
     * Does bounds-checking to make sure the result is valid.
     */
    withLine(line) {
        line = util_1.clamp(line, 0, textEditor_1.TextEditor.getLineCount() - 1);
        return new Position(line, this.character);
    }
    /**
     * @returns a new Position with the same line and the given character.
     * Does bounds-checking to make sure the result is valid.
     */
    withColumn(column) {
        column = util_1.clamp(column, 0, textEditor_1.TextEditor.getLineLength(this.line));
        return new Position(this.line, column);
    }
    getLeftTabStop() {
        if (!this.isLineBeginning()) {
            let indentationWidth = textEditor_1.TextEditor.getIndentationLevel(textEditor_1.TextEditor.getLineAt(this).text);
            let tabSize = vscode.window.activeTextEditor.options.tabSize;
            if (indentationWidth % tabSize > 0) {
                return new Position(this.line, Math.max(0, this.character - (indentationWidth % tabSize)));
            }
            else {
                return new Position(this.line, Math.max(0, this.character - tabSize));
            }
        }
        return this;
    }
    /**
     * @returns the Position `count` characters to the left of this Position. Does not go over line breaks.
     */
    getLeft(count = 1) {
        return new Position(this.line, Math.max(this.character - count, 0));
    }
    /**
     * @returns the Position `count` characters to the right of this Position. Does not go over line breaks.
     */
    getRight(count = 1) {
        return new Position(this.line, Math.min(this.character + count, textEditor_1.TextEditor.getLineLength(this.line)));
    }
    /**
     * @returns the Position `count` lines down from this Position
     */
    getDown(count = 1) {
        const line = Math.min(this.line + count, textEditor_1.TextEditor.getLineCount() - 1);
        return new Position(line, Math.min(this.character, textEditor_1.TextEditor.getLineLength(line)));
    }
    /**
     * @returns the Position `count` lines up from this Position
     */
    getUp(count = 1) {
        const line = Math.max(this.line - count, 0);
        return new Position(line, Math.min(this.character, textEditor_1.TextEditor.getLineLength(line)));
    }
    /**
     * Same as getLeft, but goes up to the previous line on line breaks.
     * Equivalent to left arrow (in a non-vim editor!)
     */
    getLeftThroughLineBreaks(includeEol = true) {
        if (!this.isLineBeginning()) {
            return this.getLeft();
        }
        // First char on first line, can not go left any more
        if (this.line === 0) {
            return this;
        }
        if (includeEol) {
            return this.getUpWithDesiredColumn(0).getLineEnd();
        }
        else {
            return this.getUpWithDesiredColumn(0).getLineEnd().getLeft();
        }
    }
    getRightThroughLineBreaks(includeEol = false) {
        if (this.isAtDocumentEnd()) {
            // TODO(bell)
            return this;
        }
        if (this.isLineEnd()) {
            return this.getDownWithDesiredColumn(0);
        }
        if (!includeEol && this.getRight().isLineEnd()) {
            return this.getDownWithDesiredColumn(0);
        }
        return this.getRight();
    }
    getOffsetThroughLineBreaks(offset) {
        let pos = new Position(this.line, this.character);
        if (offset < 0) {
            for (let i = 0; i < -offset; i++) {
                pos = pos.getLeftThroughLineBreaks();
            }
        }
        else {
            for (let i = 0; i < offset; i++) {
                pos = pos.getRightThroughLineBreaks();
            }
        }
        return pos;
    }
    /**
     * Get the position of the line directly below the current line.
     */
    getDownWithDesiredColumn(desiredColumn) {
        if (textEditor_1.TextEditor.getDocumentEnd().line !== this.line) {
            let nextLine = this.line + 1;
            let nextLineLength = textEditor_1.TextEditor.getLineLength(nextLine);
            return new Position(nextLine, Math.min(nextLineLength, desiredColumn));
        }
        return this;
    }
    /**
     * Get the position of the line directly above the current line.
     */
    getUpWithDesiredColumn(desiredColumn) {
        if (textEditor_1.TextEditor.getDocumentBegin().line !== this.line) {
            let prevLine = this.line - 1;
            let prevLineLength = textEditor_1.TextEditor.getLineLength(prevLine);
            return new Position(prevLine, Math.min(prevLineLength, desiredColumn));
        }
        return this;
    }
    /**
     * Get the position of the word counting from the position specified.
     * @param text The string to search from.
     * @param pos The position of text to search from.
     * @param inclusive true if we consider the pos a valid result, false otherwise.
     * @returns The character position of the word to the left relative to the text and the pos.
     *          undefined if there is no word to the left of the postion.
     */
    static getWordLeft(text, pos, inclusive = false) {
        return Position.getWordLeftWithRegex(text, pos, Position._nonWordCharRegex, inclusive);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getWordLeft(inclusive = false) {
        return this.getWordLeftWithRegex(Position._nonWordCharRegex, inclusive);
    }
    getBigWordLeft(inclusive = false) {
        return this.getWordLeftWithRegex(Position._nonBigWordCharRegex, inclusive);
    }
    getCamelCaseWordLeft(inclusive = false) {
        return this.getWordLeftWithRegex(Position._nonCamelCaseWordCharRegex, inclusive);
    }
    getFilePathLeft(inclusive = false) {
        return this.getWordLeftWithRegex(Position._nonFileNameRegex, inclusive);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getWordRight(inclusive = false) {
        return this.getWordRightWithRegex(Position._nonWordCharRegex, inclusive);
    }
    getBigWordRight() {
        return this.getWordRightWithRegex(Position._nonBigWordCharRegex);
    }
    getCamelCaseWordRight() {
        return this.getWordRightWithRegex(Position._nonCamelCaseWordCharRegex);
    }
    getFilePathRight(inclusive = false) {
        return this.getWordRightWithRegex(Position._nonFileNameRegex, inclusive);
    }
    getLastWordEnd() {
        return this.getLastWordEndWithRegex(Position._nonWordCharRegex);
    }
    getLastBigWordEnd() {
        return this.getLastWordEndWithRegex(Position._nonBigWordCharRegex);
    }
    getLastCamelCaseWordEnd() {
        return this.getLastWordEndWithRegex(Position._nonCamelCaseWordCharRegex);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getCurrentWordEnd(inclusive = false) {
        return this.getCurrentWordEndWithRegex(Position._nonWordCharRegex, inclusive);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getCurrentBigWordEnd(inclusive = false) {
        return this.getCurrentWordEndWithRegex(Position._nonBigWordCharRegex, inclusive);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getCurrentCamelCaseWordEnd(inclusive = false) {
        return this.getCurrentWordEndWithRegex(Position._nonCamelCaseWordCharRegex, inclusive);
    }
    isLineBlank(trimWhite = false) {
        let text = textEditor_1.TextEditor.getLineAt(this).text;
        return (trimWhite ? text.trim() : text) === '';
    }
    /**
     * Get the end of the current paragraph.
     */
    getCurrentParagraphEnd(trimWhite = false) {
        let pos = this;
        // If we're not in a paragraph yet, go down until we are.
        while (pos.isLineBlank(trimWhite) && !textEditor_1.TextEditor.isLastLine(pos)) {
            pos = pos.getDownWithDesiredColumn(0);
        }
        // Go until we're outside of the paragraph, or at the end of the document.
        while (!pos.isLineBlank(trimWhite) && pos.line < textEditor_1.TextEditor.getLineCount() - 1) {
            pos = pos.getDownWithDesiredColumn(0);
        }
        return pos.getLineEnd();
    }
    /**
     * Get the beginning of the current paragraph.
     */
    getCurrentParagraphBeginning(trimWhite = false) {
        let pos = this;
        // If we're not in a paragraph yet, go up until we are.
        while (pos.isLineBlank(trimWhite) && !textEditor_1.TextEditor.isFirstLine(pos)) {
            pos = pos.getUpWithDesiredColumn(0);
        }
        // Go until we're outside of the paragraph, or at the beginning of the document.
        while (pos.line > 0 && !pos.isLineBlank(trimWhite)) {
            pos = pos.getUpWithDesiredColumn(0);
        }
        return pos.getLineBegin();
    }
    getSentenceBegin(args) {
        if (args.forward) {
            return this.getNextSentenceBeginWithRegex(Position._sentenceEndRegex, false);
        }
        else {
            return this.getPreviousSentenceBeginWithRegex(Position._sentenceEndRegex);
        }
    }
    getCurrentSentenceEnd() {
        return this.getCurrentSentenceEndWithRegex(Position._sentenceEndRegex, false);
    }
    /**
     * @returns a new Position at the beginning of the current line.
     */
    getLineBegin() {
        return new Position(this.line, 0);
    }
    /**
     * @returns the beginning of the line, excluding preceeding whitespace.
     * This respects the `autoindent` setting, and returns `getLineBegin()` if auto-indent is disabled.
     */
    getLineBeginRespectingIndent() {
        if (!configuration_1.configuration.autoindent) {
            return this.getLineBegin();
        }
        return textEditor_1.TextEditor.getFirstNonWhitespaceCharOnLine(this.line);
    }
    /**
     * @return the beginning of the previous line.
     * If already on the first line, return the beginning of this line.
     */
    getPreviousLineBegin() {
        if (this.line === 0) {
            return this.getLineBegin();
        }
        return new Position(this.line - 1, 0);
    }
    /**
     * @return the beginning of the next line.
     * If already on the last line, return the *end* of this line.
     */
    getNextLineBegin() {
        if (this.line >= textEditor_1.TextEditor.getLineCount() - 1) {
            return this.getLineEnd();
        }
        return new Position(this.line + 1, 0);
    }
    /**
     * @returns a new Position at the end of this position's line.
     */
    getLineEnd() {
        return new Position(this.line, textEditor_1.TextEditor.getLineLength(this.line));
    }
    /**
     * @returns a new Position at the end of this Position's line, including the invisible newline character.
     */
    getLineEndIncludingEOL() {
        // TODO: isn't this one too far?
        return new Position(this.line, textEditor_1.TextEditor.getLineLength(this.line) + 1);
    }
    /**
     * @returns a new Position one to the left if this Position is on the EOL. Otherwise, returns this position.
     */
    getLeftIfEOL() {
        return this.character === textEditor_1.TextEditor.getLineLength(this.line) ? this.getLeft() : this;
    }
    /**
     * @returns the position that the cursor would be at if you pasted *text* at the current position.
     */
    advancePositionByText(text) {
        const numberOfLinesSpanned = (text.match(/\n/g) || []).length;
        return new Position(this.line + numberOfLinesSpanned, numberOfLinesSpanned === 0
            ? this.character + text.length
            : text.length - (text.lastIndexOf('\n') + 1));
    }
    /**
     * Is this position at the beginning of the line?
     */
    isLineBeginning() {
        return this.character === 0;
    }
    /**
     * Is this position at the end of the line?
     */
    isLineEnd() {
        return this.character >= textEditor_1.TextEditor.getLineLength(this.line);
    }
    isFirstWordOfLine() {
        return textEditor_1.TextEditor.getFirstNonWhitespaceCharOnLine(this.line).character === this.character;
    }
    isAtDocumentBegin() {
        return this.line === 0 && this.isLineBeginning();
    }
    isAtDocumentEnd() {
        return this.line === textEditor_1.TextEditor.getLineCount() - 1 && this.isLineEnd();
    }
    /**
     * Returns whether the current position is in the leading whitespace of a line
     * @param allowEmpty : Use true if "" is valid
     */
    isInLeadingWhitespace(allowEmpty = false) {
        if (allowEmpty) {
            return /^\s*$/.test(textEditor_1.TextEditor.getText(new vscode.Range(this.getLineBegin(), this)));
        }
        else {
            return /^\s+$/.test(textEditor_1.TextEditor.getText(new vscode.Range(this.getLineBegin(), this)));
        }
    }
    /**
     * If `vim.startofline` is set, get first non-blank character's position.
     */
    obeyStartOfLine() {
        return configuration_1.configuration.startofline ? textEditor_1.TextEditor.getFirstNonWhitespaceCharOnLine(this.line) : this;
    }
    isValid(textEditor) {
        try {
            // line
            // TODO: this `|| 1` seems dubious...
            let lineCount = textEditor_1.TextEditor.getLineCount(textEditor) || 1;
            if (this.line >= lineCount) {
                return false;
            }
            // char
            let charCount = textEditor_1.TextEditor.getLineLength(this.line);
            if (this.character > charCount + 1) {
                return false;
            }
        }
        catch (e) {
            return false;
        }
        return true;
    }
    static makeWordRegex(characterSet) {
        let escaped = characterSet && _.escapeRegExp(characterSet).replace(/-/g, '\\-');
        let segments = [];
        segments.push(`([^\\s${escaped}]+)`);
        segments.push(`[${escaped}]+`);
        segments.push(`$^`);
        return new RegExp(segments.join('|'), 'g');
    }
    static makeCamelCaseWordRegex(characterSet) {
        const escaped = characterSet && _.escapeRegExp(characterSet).replace(/-/g, '\\-');
        const segments = [];
        // old versions of VSCode before 1.31 will crash when trying to parse a regex with a lookbehind
        let supportsLookbehind = true;
        try {
            // tslint:disable-next-line
            new RegExp('(<=x)');
        }
        catch {
            supportsLookbehind = false;
        }
        // prettier-ignore
        const firstSegment = '(' + // OPEN: group for matching camel case words
            `[^\\s${escaped}]` + //   words can start with any word character
            '(?:' + //   OPEN: group for characters after initial char
            `(?:${supportsLookbehind ? '(?<=[A-Z_])' : ''}` + //     If first char was a capital
            `[A-Z](?=[\\sA-Z0-9${escaped}_]))+` + //       the word can continue with all caps
            '|' + //     OR
            `(?:${supportsLookbehind ? '(?<=[0-9_])' : ''}` + //     If first char was a digit
            `[0-9](?=[\\sA-Z0-9${escaped}_]))+` + //       the word can continue with all digits
            '|' + //     OR
            `(?:${supportsLookbehind ? '(?<=[_])' : ''}` + //     If first char was an underscore
            `[_](?=[\\s${escaped}_]))+` + //       the word can continue with all underscores
            '|' + //     OR
            `[^\\sA-Z0-9${escaped}_]*` + //     Continue with regular characters
            ')' + //   END: group for characters after initial char
            ')' + // END: group for matching camel case words
            '';
        segments.push(firstSegment);
        segments.push(`[${escaped}]+`);
        segments.push(`$^`);
        // it can be difficult to grok the behavior of the above regex
        // feel free to check out https://regex101.com/r/mkVeiH/1 as a live example
        return new RegExp(segments.join('|'), 'g');
    }
    static makeUnicodeWordRegex(keywordChars) {
        // Distinct categories of characters
        let CharKind;
        (function (CharKind) {
            CharKind[CharKind["Punctuation"] = 0] = "Punctuation";
            CharKind[CharKind["Superscript"] = 1] = "Superscript";
            CharKind[CharKind["Subscript"] = 2] = "Subscript";
            CharKind[CharKind["Braille"] = 3] = "Braille";
            CharKind[CharKind["Ideograph"] = 4] = "Ideograph";
            CharKind[CharKind["Hiragana"] = 5] = "Hiragana";
            CharKind[CharKind["Katakana"] = 6] = "Katakana";
            CharKind[CharKind["Hangul"] = 7] = "Hangul";
        })(CharKind || (CharKind = {}));
        // List of printable characters (code point intervals) and their character kinds.
        // Latin alphabets (e.g., ASCII alphabets and numbers,  Latin-1 Supplement, European Latin) are excluded.
        // Imported from utf_class_buf in src/mbyte.c of Vim.
        const symbolTable = [
            [[0x00a1, 0x00bf], CharKind.Punctuation],
            [[0x037e, 0x037e], CharKind.Punctuation],
            [[0x0387, 0x0387], CharKind.Punctuation],
            [[0x055a, 0x055f], CharKind.Punctuation],
            [[0x0589, 0x0589], CharKind.Punctuation],
            [[0x05be, 0x05be], CharKind.Punctuation],
            [[0x05c0, 0x05c0], CharKind.Punctuation],
            [[0x05c3, 0x05c3], CharKind.Punctuation],
            [[0x05f3, 0x05f4], CharKind.Punctuation],
            [[0x060c, 0x060c], CharKind.Punctuation],
            [[0x061b, 0x061b], CharKind.Punctuation],
            [[0x061f, 0x061f], CharKind.Punctuation],
            [[0x066a, 0x066d], CharKind.Punctuation],
            [[0x06d4, 0x06d4], CharKind.Punctuation],
            [[0x0700, 0x070d], CharKind.Punctuation],
            [[0x0964, 0x0965], CharKind.Punctuation],
            [[0x0970, 0x0970], CharKind.Punctuation],
            [[0x0df4, 0x0df4], CharKind.Punctuation],
            [[0x0e4f, 0x0e4f], CharKind.Punctuation],
            [[0x0e5a, 0x0e5b], CharKind.Punctuation],
            [[0x0f04, 0x0f12], CharKind.Punctuation],
            [[0x0f3a, 0x0f3d], CharKind.Punctuation],
            [[0x0f85, 0x0f85], CharKind.Punctuation],
            [[0x104a, 0x104f], CharKind.Punctuation],
            [[0x10fb, 0x10fb], CharKind.Punctuation],
            [[0x1361, 0x1368], CharKind.Punctuation],
            [[0x166d, 0x166e], CharKind.Punctuation],
            [[0x169b, 0x169c], CharKind.Punctuation],
            [[0x16eb, 0x16ed], CharKind.Punctuation],
            [[0x1735, 0x1736], CharKind.Punctuation],
            [[0x17d4, 0x17dc], CharKind.Punctuation],
            [[0x1800, 0x180a], CharKind.Punctuation],
            [[0x200c, 0x2027], CharKind.Punctuation],
            [[0x202a, 0x202e], CharKind.Punctuation],
            [[0x2030, 0x205e], CharKind.Punctuation],
            [[0x2060, 0x27ff], CharKind.Punctuation],
            [[0x2070, 0x207f], CharKind.Superscript],
            [[0x2080, 0x2094], CharKind.Subscript],
            [[0x20a0, 0x27ff], CharKind.Punctuation],
            [[0x2800, 0x28ff], CharKind.Braille],
            [[0x2900, 0x2998], CharKind.Punctuation],
            [[0x29d8, 0x29db], CharKind.Punctuation],
            [[0x29fc, 0x29fd], CharKind.Punctuation],
            [[0x2e00, 0x2e7f], CharKind.Punctuation],
            [[0x3001, 0x3020], CharKind.Punctuation],
            [[0x3030, 0x3030], CharKind.Punctuation],
            [[0x303d, 0x303d], CharKind.Punctuation],
            [[0x3040, 0x309f], CharKind.Hiragana],
            [[0x30a0, 0x30ff], CharKind.Katakana],
            [[0x3300, 0x9fff], CharKind.Ideograph],
            [[0xac00, 0xd7a3], CharKind.Hangul],
            [[0xf900, 0xfaff], CharKind.Ideograph],
            [[0xfd3e, 0xfd3f], CharKind.Punctuation],
            [[0xfe30, 0xfe6b], CharKind.Punctuation],
            [[0xff00, 0xff0f], CharKind.Punctuation],
            [[0xff1a, 0xff20], CharKind.Punctuation],
            [[0xff3b, 0xff40], CharKind.Punctuation],
            [[0xff5b, 0xff65], CharKind.Punctuation],
            [[0x20000, 0x2a6df], CharKind.Ideograph],
            [[0x2a700, 0x2b73f], CharKind.Ideograph],
            [[0x2b740, 0x2b81f], CharKind.Ideograph],
            [[0x2f800, 0x2fa1f], CharKind.Ideograph],
        ];
        const codePointRangePatterns = [];
        for (let kind in CharKind) {
            if (!isNaN(Number(kind))) {
                codePointRangePatterns[kind] = [];
            }
        }
        for (let [[first, last], kind] of symbolTable) {
            if (first === last) {
                // '\u{hhhh}'
                codePointRangePatterns[kind].push(`\\u{${first.toString(16)}}`);
            }
            else {
                // '\u{hhhh}-\u{hhhh}'
                codePointRangePatterns[kind].push(`\\u{${first.toString(16)}}-\\u{${last.toString(16)}}`);
            }
        }
        // Symbols in vim.iskeyword or editor.wordSeparators
        // are treated as CharKind.Punctuation
        const escapedKeywordChars = _.escapeRegExp(keywordChars).replace(/-/g, '\\-');
        codePointRangePatterns[Number(CharKind.Punctuation)].push(escapedKeywordChars);
        const codePointRanges = codePointRangePatterns.map((patterns) => patterns.join(''));
        const symbolSegments = codePointRanges.map((range) => `([${range}]+)`);
        // wordSegment matches word characters.
        // A word character is a symbol which is neither
        // - space
        // - a symbol listed in the table
        // - a keyword (vim.iskeyword)
        const wordSegment = `([^\\s${codePointRanges.join('')}]+)`;
        // https://regex101.com/r/X1agK6/2
        const segments = symbolSegments.concat(wordSegment, '$^');
        return new RegExp(segments.join('|'), 'ug');
    }
    static getAllPositions(line, regex) {
        let positions = [];
        let result = regex.exec(line);
        while (result) {
            positions.push(result.index);
            // Handles the case where an empty string match causes lastIndex not to advance,
            // which gets us in an infinite loop.
            if (result.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            result = regex.exec(line);
        }
        return positions;
    }
    getAllEndPositions(line, regex) {
        let positions = [];
        let result = regex.exec(line);
        while (result) {
            if (result[0].length) {
                positions.push(result.index + result[0].length - 1);
            }
            // Handles the case where an empty string match causes lastIndex not to advance,
            // which gets us in an infinite loop.
            if (result.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            result = regex.exec(line);
        }
        return positions;
    }
    static getWordLeftWithRegex(text, pos, regex, forceFirst = false, inclusive = false) {
        return Position.getAllPositions(text, regex)
            .reverse()
            .find((index) => (index < pos && !inclusive) || (index <= pos && inclusive) || forceFirst);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getWordLeftWithRegex(regex, inclusive = false) {
        for (let currentLine = this.line; currentLine >= 0; currentLine--) {
            const newCharacter = Position.getWordLeftWithRegex(textEditor_1.TextEditor.getLine(currentLine).text, this.character, regex, currentLine !== this.line, inclusive);
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter);
            }
        }
        return new Position(0, 0);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getWordRightWithRegex(regex, inclusive = false) {
        for (let currentLine = this.line; currentLine < textEditor_1.TextEditor.getLineCount(); currentLine++) {
            let positions = Position.getAllPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            let newCharacter = positions.find((index) => (index > this.character && !inclusive) ||
                (index >= this.character && inclusive) ||
                currentLine !== this.line);
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter);
            }
        }
        return new Position(textEditor_1.TextEditor.getLineCount() - 1, 0).getLineEnd();
    }
    getLastWordEndWithRegex(regex) {
        for (let currentLine = this.line; currentLine > -1; currentLine--) {
            let positions = this.getAllEndPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            // if one line is empty, use the 0 position as the default value
            if (positions.length === 0) {
                positions.push(0);
            }
            // reverse the list to find the biggest element smaller than this.character
            positions = positions.reverse();
            let index = positions.findIndex((i) => i < this.character || currentLine !== this.line);
            let newCharacter = 0;
            if (index === -1) {
                if (currentLine > -1) {
                    continue;
                }
                newCharacter = positions[positions.length - 1];
            }
            else {
                newCharacter = positions[index];
            }
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter);
            }
        }
        return new Position(0, 0);
    }
    /**
     * Inclusive is true if we consider the current position a valid result, false otherwise.
     */
    getCurrentWordEndWithRegex(regex, inclusive) {
        for (let currentLine = this.line; currentLine < textEditor_1.TextEditor.getLineCount(); currentLine++) {
            let positions = this.getAllEndPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            let newCharacter = positions.find((index) => (index > this.character && !inclusive) ||
                (index >= this.character && inclusive) ||
                currentLine !== this.line);
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter);
            }
        }
        return new Position(textEditor_1.TextEditor.getLineCount() - 1, 0).getLineEnd();
    }
    getPreviousSentenceBeginWithRegex(regex) {
        let paragraphBegin = this.getCurrentParagraphBeginning();
        for (let currentLine = this.line; currentLine >= paragraphBegin.line; currentLine--) {
            let endPositions = this.getAllEndPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            let newCharacter = endPositions.reverse().find((index) => {
                const newPositionBeforeThis = new Position(currentLine, index)
                    .getRightThroughLineBreaks()
                    .compareTo(this);
                return newPositionBeforeThis && (index < this.character || currentLine < this.line);
            });
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter).getRightThroughLineBreaks();
            }
        }
        if (paragraphBegin.line + 1 === this.line || paragraphBegin.line === this.line) {
            return paragraphBegin;
        }
        else {
            return new Position(paragraphBegin.line + 1, 0);
        }
    }
    getNextSentenceBeginWithRegex(regex, inclusive) {
        // A paragraph and section boundary is also a sentence boundary.
        let paragraphEnd = this.getCurrentParagraphEnd();
        for (let currentLine = this.line; currentLine <= paragraphEnd.line; currentLine++) {
            let endPositions = this.getAllEndPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            let newCharacter = endPositions.find((index) => (index > this.character && !inclusive) ||
                (index >= this.character && inclusive) ||
                currentLine !== this.line);
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter).getRightThroughLineBreaks();
            }
        }
        return this.getFirstNonWhitespaceInParagraph(paragraphEnd, inclusive);
    }
    getCurrentSentenceEndWithRegex(regex, inclusive) {
        let paragraphEnd = this.getCurrentParagraphEnd();
        for (let currentLine = this.line; currentLine <= paragraphEnd.line; currentLine++) {
            let allPositions = Position.getAllPositions(textEditor_1.TextEditor.getLine(currentLine).text, regex);
            let newCharacter = allPositions.find((index) => (index > this.character && !inclusive) ||
                (index >= this.character && inclusive) ||
                currentLine !== this.line);
            if (newCharacter !== undefined) {
                return new Position(currentLine, newCharacter);
            }
        }
        return this.getFirstNonWhitespaceInParagraph(paragraphEnd, inclusive);
    }
    getFirstNonWhitespaceInParagraph(paragraphEnd, inclusive) {
        // If the cursor is at an empty line, it's the end of a paragraph and the begin of another paragraph
        // Find the first non-whitespace character.
        if (textEditor_1.TextEditor.getLine(this.line).text) {
            return paragraphEnd;
        }
        else {
            for (let currentLine = this.line; currentLine <= paragraphEnd.line; currentLine++) {
                const nonWhitePositions = Position.getAllPositions(textEditor_1.TextEditor.getLine(currentLine).text, /\S/g);
                const newCharacter = nonWhitePositions.find((index) => (index > this.character && !inclusive) ||
                    (index >= this.character && inclusive) ||
                    currentLine !== this.line);
                if (newCharacter !== undefined) {
                    return new Position(currentLine, newCharacter);
                }
            }
        }
        // Only happens at end of document
        return this;
    }
}
exports.Position = Position;
Position.NonWordCharacters = configuration_1.configuration.iskeyword;
Position.NonBigWordCharacters = '';
Position.NonFileCharacters = '"\'`;<>{}[]()';
Position._nonWordCharRegex = Position.makeUnicodeWordRegex(Position.NonWordCharacters);
Position._nonBigWordCharRegex = Position.makeWordRegex(Position.NonBigWordCharacters);
Position._nonCamelCaseWordCharRegex = Position.makeCamelCaseWordRegex(Position.NonWordCharacters);
Position._sentenceEndRegex = /[\.!\?]{1}([ \n\t]+|$)/g;
Position._nonFileNameRegex = Position.makeWordRegex(Position.NonFileCharacters);

//# sourceMappingURL=position.js.map
