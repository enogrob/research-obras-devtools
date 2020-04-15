"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const OutputChannel_1 = require("../common/OutputChannel");
class TableHoverProvider {
    provideHover(document, position, token) {
        OutputChannel_1.Console.log(position);
    }
}
exports.TableHoverProvider = TableHoverProvider;
//# sourceMappingURL=HoverProvider.js.map