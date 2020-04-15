"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Formatter_1 = require("../core/Formatter");
const Tokenizer_1 = require("../core/Tokenizer");
const reservedWords = [
    "ABS", "ACTIVATE", "ALIAS", "ALL", "ALLOCATE", "ALLOW", "ALTER", "ANY", "ARE", "ARRAY", "AS", "ASC",
    "ASENSITIVE", "ASSOCIATE", "ASUTIME", "ASYMMETRIC", "AT", "ATOMIC", "ATTRIBUTES", "AUDIT", "AUTHORIZATION", "AUX", "AUXILIARY", "AVG",
    "BEFORE", "BEGIN", "BETWEEN", "BIGINT", "BINARY", "BLOB", "BOOLEAN", "BOTH", "BUFFERPOOL", "BY",
    "CACHE", "CALL", "CALLED", "CAPTURE", "CARDINALITY", "CASCADED", "CASE", "CAST", "CCSID", "CEIL", "CEILING", "CHAR", "CHARACTER",
    "CHARACTER_LENGTH", "CHAR_LENGTH", "CHECK", "CLOB", "CLONE", "CLOSE", "CLUSTER", "COALESCE", "COLLATE", "COLLECT", "COLLECTION",
    "COLLID", "COLUMN", "COMMENT", "COMMIT", "CONCAT", "CONDITION", "CONNECT", "CONNECTION", "CONSTRAINT", "CONTAINS", "CONTINUE",
    "CONVERT", "CORR", "CORRESPONDING", "COUNT", "COUNT_BIG", "COVAR_POP", "COVAR_SAMP", "CREATE", "CROSS", "CUBE", "CUME_DIST", "CURRENT",
    "CURRENT_DATE", "CURRENT_DEFAULT_TRANSFORM_GROUP", "CURRENT_LC_CTYPE", "CURRENT_PATH", "CURRENT_ROLE", "CURRENT_SCHEMA",
    "CURRENT_SERVER", "CURRENT_TIME", "CURRENT_TIMESTAMP", "CURRENT_TIMEZONE", "CURRENT_TRANSFORM_GROUP_FOR_TYPE", "CURRENT_USER", "CURSOR",
    "CYCLE",
    "DATA", "DATABASE", "DATAPARTITIONNAME", "DATAPARTITIONNUM", "DATE", "DAY", "DAYS", "DB2GENERAL", "DB2GENRL", "DB2SQL", "DBINFO",
    "DBPARTITIONNAME", "DBPARTITIONNUM", "DEALLOCATE", "DEC", "DECIMAL", "DECLARE", "DEFAULT", "DEFAULTS", "DEFINITION", "DELETE",
    "DENSERANK", "DENSE_RANK", "DEREF", "DESCRIBE", "DESCRIPTOR", "DETERMINISTIC", "DIAGNOSTICS", "DISABLE", "DISALLOW", "DISCONNECT",
    "DISTINCT", "DO", "DOCUMENT", "DOUBLE", "DROP", "DSSIZE", "DYNAMIC",
    "EACH", "EDITPROC", "ELEMENT", "ELSE", "ELSEIF", "ENABLE", "ENCODING", "ENCRYPTION", "END", "END-EXEC", "ENDING", "ERASE", "ESCAPE",
    "EVERY", "EXCEPTION", "EXCLUDING", "EXCLUSIVE", "EXEC", "EXECUTE", "EXISTS", "EXIT", "EXP", "EXPLAIN", "EXTENDED", "EXTERNAL",
    "EXTRACT",
    "FALSE", "FENCED", "FETCH", "FIELDPROC", "FILE", "FILTER", "FINAL", "FIRST", "FLOAT", "FLOOR", "FOR", "FOREIGN", "FREE", "FULL",
    "FUNCTION", "FUSION",
    "GENERAL", "GENERATED", "GET", "GLOBAL", "GOTO", "GRANT", "GRAPHIC", "GROUP", "GROUPING",
    "HANDLER", "HASH", "HASHED_VALUE", "HINT", "HOLD", "HOUR", "HOURS",
    "IDENTITY", "IF", "IMMEDIATE", "IN", "INCLUDING", "INCLUSIVE", "INCREMENT", "INDEX", "INDICATOR", "INDICATORS", "INF", "INFINITY",
    "INHERIT", "INNER", "INOUT", "INSENSITIVE", "INSERT", "INT", "INTEGER", "INTEGRITY", "INTERSECTION", "INTERVAL", "INTO",
    "IS", "ISOBID", "ISOLATION", "ITERATE",
    "JAR", "JAVA",
    "KEEP", "KEY",
    "LABEL", "LANGUAGE", "LARGE", "LATERAL", "LC_CTYPE", "LEADING", "LEAVE", "LEFT", "LIKE", "LINKTYPE", "LN", "LOCAL",
    "LOCALDATE", "LOCALE", "LOCALTIME", "LOCALTIMESTAMP", "LOCATOR", "LOCATORS", "LOCK", "LOCKMAX", "LOCKSIZE", "LONG", "LOOP", "LOWER",
    "MAINTAINED", "MATCH", "MATERIALIZED", "MAX", "MAXVALUE", "MEMBER", "MERGE", "METHOD", "MICROSECOND", "MICROSECONDS", "MIN", "MINUTE",
    "MINUTES", "MINVALUE", "MOD", "MODE", "MODIFIES", "MODULE", "MONTH", "MONTHS", "MULTISET",
    "NAN", "NATIONAL", "NATURAL", "NCHAR", "NCLOB", "NEW", "NEW_TABLE", "NEXTVAL", "NO", "NOCACHE", "NOCYCLE", "NODENAME", "NODENUMBER",
    "NOMAXVALUE", "NOMINVALUE", "NONE", "NOORDER", "NORMALIZE", "NORMALIZED", "NOT", "NULL", "NULLIF", "NULLS", "NUMERIC", "NUMPARTS",
    "OBID", "OCTET_LENGTH", "OF", "OFFSET", "OLD", "OLD_TABLE", "ON", "ONLY", "OPEN", "OPTIMIZATION", "OPTIMIZE", "OPTION", "ORDER",
    "OUT", "OUTER", "OVER", "OVERLAPS", "OVERLAY", "OVERRIDING",
    "PACKAGE", "PADDED", "PAGESIZE", "PARAMETER", "PART", "PARTITION", "PARTITIONED", "PARTITIONING", "PARTITIONS", "PASSWORD", "PATH",
    "PERCENTILE_CONT", "PERCENTILE_DISC", "PERCENT_RANK", "PIECESIZE", "PLAN", "POSITION", "POWER", "PRECISION", "PREPARE", "PREVVAL",
    "PRIMARY", "PRIQTY", "PRIVILEGES", "PROCEDURE", "PROGRAM", "PSID", "PUBLIC",
    "QUERY", "QUERYNO",
    "RANGE", "RANK", "READ", "READS", "REAL", "RECOVERY", "RECURSIVE", "REF", "REFERENCES", "REFERENCING", "REFRESH", "REGR_AVGX",
    "REGR_AVGY", "REGR_COUNT", "REGR_INTERCEPT", "REGR_R2", "REGR_SLOPE", "REGR_SXX", "REGR_SXY", "REGR_SYY", "RELEASE", "RENAME", "REPEAT",
    "RESET", "RESIGNAL", "RESTART", "RESTRICT", "RESULT", "RESULT_SET_LOCATOR", "RETURN", "RETURNS", "REVOKE", "RIGHT", "ROLE", "ROLLBACK",
    "ROLLUP", "ROUND_CEILING", "ROUND_DOWN", "ROUND_FLOOR", "ROUND_HALF_DOWN", "ROUND_HALF_EVEN", "ROUND_HALF_UP", "ROUND_UP", "ROUTINE",
    "ROW", "ROWNUMBER", "ROWS", "ROWSET", "ROW_NUMBER", "RRN", "RUN",
    "SAVEPOINT", "SCHEMA", "SCOPE", "SCRATCHPAD", "SCROLL", "SEARCH", "SECOND", "SECONDS", "SECQTY", "SECURITY", "SENSITIVE",
    "SEQUENCE", "SESSION", "SESSION_USER", "SIGNAL", "SIMILAR", "SIMPLE", "SMALLINT", "SNAN", "SOME", "SOURCE", "SPECIFIC",
    "SPECIFICTYPE", "SQL", "SQLEXCEPTION", "SQLID", "SQLSTATE", "SQLWARNING", "SQRT", "STACKED", "STANDARD", "START", "STARTING",
    "STATEMENT", "STATIC", "STATMENT", "STAY", "STDDEV_POP", "STDDEV_SAMP", "STOGROUP", "STORES", "STYLE", "SUBMULTISET", "SUBSTRING",
    "SUM", "SUMMARY", "SYMMETRIC", "SYNONYM", "SYSFUN", "SYSIBM", "SYSPROC", "SYSTEM", "SYSTEM_USER",
    "TABLE", "TABLESAMPLE", "TABLESPACE", "THEN", "TIME", "TIMESTAMP", "TIMEZONE_HOUR", "TIMEZONE_MINUTE", "TO", "TRAILING", "TRANSACTION",
    "TRANSLATE", "TRANSLATION", "TREAT", "TRIGGER", "TRIM", "TRUE", "TRUNCATE", "TYPE",
    "UESCAPE", "UNDO", "UNIQUE", "UNKNOWN", "UNNEST", "UNTIL", "UPPER", "USAGE", "USER", "USING",
    "VALIDPROC", "VALUE", "VARCHAR", "VARIABLE", "VARIANT", "VARYING", "VAR_POP", "VAR_SAMP", "VCAT", "VERSION", "VIEW",
    "VOLATILE", "VOLUMES", "WHEN", "WHENEVER", "WHILE", "WIDTH_BUCKET", "WINDOW", "WITH", "WITHIN", "WITHOUT", "WLM", "WRITE",
    "XMLELEMENT", "XMLEXISTS", "XMLNAMESPACES",
    "YEAR", "YEARS"
];
const reservedToplevelWords = [
    "ADD", "AFTER", "ALTER COLUMN", "ALTER TABLE",
    "DELETE FROM",
    "EXCEPT",
    "FETCH FIRST", "FROM",
    "GROUP BY", "GO",
    "HAVING",
    "INSERT INTO", "INTERSECT",
    "LIMIT",
    "ORDER BY",
    "SELECT", "SET CURRENT SCHEMA", "SET SCHEMA", "SET",
    "UNION ALL", "UPDATE",
    "VALUES",
    "WHERE"
];
const reservedNewlineWords = [
    "AND",
    "CROSS JOIN",
    "INNER JOIN",
    "JOIN",
    "LEFT JOIN", "LEFT OUTER JOIN",
    "OR", "OUTER JOIN",
    "RIGHT JOIN", "RIGHT OUTER JOIN"
];
let tokenizer;
class Db2Formatter {
    /**
     * @param {Object} cfg Different set of configurations
     */
    constructor(cfg) {
        this.cfg = cfg;
    }
    /**
     * Formats DB2 query to make it easier to read
     *
     * @param {String} query The DB2 query string
     * @return {String} formatted string
     */
    format(query) {
        if (!tokenizer) {
            tokenizer = new Tokenizer_1.default({
                reservedWords,
                reservedToplevelWords,
                reservedNewlineWords,
                stringTypes: [`""`, "''", "``", "[]"],
                openParens: ["("],
                closeParens: [")"],
                indexedPlaceholderTypes: ["?"],
                namedPlaceholderTypes: [":"],
                lineCommentTypes: ["--"],
                specialWordChars: ["#", "@"]
            });
        }
        return new Formatter_1.default(this.cfg, tokenizer).format(query);
    }
}
exports.default = Db2Formatter;
//# sourceMappingURL=Db2Formatter.js.map