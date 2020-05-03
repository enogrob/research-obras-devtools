"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const util = require("../../util/util");
const logger_1 = require("../../util/logger");
const mode_1 = require("../../mode/mode");
const configuration_1 = require("../../configuration/configuration");
/**
 * InputMethodSwitcher changes input method when mode changed
 */
class InputMethodSwitcher {
    constructor(execute = util.executeShell) {
        this.logger = logger_1.Logger.get('IMSwitcher');
        this.savedIMKey = '';
        this.execute = execute;
    }
    async switchInputMethod(prevMode, newMode) {
        if (configuration_1.configuration.autoSwitchInputMethod.enable !== true) {
            return;
        }
        // when you exit from insert-like mode, save origin input method and set it to default
        let isPrevModeInsertLike = this.isInsertLikeMode(prevMode);
        let isNewModeInsertLike = this.isInsertLikeMode(newMode);
        if (isPrevModeInsertLike !== isNewModeInsertLike) {
            if (isNewModeInsertLike) {
                await this.resumeIM();
            }
            else {
                await this.switchToDefaultIM();
            }
        }
    }
    // save origin input method and set input method to default
    async switchToDefaultIM() {
        const obtainIMCmd = configuration_1.configuration.autoSwitchInputMethod.obtainIMCmd;
        try {
            const insertIMKey = await this.execute(obtainIMCmd);
            if (insertIMKey !== undefined) {
                this.savedIMKey = insertIMKey.trim();
            }
        }
        catch (e) {
            this.logger.error(`Error switching to default IM. err=${e}`);
        }
        const defaultIMKey = configuration_1.configuration.autoSwitchInputMethod.defaultIM;
        if (defaultIMKey !== this.savedIMKey) {
            await this.switchToIM(defaultIMKey);
        }
    }
    // resume origin inputmethod
    async resumeIM() {
        if (this.savedIMKey !== configuration_1.configuration.autoSwitchInputMethod.defaultIM) {
            await this.switchToIM(this.savedIMKey);
        }
    }
    async switchToIM(imKey) {
        let switchIMCmd = configuration_1.configuration.autoSwitchInputMethod.switchIMCmd;
        if (imKey !== '' && imKey !== undefined) {
            switchIMCmd = switchIMCmd.replace('{im}', imKey);
            try {
                await this.execute(switchIMCmd);
            }
            catch (e) {
                this.logger.error(`Error switching to IM. err=${e}`);
            }
        }
    }
    isInsertLikeMode(mode) {
        return [mode_1.Mode.Insert, mode_1.Mode.Replace, mode_1.Mode.SurroundInputMode].includes(mode);
    }
}
exports.InputMethodSwitcher = InputMethodSwitcher;

//# sourceMappingURL=imswitcher.js.map
