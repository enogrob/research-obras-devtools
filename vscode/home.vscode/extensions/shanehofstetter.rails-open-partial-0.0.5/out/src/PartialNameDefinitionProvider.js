"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const openFile_1 = require("./openFile");
const vscode_1 = require("vscode");
class PartialNameDefinitionProvider {
    provideDefinition(document, position, token) {
        return __awaiter(this, void 0, void 0, function* () {
            const partialName = this.getPartiaName(document, position);
            yield openFile_1.default(this.resolvePartialFilePath(partialName, document.fileName));
            return undefined;
        });
    }
    getPartiaName(document, position) {
        return this.getPartialNameFromLine(document.lineAt(position.line).text);
    }
    getPartialNameFromLine(line_text) {
        if (!(/partial/.test(line_text))) {
            return "";
        }
        var line_text = line_text.split(" ").filter(function (i) { return i != ""; }).join(" ");
        var after_partial = line_text.split(/partial\(|partial\ |partial\: /)[1];
        var first_argument = after_partial.split(/\ |\,/)[0];
        var partial_name = first_argument.replace(/\"|\'|\)|\:/g, "");
        return this.underscorePartialName(partial_name);
    }
    underscorePartialName(partial_name) {
        return partial_name.split("/").map(function (item, index, array) {
            return index == array.length - 1 ? "_" + item : item;
        }).join("/");
    }
    resolvePartialFilePath(partialName, currentFileName) {
        const currentFileEnding = currentFileName.substring(currentFileName.indexOf("."));
        if (partialName.includes("/")) {
            return `${vscode_1.workspace.rootPath}/app/views/${partialName}${currentFileEnding}`;
        }
        const currentDirectory = currentFileName.substring(0, currentFileName.lastIndexOf("/") + 1);
        return `${currentDirectory}/${partialName}${currentFileEnding}`;
    }
}
exports.default = PartialNameDefinitionProvider;
//# sourceMappingURL=PartialNameDefinitionProvider.js.map