"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate({ subscriptions }) {
    const foldStatusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    foldStatusBarItem.command = "editor.foldAll";
    foldStatusBarItem.tooltip = "fold all";
    foldStatusBarItem.text = `{$(chevron-right)$(chevron-left)}`;
    subscriptions.push(foldStatusBarItem);
    foldStatusBarItem.show();
    const unfoldStatusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    unfoldStatusBarItem.command = "editor.unfoldAll";
    unfoldStatusBarItem.tooltip = "unfold all";
    unfoldStatusBarItem.text = `{$(chevron-left)$(chevron-right)}`;
    subscriptions.push(unfoldStatusBarItem);
    unfoldStatusBarItem.show();
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map