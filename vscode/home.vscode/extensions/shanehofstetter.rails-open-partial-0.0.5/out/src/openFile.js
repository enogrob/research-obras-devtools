'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const { window } = vscode;
const { workspace } = vscode;
const { rootPath } = workspace;
function openFile(fileName) {
    return workspace.openTextDocument(fileName)
        .then(textDocument => window.showTextDocument(textDocument));
}
exports.default = openFile;
//# sourceMappingURL=openFile.js.map