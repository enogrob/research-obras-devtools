"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
/**
 * Wrapper around VS Code's `setContext`.
 * The API call takes several milliseconds to seconds to complete,
 * so let's cache the values and only call the API when necessary.
 */
class VsCodeContextImpl {
    constructor() {
        this.contextMap = {};
    }
    async Set(key, value) {
        const prev = this.Get(key);
        if (!prev || prev !== value) {
            this.contextMap[key] = value;
            return vscode.commands.executeCommand('setContext', key, value);
        }
    }
    Get(key) {
        return this.contextMap[key];
    }
}
exports.VsCodeContext = new VsCodeContextImpl();

//# sourceMappingURL=vscode-context.js.map
