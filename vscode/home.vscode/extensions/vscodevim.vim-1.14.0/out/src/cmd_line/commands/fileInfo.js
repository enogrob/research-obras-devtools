"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const node_1 = require("../node");
const statusBarTextUtils_1 = require("../../util/statusBarTextUtils");
class FileInfoCommand extends node_1.CommandBase {
    async execute(vimState) {
        statusBarTextUtils_1.reportFileInfo(vimState.cursors[0].start, vimState);
    }
}
exports.FileInfoCommand = FileInfoCommand;

//# sourceMappingURL=fileInfo.js.map
