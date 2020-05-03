"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const register_1 = require("../../register/register");
const recordedState_1 = require("../../state/recordedState");
const node = require("../node");
class RegisterCommand extends node.CommandBase {
    constructor(args) {
        super();
        this._arguments = args;
    }
    get arguments() {
        return this._arguments;
    }
    async getRegisterDisplayValue(register) {
        let result = (await register_1.Register.getByKey(register)).text;
        if (result instanceof Array) {
            result = result.join('\n').substr(0, 100);
        }
        else if (result instanceof recordedState_1.RecordedState) {
            result = result.actionsRun.map((x) => x.keysPressed.join('')).join('');
        }
        return result;
    }
    async displayRegisterValue(register) {
        let result = await this.getRegisterDisplayValue(register);
        result = result.replace(/\n/g, '\\n');
        vscode.window.showInformationMessage(`${register} ${result}`);
    }
    async execute(vimState) {
        if (this.arguments.registers.length === 1) {
            await this.displayRegisterValue(this.arguments.registers[0]);
        }
        else {
            const currentRegisterKeys = register_1.Register.getKeys().filter((reg) => reg !== '_' &&
                (this.arguments.registers.length === 0 || this.arguments.registers.includes(reg)));
            const registerKeyAndContent = new Array();
            for (let registerKey of currentRegisterKeys) {
                registerKeyAndContent.push({
                    label: registerKey,
                    description: await this.getRegisterDisplayValue(registerKey),
                });
            }
            vscode.window.showQuickPick(registerKeyAndContent).then(async (val) => {
                if (val) {
                    let result = val.description;
                    vscode.window.showInformationMessage(`${val.label} ${result}`);
                }
            });
        }
    }
}
exports.RegisterCommand = RegisterCommand;

//# sourceMappingURL=register.js.map
