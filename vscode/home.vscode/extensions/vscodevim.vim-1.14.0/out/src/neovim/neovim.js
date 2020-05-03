"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const util = require("util");
const vscode = require("vscode");
const logger_1 = require("../util/logger");
const position_1 = require("./../common/motion/position");
const register_1 = require("../register/register");
const textEditor_1 = require("../textEditor");
const configuration_1 = require("../configuration/configuration");
const path_1 = require("path");
const fs_1 = require("fs");
const child_process_1 = require("child_process");
const attach_1 = require("neovim/lib/attach");
class NeovimWrapper {
    constructor() {
        this.logger = logger_1.Logger.get('Neovim');
        this.processTimeoutInSeconds = 3;
    }
    async run(vimState, command) {
        if (!this.nvim) {
            this.nvim = await this.startNeovim();
            try {
                const nvimAttach = this.nvim.uiAttach(80, 20, {
                    ext_cmdline: false,
                    ext_popupmenu: false,
                    ext_tabline: false,
                    ext_wildmenu: false,
                    rgb: false,
                });
                const timeout = new Promise((resolve, reject) => {
                    setTimeout(() => reject(new Error('Timeout')), this.processTimeoutInSeconds * 1000);
                });
                await Promise.race([nvimAttach, timeout]);
            }
            catch (e) {
                configuration_1.configuration.enableNeovim = false;
                throw new Error(`Failed to attach to neovim process. ${e.message}`);
            }
            const apiInfo = await this.nvim.apiInfo;
            const version = apiInfo[1].version;
            this.logger.debug(`version: ${version.major}.${version.minor}.${version.patch}`);
        }
        await this.syncVSCodeToVim(vimState);
        command = (':' + command + '\n').replace('<', '<lt>');
        // Clear the previous error and status messages.
        // API does not allow setVvar so do it manually
        await this.nvim.command('let v:errmsg="" | let v:statusmsg=""');
        // Execute the command
        this.logger.debug(`Running ${command}.`);
        await this.nvim.input(command);
        const mode = await this.nvim.mode;
        if (mode.blocking) {
            await this.nvim.input('<esc>');
        }
        // Check if an error occurred
        const errMsg = await this.nvim.getVvar('errmsg');
        let statusBarText = '';
        if (errMsg && errMsg.toString() !== '') {
            statusBarText = errMsg.toString();
        }
        else {
            // Check to see if a status message was updated
            const statusMsg = await this.nvim.getVvar('statusmsg');
            if (statusMsg && statusMsg.toString() !== '') {
                statusBarText = statusMsg.toString();
            }
        }
        // Sync buffer back to VSCode
        await this.syncVimToVSCode(vimState);
        return statusBarText;
    }
    async startNeovim() {
        this.logger.debug('Spawning Neovim process...');
        let dir = path_1.dirname(vscode.window.activeTextEditor.document.uri.fsPath);
        if (!(await util.promisify(fs_1.exists)(dir))) {
            dir = __dirname;
        }
        this.process = child_process_1.spawn(configuration_1.configuration.neovimPath, ['-u', 'NONE', '-i', 'NONE', '-n', '--embed'], {
            cwd: dir,
        });
        this.process.on('error', (err) => {
            this.logger.error(`Error spawning neovim. ${err.message}.`);
            configuration_1.configuration.enableNeovim = false;
        });
        return attach_1.attach({ proc: this.process });
    }
    // Data flows from VSCode to Vim
    async syncVSCodeToVim(vimState) {
        const buf = await this.nvim.buffer;
        if (configuration_1.configuration.expandtab) {
            await vscode.commands.executeCommand('editor.action.indentationToTabs');
        }
        await this.nvim.setOption('gdefault', configuration_1.configuration.gdefault === true);
        await buf.setLines(textEditor_1.TextEditor.getText().split('\n'), {
            start: 0,
            end: -1,
            strictIndexing: true,
        });
        const [rangeStart, rangeEnd] = position_1.Position.sorted(vimState.cursorStartPosition, vimState.cursorStopPosition);
        await this.nvim.callFunction('setpos', [
            '.',
            [0, vimState.cursorStopPosition.line + 1, vimState.cursorStopPosition.character, false],
        ]);
        await this.nvim.callFunction('setpos', [
            "'<",
            [0, rangeStart.line + 1, rangeEnd.character, false],
        ]);
        await this.nvim.callFunction('setpos', [
            "'>",
            [0, rangeEnd.line + 1, rangeEnd.character, false],
        ]);
        for (const mark of vimState.historyTracker.getLocalMarks()) {
            await this.nvim.callFunction('setpos', [
                `'${mark.name}`,
                [0, mark.position.line + 1, mark.position.character, false],
            ]);
        }
        // We only copy over " register for now, due to our weird handling of macros.
        let reg = await register_1.Register.get(vimState);
        let vsRegTovimReg = [undefined, 'c', 'l', 'b'];
        await this.nvim.callFunction('setreg', [
            '"',
            reg.text,
            vsRegTovimReg[vimState.effectiveRegisterMode],
        ]);
    }
    // Data flows from Vim to VSCode
    async syncVimToVSCode(vimState) {
        const buf = await this.nvim.buffer;
        const lines = await buf.getLines({ start: 0, end: -1, strictIndexing: false });
        // one Windows, lines that went to nvim and back have a '\r' at the end,
        // which causes the issues exhibited in #1914
        const fixedLines = process.platform === 'win32' ? lines.map((line, index) => line.replace(/\r$/, '')) : lines;
        const lineCount = textEditor_1.TextEditor.getLineCount();
        await textEditor_1.TextEditor.replace(new vscode.Range(0, 0, lineCount - 1, textEditor_1.TextEditor.getLineLength(lineCount - 1)), fixedLines.join('\n'));
        this.logger.debug(`${lines.length} lines in nvim. ${lineCount} in editor.`);
        let [row, character] = (await this.nvim.callFunction('getpos', ['.'])).slice(1, 3);
        vimState.editor.selection = new vscode.Selection(new position_1.Position(row - 1, character), new position_1.Position(row - 1, character));
        if (configuration_1.configuration.expandtab) {
            await vscode.commands.executeCommand('editor.action.indentationToSpaces');
        }
        // We're only syncing back the default register for now, due to the way we could
        // be storing macros in registers.
        const vimRegToVsReg = {
            v: register_1.RegisterMode.CharacterWise,
            V: register_1.RegisterMode.LineWise,
            '\x16': register_1.RegisterMode.BlockWise,
        };
        vimState.currentRegisterMode =
            vimRegToVsReg[(await this.nvim.callFunction('getregtype', ['"']))];
        register_1.Register.put((await this.nvim.callFunction('getreg', ['"'])), vimState);
    }
    dispose() {
        if (this.nvim) {
            this.nvim.quit();
        }
        if (this.process) {
            this.process.kill();
        }
    }
}
exports.NeovimWrapper = NeovimWrapper;

//# sourceMappingURL=neovim.js.map
