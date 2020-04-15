"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Db2Formatter_1 = require("./languages/Db2Formatter");
const N1qlFormatter_1 = require("./languages/N1qlFormatter");
const PlSqlFormatter_1 = require("./languages/PlSqlFormatter");
const StandardSqlFormatter_1 = require("./languages/StandardSqlFormatter");
exports.default = {
    /**
     * Format whitespaces in a query to make it easier to read.
     *
     * @param {String} query
     * @param {Object} cfg
     *  @param {String} cfg.language Query language, default is Standard SQL
     *  @param {String} cfg.indent Characters used for indentation, default is "  " (2 spaces)
     *  @param {Object} cfg.params Collection of params for placeholder replacement
     * @return {String}
     */
    format: (query, cfg) => {
        cfg = cfg || {};
        switch (cfg.language) {
            case "db2":
                return new Db2Formatter_1.default(cfg).format(query);
            case "n1ql":
                return new N1qlFormatter_1.default(cfg).format(query);
            case "pl/sql":
                return new PlSqlFormatter_1.default(cfg).format(query);
            case "sql":
            case undefined:
                return new StandardSqlFormatter_1.default(cfg).format(query);
            default:
                throw Error(`Unsupported SQL dialect: ${cfg.language}`);
        }
    }
};
//# sourceMappingURL=sqlFormatter.js.map