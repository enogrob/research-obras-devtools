"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const iconfigurationValidator_1 = require("../iconfigurationValidator");
const util_1 = require("util");
const child_process_1 = require("child_process");
const path = require("path");
const fs_1 = require("fs");
class NeovimValidator {
    async validate(config) {
        const result = new iconfigurationValidator_1.ValidatorResults();
        if (config.enableNeovim) {
            let triedToParsePath = false;
            try {
                // Try to find nvim in path if it is not defined
                if (config.neovimPath === '') {
                    const pathVar = process.env.PATH;
                    if (pathVar) {
                        pathVar.split(';').forEach((element) => {
                            let neovimExecutable = 'nvim';
                            if (process.platform === 'win32') {
                                neovimExecutable += '.exe';
                            }
                            const testPath = path.join(element, neovimExecutable);
                            if (fs_1.existsSync(testPath)) {
                                config.neovimPath = testPath;
                                triedToParsePath = true;
                                return;
                            }
                        });
                    }
                }
                await util_1.promisify(child_process_1.execFile)(config.neovimPath, ['--version']);
            }
            catch (e) {
                let errorMessage = `Invalid neovimPath. ${e.message}.`;
                if (triedToParsePath) {
                    errorMessage += `Tried to parse PATH ${config.neovimPath}.`;
                }
                result.append({
                    level: 'error',
                    message: errorMessage,
                });
            }
        }
        return Promise.resolve(result);
    }
    disable(config) {
        config.enableNeovim = false;
    }
}
exports.NeovimValidator = NeovimValidator;

//# sourceMappingURL=neovimValidator.js.map
