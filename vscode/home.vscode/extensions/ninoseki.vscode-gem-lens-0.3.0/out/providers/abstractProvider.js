"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const extractDependency_1 = require("../extractDependency");
const gem_1 = require("../gem");
const common_1 = require("../common");
class AbstractProvider {
    provideHover(document, position, token) {
        return __awaiter(this, void 0, void 0, function* () {
            const range = document.getWordRangeAtPosition(position, this.gemRegexp());
            const line = document.lineAt(position.line).text.trim();
            const dependency = extractDependency_1.extractDependency(line);
            if (!dependency) {
                return;
            }
            const gem = new gem_1.Gem(dependency.name, dependency.requirements);
            if (!common_1.cache.has(gem.name)) {
                const details = yield gem.details();
                if (details !== undefined) {
                    common_1.cache.set(gem.name, details);
                }
            }
            const details = common_1.cache.get(gem.name);
            if (details === undefined) {
                return;
            }
            const message = this.buildMessage(details);
            const link = new vscode.Hover(message, range);
            return link;
        });
    }
    buildMessage(info) {
        return `${info.info}\n\nLatest version: ${info.version}\n\n${info.homepage_uri}`;
    }
    gemRegexp() {
        return /foo bar/;
    }
}
exports.AbstractProvider = AbstractProvider;
//# sourceMappingURL=abstractProvider.js.map