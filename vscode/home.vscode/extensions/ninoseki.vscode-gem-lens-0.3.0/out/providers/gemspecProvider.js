"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const abstractProvider_1 = require("./abstractProvider");
class GemspecProvider extends abstractProvider_1.AbstractProvider {
    gemRegexp() {
        return /\w+\.(add_development_dependency|add_runtime_dependency|add_dependency)/;
    }
}
exports.GemspecProvider = GemspecProvider;
//# sourceMappingURL=gemspecProvider.js.map