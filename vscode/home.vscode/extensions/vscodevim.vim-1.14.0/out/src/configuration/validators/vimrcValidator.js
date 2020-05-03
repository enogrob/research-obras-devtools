"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const iconfigurationValidator_1 = require("../iconfigurationValidator");
class VimrcValidator {
    async validate(config) {
        const result = new iconfigurationValidator_1.ValidatorResults();
        // if (config.vimrc.enable && !fs.existsSync(vimrc.vimrcPath)) {
        //   result.append({
        //     level: 'error',
        //     message: `.vimrc not found at ${config.vimrc.path}`,
        //   });
        // }
        return result;
    }
    disable(config) {
        // no-op
    }
}
exports.VimrcValidator = VimrcValidator;

//# sourceMappingURL=vimrcValidator.js.map
