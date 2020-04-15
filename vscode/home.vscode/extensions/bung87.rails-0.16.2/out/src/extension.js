"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
const rails_helper_1 = require("./rails_helper");
const rails_definition_1 = require("./rails_definition");
const rails_completion_1 = require("./rails_completion");
const viewRef_1 = require("./viewRef");
const lineByLine = require("n-readlines");
const view_doc_1 = require("./view_doc");
const formatter_1 = require("./formatter");
const RAILS_MODE = { language: "ruby", scheme: "file" };
const VIEW_MODE = {
    pattern: "**/views/**",
    scheme: "file"
};
function railsNavigation() {
    if (!vscode.window.activeTextEditor) {
        return;
    }
    var relativeFileName = vscode.workspace.asRelativePath(vscode.window.activeTextEditor.document.fileName);
    var line = vscode.window.activeTextEditor.document
        .lineAt(vscode.window.activeTextEditor.selection.active.line)
        .text.trim();
    var rh = new rails_helper_1.RailsHelper(relativeFileName, line);
    rh.showFileList();
}
function registerFormatter(context) {
    console.log("registerFormatter");
    var docType = ['css.erb', 'scss.erb', 'html.erb'];
    for (var i = 0, l = docType.length; i < l; i++) {
        registerDocType(docType[i]);
    }
    let formatter = new formatter_1.Formatter();
    context.subscriptions.push(vscode.commands.registerCommand('erb.formatting', () => {
        formatter.beautify();
    }));
    context.subscriptions.push(vscode.workspace.onWillSaveTextDocument(e => {
        formatter.onSave(e);
    }));
    function registerDocType(type) {
        context.subscriptions.push(vscode.languages.registerDocumentFormattingEditProvider(type, {
            provideDocumentFormattingEdits: (document, options, token) => {
                return formatter.registerBeautify(null);
            }
        }));
        context.subscriptions.push(vscode.languages.registerDocumentRangeFormattingEditProvider(type, {
            provideDocumentRangeFormattingEdits: (document, range, options, token) => {
                var start = new vscode.Position(0, 0);
                var end = new vscode.Position(document.lineCount - 1, document.lineAt(document.lineCount - 1).text.length);
                return formatter.registerBeautify(new vscode.Range(start, end));
            }
        }));
    }
}
function activate(context) {
    context.subscriptions.push(vscode.commands.registerCommand("Rails:Navigation", railsNavigation));
    context.subscriptions.push(vscode.languages.registerDefinitionProvider(RAILS_MODE, new rails_definition_1.RailsDefinitionProvider()));
    context.subscriptions.push(vscode.languages.registerCompletionItemProvider({ scheme: "file" }, new rails_completion_1.RailsCompletionItemProvider(), ".", '"', ":", "'"));
    // since VIEW_MODE use glob pattern ,must make sure work on a rails project
    function registerViewDefinitionProvider() {
        context.subscriptions.push(vscode.languages.registerDefinitionProvider(VIEW_MODE, new viewRef_1.ViewDefinitionProvider()));
    }
    function registerViewDocCommand() {
        context.subscriptions.push(vscode.commands.registerCommand("Rails:Document", view_doc_1.viewDoc, context));
    }
    vscode.workspace.findFiles("Gemfile").then((uris) => {
        if (uris.length == 1) {
            let fileAbsPath = uris[0].fsPath;
            var liner = new lineByLine(fileAbsPath), line;
            while ((line = liner.next())) {
                let lineText = line.toString("utf8").trim();
                if (/gem\s+['"]rails['"]/.test(lineText)) {
                    registerViewDefinitionProvider();
                    registerViewDocCommand();
                    registerFormatter(context);
                    console.log("Project Gemfile contains rails");
                    break;
                }
            }
        }
    });
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map