"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const gemspecProvider_1 = require("./providers/gemspecProvider");
const gemfileProvider_1 = require("./providers/gemfileProvider");
function activate(context) {
    const gemspecFile = {
        language: "ruby",
        pattern: "**/*.gemspec",
        scheme: "file",
    };
    context.subscriptions.push(vscode.languages.registerHoverProvider(gemspecFile, new gemspecProvider_1.GemspecProvider()));
    const gemfileFile = {
        pattern: "**/Gemfile",
        scheme: "file",
    };
    context.subscriptions.push(vscode.languages.registerHoverProvider(gemfileFile, new gemfileProvider_1.GemfileProvider()));
}
exports.activate = activate;
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map