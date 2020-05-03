"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const modeHandler_1 = require("./modeHandler");
/**
 * Stores one ModeHandler (and therefore VimState) per editor.
 */
class ModeHandlerMapImpl {
    constructor() {
        this.modeHandlerMap = new Map();
    }
    async getOrCreate(editorId) {
        let isNew = false;
        let modeHandler = this.get(editorId);
        if (!modeHandler) {
            isNew = true;
            modeHandler = await modeHandler_1.ModeHandler.create();
            this.modeHandlerMap.set(editorId, modeHandler);
        }
        return [modeHandler, isNew];
    }
    get(editorId) {
        for (const [key, value] of this.modeHandlerMap.entries()) {
            if (key.isEqual(editorId)) {
                return value;
            }
        }
        return undefined;
    }
    getKeys() {
        return [...this.modeHandlerMap.keys()];
    }
    getAll() {
        return [...this.modeHandlerMap.values()];
    }
    delete(editorId) {
        const modeHandler = this.modeHandlerMap.get(editorId);
        if (modeHandler) {
            modeHandler.dispose();
            this.modeHandlerMap.delete(editorId);
        }
    }
    clear() {
        for (const key of this.modeHandlerMap.keys()) {
            this.delete(key);
        }
    }
}
exports.ModeHandlerMap = new ModeHandlerMapImpl();

//# sourceMappingURL=modeHandlerMap.js.map
