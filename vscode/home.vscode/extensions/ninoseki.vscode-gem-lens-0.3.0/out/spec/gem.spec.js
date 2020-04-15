"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const moxios = require("moxios");
const gem_1 = require("../gem");
describe("Gem", () => {
    beforeEach(() => {
        moxios.install();
    });
    afterEach(() => {
        moxios.uninstall();
    });
    test("initialize", () => {
        const gem = new gem_1.Gem("rails", "~> 1.0");
        expect(gem.name).toBe("rails");
        expect(gem.requirements).toBe("~> 1.0");
    });
    test("info", () => __awaiter(void 0, void 0, void 0, function* () {
        moxios.stubRequest("https://rubygems.org/api/v1/gems/rails.json", {
            response: {
                name: "rails",
                downloads: 7528417,
                version: "3.2.1",
                authors: "David Heinemeier Hansson",
                info: "Ruby on Rails is a full-stack web framework",
            },
            status: 200,
        });
        const gem = new gem_1.Gem("rails", "~> 1.0");
        const details = yield gem.details();
        expect(details).toBeDefined();
        if (details) {
            expect(details.version).toBe("3.2.1");
            expect(details.info).toBe("Ruby on Rails is a full-stack web framework");
        }
    }));
});
//# sourceMappingURL=gem.spec.js.map