"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const extractDependency_1 = require("../extractDependency");
test("extractDependency", () => {
    const gemspecLine = '  spec.add_development_dependency "bundler", "~> 2.0"';
    let dependency = extractDependency_1.extractDependency(gemspecLine);
    expect(dependency).toBeDefined();
    if (dependency) {
        expect(dependency.name).toBe("bundler");
        expect(dependency.requirements).toBe("~> 2.0");
    }
    const gemLine = `  gem "pry", "~> 0.12"`;
    dependency = extractDependency_1.extractDependency(gemLine);
    expect(dependency).toBeDefined();
    if (dependency) {
        expect(dependency.name).toBe("pry");
        expect(dependency.requirements).toBe("~> 0.12");
    }
    const gemLineWithOption = `  gem "coveralls", "~> 0.8", require: false`;
    dependency = extractDependency_1.extractDependency(gemLineWithOption);
    expect(dependency).toBeDefined();
    if (dependency) {
        expect(dependency.name).toBe("coveralls");
        expect(dependency.requirements).toBe("~> 0.8");
    }
    const gemLineWithoutVersion = `gem "rails"`;
    dependency = extractDependency_1.extractDependency(gemLineWithoutVersion);
    expect(dependency).toBeDefined();
    if (dependency) {
        expect(dependency.name).toBe("rails");
        expect(dependency.requirements).toBeUndefined();
    }
    const nonGemLine = "foo bar";
    dependency = extractDependency_1.extractDependency(nonGemLine);
    expect(dependency).toBeUndefined();
});
//# sourceMappingURL=extractDependency.spec.js.map