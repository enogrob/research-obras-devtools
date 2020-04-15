"use strict";
function quoteMapper(line) {
    const quoteIndex = line.indexOf("'");
    const start = quoteIndex >= 0 ? quoteIndex : line.indexOf('"') || 0;
    return line.slice(start);
}
function reduceGemDeps(dependencies) {
    dependencies.map(quoteMapper).map((line) => {
        const parts = line
            .split(",")
            .map(s => s.trim().replace(/'|"/g, ""));
        const name = parts[0] || "N/A";
        const requirements = parts[1] || "N/A";
        return { name: name, requirements: requirements };
    });
}
function extractGems(lines) {
    return lines
        .map(line => line.trim())
        .filter(line => line.match(/^\w+\.(add_development_dependency|add_runtime_dependency|add_dependency)/));
}
function interpret(string) {
    const lines = string.split("\n");
    const selectedLines = lines
        .map(line => line.trim())
        .filter(line => line.match(/^\w+\.(add_development_dependency|add_runtime_dependency|add_dependency)/));
}
//# sourceMappingURL=gemPackageParser.js.map