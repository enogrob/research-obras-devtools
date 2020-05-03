"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
class VimrcKeyRemappingBuilderImpl {
    /**
     * @returns A remapping if the given `line` parses to one, and `undefined` otherwise.
     */
    async build(line) {
        if (line.trimLeft().startsWith('"')) {
            return;
        }
        const matches = VimrcKeyRemappingBuilderImpl.KEY_REMAPPING_REG_EX.exec(line);
        if (!matches || matches.length < 4) {
            return undefined;
        }
        const type = matches[1];
        const before = matches[2];
        const after = matches[3];
        const vscodeCommands = await vscode.commands.getCommands();
        const vimCommand = after.match(VimrcKeyRemappingBuilderImpl.VIM_COMMAND_REG_EX);
        let command;
        if (vscodeCommands.includes(after)) {
            command = { commands: [after] };
        }
        else if (vimCommand) {
            command = { commands: [vimCommand[1]] };
        }
        else {
            command = { after: VimrcKeyRemappingBuilderImpl.buildKeyList(after) };
        }
        return {
            keyRemapping: {
                before: VimrcKeyRemappingBuilderImpl.buildKeyList(before),
                source: 'vimrc',
                ...command,
            },
            keyRemappingType: type,
        };
    }
    static buildKeyList(keyString) {
        let keyList = [];
        let matches = null;
        do {
            matches = VimrcKeyRemappingBuilderImpl.KEY_LIST_REG_EX.exec(keyString);
            if (matches) {
                keyList.push(matches[0]);
            }
        } while (matches);
        return keyList;
    }
}
VimrcKeyRemappingBuilderImpl.KEY_REMAPPING_REG_EX = /(^.*map)\s([\S]+)\s+(?!<Plug>)([\S]+)$/;
VimrcKeyRemappingBuilderImpl.KEY_LIST_REG_EX = /(<[^>]+>|.)/g;
VimrcKeyRemappingBuilderImpl.VIM_COMMAND_REG_EX = /^(:\w+)<[Cc][Rr]>$/;
exports.vimrcKeyRemappingBuilder = new VimrcKeyRemappingBuilderImpl();

//# sourceMappingURL=vimrcKeyRemappingBuilder.js.map
