"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const trimEnd_1 = require("lodash/trimEnd");
const tokenTypes_1 = require("./tokenTypes");
const Indentation_1 = require("./Indentation");
const InlineBlock_1 = require("./InlineBlock");
const Params_1 = require("./Params");
class Formatter {
    /**
     * @param {Object} cfg
     *   @param {Object} cfg.indent
     *   @param {Object} cfg.params
     * @param {Tokenizer} tokenizer
     */
    constructor(cfg, tokenizer) {
        this.cfg = cfg || {};
        this.indentation = new Indentation_1.default(this.cfg.indent);
        this.inlineBlock = new InlineBlock_1.default();
        this.params = new Params_1.default(this.cfg.params);
        this.tokenizer = tokenizer;
        this.previousReservedWord = {};
        this.tokens = [];
        this.index = 0;
    }
    /**
     * Formats whitespaces in a SQL string to make it easier to read.
     *
     * @param {String} query The SQL query string
     * @return {String} formatted query
     */
    format(query) {
        this.tokens = this.tokenizer.tokenize(query);
        const formattedQuery = this.getFormattedQueryFromTokens();
        return formattedQuery.trim();
    }
    getFormattedQueryFromTokens() {
        let formattedQuery = "";
        this.tokens.forEach((token, index) => {
            this.index = index;
            if (token.type === tokenTypes_1.default.WHITESPACE) {
                // ignore (we do our own whitespace formatting)
            }
            else if (token.type === tokenTypes_1.default.LINE_COMMENT) {
                formattedQuery = this.formatLineComment(token, formattedQuery);
            }
            else if (token.type === tokenTypes_1.default.BLOCK_COMMENT) {
                formattedQuery = this.formatBlockComment(token, formattedQuery);
            }
            else if (token.type === tokenTypes_1.default.RESERVED_TOPLEVEL) {
                formattedQuery = this.formatToplevelReservedWord(token, formattedQuery);
                this.previousReservedWord = token;
            }
            else if (token.type === tokenTypes_1.default.RESERVED_NEWLINE) {
                formattedQuery = this.formatNewlineReservedWord(token, formattedQuery);
                this.previousReservedWord = token;
            }
            else if (token.type === tokenTypes_1.default.RESERVED) {
                formattedQuery = this.formatWithSpaces(token, formattedQuery);
                this.previousReservedWord = token;
            }
            else if (token.type === tokenTypes_1.default.OPEN_PAREN) {
                formattedQuery = this.formatOpeningParentheses(token, formattedQuery);
            }
            else if (token.type === tokenTypes_1.default.CLOSE_PAREN) {
                formattedQuery = this.formatClosingParentheses(token, formattedQuery);
            }
            else if (token.type === tokenTypes_1.default.PLACEHOLDER) {
                formattedQuery = this.formatPlaceholder(token, formattedQuery);
            }
            else if (token.value === ",") {
                formattedQuery = this.formatComma(token, formattedQuery);
            }
            else if (token.value === ":") {
                formattedQuery = this.formatWithSpaceAfter(token, formattedQuery);
            }
            else if (token.value === ".") {
                formattedQuery = this.formatWithoutSpaces(token, formattedQuery);
            }
            else if (token.value === ";") {
                formattedQuery = this.formatQuerySeparator(token, formattedQuery);
            }
            else {
                formattedQuery = this.formatWithSpaces(token, formattedQuery);
            }
        });
        return formattedQuery;
    }
    formatLineComment(token, query) {
        return this.addNewline(query + token.value);
    }
    formatBlockComment(token, query) {
        return this.addNewline(this.addNewline(query) + this.indentComment(token.value));
    }
    indentComment(comment) {
        return comment.replace(/\n/g, "\n" + this.indentation.getIndent());
    }
    formatToplevelReservedWord(token, query) {
        this.indentation.decreaseTopLevel();
        query = this.addNewline(query);
        this.indentation.increaseToplevel();
        query += this.equalizeWhitespace(token.value);
        return this.addNewline(query);
    }
    formatNewlineReservedWord(token, query) {
        return this.addNewline(query) + this.equalizeWhitespace(token.value) + " ";
    }
    // Replace any sequence of whitespace characters with single space
    equalizeWhitespace(string) {
        return string.replace(/\s+/g, " ");
    }
    // Opening parentheses increase the block indent level and start a new line
    formatOpeningParentheses(token, query) {
        // Take out the preceding space unless there was whitespace there in the original query
        // or another opening parens or line comment
        const preserveWhitespaceFor = [
            tokenTypes_1.default.WHITESPACE,
            tokenTypes_1.default.OPEN_PAREN,
            tokenTypes_1.default.LINE_COMMENT,
        ];
        if (!preserveWhitespaceFor.includes(this.previousToken().type)) {
            query = trimEnd_1.default(query);
        }
        query += token.value;
        this.inlineBlock.beginIfPossible(this.tokens, this.index);
        if (!this.inlineBlock.isActive()) {
            this.indentation.increaseBlockLevel();
            query = this.addNewline(query);
        }
        return query;
    }
    // Closing parentheses decrease the block indent level
    formatClosingParentheses(token, query) {
        if (this.inlineBlock.isActive()) {
            this.inlineBlock.end();
            return this.formatWithSpaceAfter(token, query);
        }
        else {
            this.indentation.decreaseBlockLevel();
            return this.formatWithSpaces(token, this.addNewline(query));
        }
    }
    formatPlaceholder(token, query) {
        return query + this.params.get(token) + " ";
    }
    // Commas start a new line (unless within inline parentheses or SQL "LIMIT" clause)
    formatComma(token, query) {
        query = this.trimTrailingWhitespace(query) + token.value + " ";
        if (this.inlineBlock.isActive()) {
            return query;
        }
        else if (/^LIMIT$/i.test(this.previousReservedWord.value)) {
            return query;
        }
        else {
            return this.addNewline(query);
        }
    }
    formatWithSpaceAfter(token, query) {
        return this.trimTrailingWhitespace(query) + token.value + " ";
    }
    formatWithoutSpaces(token, query) {
        return this.trimTrailingWhitespace(query) + token.value;
    }
    formatWithSpaces(token, query) {
        return query + token.value + " ";
    }
    formatQuerySeparator(token, query) {
        return this.trimTrailingWhitespace(query) + token.value + "\n";
    }
    addNewline(query) {
        return trimEnd_1.default(query) + "\n" + this.indentation.getIndent();
    }
    trimTrailingWhitespace(query) {
        if (this.previousNonWhitespaceToken().type === tokenTypes_1.default.LINE_COMMENT) {
            return trimEnd_1.default(query) + "\n";
        }
        else {
            return trimEnd_1.default(query);
        }
    }
    previousNonWhitespaceToken() {
        let n = 1;
        while (this.previousToken(n).type === tokenTypes_1.default.WHITESPACE) {
            n++;
        }
        return this.previousToken(n);
    }
    previousToken(offset = 1) {
        return this.tokens[this.index - offset] || {};
    }
}
exports.default = Formatter;
//# sourceMappingURL=Formatter.js.map