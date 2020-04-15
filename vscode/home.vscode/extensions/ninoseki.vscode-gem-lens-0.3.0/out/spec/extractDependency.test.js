"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const extractDependency_1 = require("../extractDependency");
test("extractDependency", () => {
    const line = '  spec.add_development_dependency "bundler", "~> 2.0"';
    const dependecy = extractDependency_1.extractDependency(line);
    expect(dependecy).toBe({
        name: "bundler",
        requirements: "~> 2.0",
    });
});
//# sourceMappingURL=extractDependency.test.js.map