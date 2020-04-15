"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function quoteMapper(line) {
    const quoteIndex = line.indexOf("'");
    const start = quoteIndex >= 0 ? quoteIndex : line.indexOf('"') || 0;
    return line.slice(start);
}
function extractDependency(line) {
    const mapped = quoteMapper(line);
    const parts = mapped
        .trim()
        .split(",")
        .map(s => s.trim().replace(/'|"/g, ""));
    if (parts.length === 2) {
        const name = parts[0];
        const requirements = parts[1];
        return { name: name, requirements: requirements };
    }
    return undefined;
}
exports.extractDependency = extractDependency;
//# sourceMappingURL=extractGem.js.map