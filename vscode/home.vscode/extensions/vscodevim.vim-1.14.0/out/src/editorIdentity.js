"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * We consider two editors to be the same iff their EditorIdentities are the same
 */
class EditorIdentity {
    constructor(fileName) {
        this._fileName = fileName;
    }
    static fromEditor(textEditor) {
        var _a, _b;
        return new EditorIdentity((_b = (_a = textEditor === null || textEditor === void 0 ? void 0 : textEditor.document) === null || _a === void 0 ? void 0 : _a.fileName) !== null && _b !== void 0 ? _b : '');
    }
    get fileName() {
        return this._fileName;
    }
    isEqual(other) {
        return this.fileName === other.fileName;
    }
    toString() {
        return this.fileName;
    }
}
exports.EditorIdentity = EditorIdentity;

//# sourceMappingURL=editorIdentity.js.map
