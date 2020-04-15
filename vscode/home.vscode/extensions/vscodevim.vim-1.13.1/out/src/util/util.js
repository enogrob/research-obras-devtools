"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const position_1 = require("../common/motion/position");
const range_1 = require("../common/motion/range");
const child_process_1 = require("child_process");
/**
 * We used to have an issue where we would do something like execute a VSCode
 * command, and would encounter race conditions because the cursor positions
 * wouldn't yet be updated. So we waited for a selection change event, but
 * this doesn't seem to be necessary any more.
 */
function getCursorsAfterSync() {
    return vscode.window.activeTextEditor.selections.map(x => new range_1.Range(position_1.Position.FromVSCodePosition(x.start), position_1.Position.FromVSCodePosition(x.end)));
}
exports.getCursorsAfterSync = getCursorsAfterSync;
/**
 * This function executes a shell command and returns the standard output as a string.
 */
function executeShell(cmd) {
    return new Promise((resolve, reject) => {
        try {
            child_process_1.exec(cmd, (err, stdout, stderr) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(stdout);
                }
            });
        }
        catch (error) {
            reject(error);
        }
    });
}
exports.executeShell = executeShell;
function clamp(num, min, max) {
    return Math.min(Math.max(num, min), max);
}
exports.clamp = clamp;
function scrollView(vimState, offset) {
    if (offset !== 0) {
        vimState.postponedCodeViewChanges.push({
            command: 'editorScroll',
            args: {
                to: offset > 0 ? 'up' : 'down',
                by: 'line',
                value: Math.abs(offset),
                revealCursor: false,
                select: false,
            },
        });
    }
}
exports.scrollView = scrollView;

//# sourceMappingURL=util.js.map
