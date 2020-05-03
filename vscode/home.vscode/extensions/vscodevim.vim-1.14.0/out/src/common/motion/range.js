"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const position_1 = require("./position");
class Range {
    constructor(start, stop) {
        this.start = start;
        this.stop = stop;
    }
    isValid(textEditor) {
        return this.start.isValid(textEditor) && this.stop.isValid(textEditor);
    }
    /**
     * Create a range from a VSCode selection.
     */
    static FromVSCodeSelection(sel) {
        return new Range(position_1.Position.FromVSCodePosition(sel.start), position_1.Position.FromVSCodePosition(sel.end));
    }
    equals(other) {
        return this.start.isEqual(other.start) && this.stop.isEqual(other.stop);
    }
    /**
     * Returns a new Range which is the same as this Range, but with the provided stop value.
     */
    withNewStop(stop) {
        return new Range(this.start, stop);
    }
    /**
     * Returns a new Range which is the same as this Range, but with the provided start value.
     */
    withNewStart(start) {
        return new Range(start, this.stop);
    }
    toString() {
        return `[ ${this.start.toString()} | ${this.stop.toString()}]`;
    }
    overlaps(other) {
        return this.start.isBefore(other.stop) && other.start.isBefore(this.stop);
    }
}
exports.Range = Range;

//# sourceMappingURL=range.js.map
