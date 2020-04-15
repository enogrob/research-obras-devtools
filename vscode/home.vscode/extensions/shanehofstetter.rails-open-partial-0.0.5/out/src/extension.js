'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const PartialNameDefinitionProvider_1 = require("./PartialNameDefinitionProvider");
function activate(context) {
    console.log('activated extension "rails-open-partial"');
    const HAML = { language: 'haml', scheme: 'file' };
    const ERB = { language: 'erb', scheme: 'file' };
    context.subscriptions.push(vscode.languages.registerDefinitionProvider(HAML, new PartialNameDefinitionProvider_1.default));
    context.subscriptions.push(vscode.languages.registerDefinitionProvider(ERB, new PartialNameDefinitionProvider_1.default));
}
exports.activate = activate;
function deactivate() {
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map