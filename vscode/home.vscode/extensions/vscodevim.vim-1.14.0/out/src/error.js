"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var ErrorCode;
(function (ErrorCode) {
    ErrorCode[ErrorCode["MarkNotSet"] = 20] = "MarkNotSet";
    ErrorCode[ErrorCode["NoFileName"] = 32] = "NoFileName";
    ErrorCode[ErrorCode["NoPreviousRegularExpression"] = 35] = "NoPreviousRegularExpression";
    ErrorCode[ErrorCode["NoWriteSinceLastChange"] = 37] = "NoWriteSinceLastChange";
    ErrorCode[ErrorCode["ErrorWritingToFile"] = 208] = "ErrorWritingToFile";
    ErrorCode[ErrorCode["NoStringUnderCursor"] = 348] = "NoStringUnderCursor";
    ErrorCode[ErrorCode["SearchHitTop"] = 384] = "SearchHitTop";
    ErrorCode[ErrorCode["SearchHitBottom"] = 385] = "SearchHitBottom";
    ErrorCode[ErrorCode["CannotCloseLastWindow"] = 444] = "CannotCloseLastWindow";
    ErrorCode[ErrorCode["InvalidArgument"] = 474] = "InvalidArgument";
    ErrorCode[ErrorCode["PatternNotFound"] = 486] = "PatternNotFound";
    ErrorCode[ErrorCode["TrailingCharacters"] = 488] = "TrailingCharacters";
    ErrorCode[ErrorCode["NotAnEditorCommand"] = 492] = "NotAnEditorCommand";
    ErrorCode[ErrorCode["UnknownOption"] = 518] = "UnknownOption";
})(ErrorCode = exports.ErrorCode || (exports.ErrorCode = {}));
exports.ErrorMessage = {
    20: 'Mark not set',
    32: 'No file name',
    35: 'No previous regular expression',
    37: 'No write since last change (add ! to override)',
    208: 'Error writing to file',
    348: 'No string under cursor',
    384: 'Search hit TOP without match',
    385: 'Search hit BOTTOM without match',
    444: 'Cannot close last window',
    474: 'Invalid argument',
    486: 'Pattern not found',
    488: 'Trailing characters',
    492: 'Not an editor command',
    518: 'Unknown option',
};
class VimError extends Error {
    constructor(code, message) {
        super();
        this._code = code;
        this._message = message;
    }
    static fromCode(code, extraValue) {
        if (exports.ErrorMessage[code]) {
            return new VimError(code, exports.ErrorMessage[code] + (extraValue ? `: ${extraValue}` : ''));
        }
        throw new Error('unknown error code: ' + code);
    }
    get code() {
        return this._code;
    }
    get message() {
        return this._message;
    }
    toString() {
        return `E${this.code}: ${this.message}`;
    }
}
exports.VimError = VimError;

//# sourceMappingURL=error.js.map
