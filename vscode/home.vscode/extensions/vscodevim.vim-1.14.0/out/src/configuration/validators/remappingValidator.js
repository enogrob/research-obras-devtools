"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const notation_1 = require("../notation");
const iconfigurationValidator_1 = require("../iconfigurationValidator");
class RemappingValidator {
    async validate(config) {
        const result = new iconfigurationValidator_1.ValidatorResults();
        const modeKeyBindingsKeys = [
            'insertModeKeyBindings',
            'insertModeKeyBindingsNonRecursive',
            'normalModeKeyBindings',
            'normalModeKeyBindingsNonRecursive',
            'visualModeKeyBindings',
            'visualModeKeyBindingsNonRecursive',
            'commandLineModeKeyBindings',
            'commandLineModeKeyBindingsNonRecursive',
        ];
        for (const modeKeyBindingsKey of modeKeyBindingsKeys) {
            let keybindings = config[modeKeyBindingsKey];
            const modeKeyBindingsMap = new Map();
            for (let i = keybindings.length - 1; i >= 0; i--) {
                let remapping = keybindings[i];
                // validate
                let remappingError = await this.isRemappingValid(remapping);
                result.concat(remappingError);
                if (remappingError.hasError) {
                    // errors with remapping, skip
                    keybindings.splice(i, 1);
                    continue;
                }
                // normalize
                if (remapping.before) {
                    remapping.before.forEach((key, idx) => (remapping.before[idx] = notation_1.Notation.NormalizeKey(key, config.leader)));
                }
                if (remapping.after) {
                    remapping.after.forEach((key, idx) => (remapping.after[idx] = notation_1.Notation.NormalizeKey(key, config.leader)));
                }
                // check for duplicates
                const beforeKeys = remapping.before.join('');
                if (modeKeyBindingsMap.has(beforeKeys)) {
                    result.append({
                        level: 'warning',
                        message: `${remapping.before}. Duplicate remapped key for ${beforeKeys}.`,
                    });
                    continue;
                }
                // add to map
                modeKeyBindingsMap.set(beforeKeys, remapping);
            }
            config[modeKeyBindingsKey + 'Map'] = modeKeyBindingsMap;
        }
        return result;
    }
    disable(config) {
        // no-op
    }
    async isRemappingValid(remapping) {
        const result = new iconfigurationValidator_1.ValidatorResults();
        if (!remapping.after && !remapping.commands) {
            result.append({
                level: 'error',
                message: `${remapping.before} missing 'after' key or 'command'.`,
            });
        }
        if (!(remapping.before instanceof Array)) {
            result.append({
                level: 'error',
                message: `Remapping of '${remapping.before}' should be a string array.`,
            });
        }
        if (remapping.after && !(remapping.after instanceof Array)) {
            result.append({
                level: 'error',
                message: `Remapping of '${remapping.after}' should be a string array.`,
            });
        }
        if (remapping.commands) {
            for (const command of remapping.commands) {
                let cmd;
                if (typeof command === 'string') {
                    cmd = command;
                }
                else {
                    cmd = command.command;
                }
                if (!(await this.isCommandValid(cmd))) {
                    result.append({ level: 'warning', message: `${cmd} does not exist.` });
                }
            }
        }
        return result;
    }
    async isCommandValid(command) {
        if (command.startsWith(':')) {
            return true;
        }
        return (await this.getCommandMap()).has(command);
    }
    async getCommandMap() {
        if (this._commandMap == null) {
            this._commandMap = new Map((await vscode.commands.getCommands(true)).map((x) => [x, true]));
        }
        return this._commandMap;
    }
}
exports.RemappingValidator = RemappingValidator;

//# sourceMappingURL=remappingValidator.js.map
