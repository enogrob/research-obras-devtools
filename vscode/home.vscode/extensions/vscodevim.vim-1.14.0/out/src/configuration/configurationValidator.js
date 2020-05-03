"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const iconfigurationValidator_1 = require("./iconfigurationValidator");
const inputMethodSwitcherValidator_1 = require("./validators/inputMethodSwitcherValidator");
const neovimValidator_1 = require("./validators/neovimValidator");
const remappingValidator_1 = require("./validators/remappingValidator");
const vimrcValidator_1 = require("./validators/vimrcValidator");
class ConfigurationValidator {
    constructor() {
        this._validators = [
            new inputMethodSwitcherValidator_1.InputMethodSwitcherConfigurationValidator(),
            new neovimValidator_1.NeovimValidator(),
            new remappingValidator_1.RemappingValidator(),
            new vimrcValidator_1.VimrcValidator(),
        ];
    }
    async validate(config) {
        const results = new iconfigurationValidator_1.ValidatorResults();
        for (const validator of this._validators) {
            let validatorResults = await validator.validate(config);
            if (validatorResults.hasError) {
                // errors found in configuration, disable feature
                validator.disable(config);
            }
            results.concat(validatorResults);
        }
        return results;
    }
}
exports.configurationValidator = new ConfigurationValidator();

//# sourceMappingURL=configurationValidator.js.map
