"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const jumpTracker_1 = require("../jumps/jumpTracker");
const mode_1 = require("../mode/mode");
const position_1 = require("../common/motion/position");
const historyFile_1 = require("../history/historyFile");
const searchState_1 = require("./searchState");
const configuration_1 = require("../configuration/configuration");
/**
 * State which stores global state (across editors)
 */
class GlobalState {
    constructor() {
        /**
         * Previous searches performed
         */
        this._searchStatePrevious = [];
        /**
         * Track jumps, and traverse jump history
         */
        this.jumpTracker = new jumpTracker_1.JumpTracker();
        /**
         * Tracks search history
         */
        this._searchHistory = new historyFile_1.SearchHistory();
        /**
         * The keystroke sequence that made up our last complete action (that can be
         * repeated with '.').
         */
        this.previousFullAction = undefined;
        /**
         * Last substitute state for running :s by itself
         */
        this.substituteState = undefined;
        /**
         * Last search state for running n and N commands
         */
        this.searchState = undefined;
        /**
         *  Index used for navigating search history with <up> and <down> when searching
         */
        this.searchStateIndex = 0;
        /**
         * Used internally for nohl.
         */
        this.hl = true;
    }
    async load() {
        await this._searchHistory.load();
        this._searchHistory
            .get()
            .forEach((val) => this.searchStatePrevious.push(new searchState_1.SearchState(searchState_1.SearchDirection.Forward, new position_1.Position(0, 0), val, undefined, mode_1.Mode.Normal)));
    }
    /**
     * Getters and setters for changing global state
     */
    get searchStatePrevious() {
        return this._searchStatePrevious;
    }
    set searchStatePrevious(states) {
        this._searchStatePrevious = this._searchStatePrevious.concat(states);
    }
    async addSearchStateToHistory(searchState) {
        const prevSearchString = this.searchStatePrevious.length === 0
            ? undefined
            : this.searchStatePrevious[this.searchStatePrevious.length - 1].searchString;
        // Store this search if different than previous
        if (searchState.searchString !== prevSearchString) {
            this.searchStatePrevious.push(searchState);
            if (this._searchHistory !== undefined) {
                await this._searchHistory.add(searchState.searchString);
            }
        }
        // Make sure search history does not exceed configuration option
        if (this.searchStatePrevious.length > configuration_1.configuration.history) {
            this.searchStatePrevious.splice(0, 1);
        }
        // Update the index to the end of the search history
        this.searchStateIndex = this.searchStatePrevious.length - 1;
    }
    /**
     * Shows the search history as a QuickPick (popup list)
     *
     * @returns The SearchState that was selected by the user, if there was one.
     */
    async showSearchHistory() {
        if (!vscode.window.activeTextEditor) {
            return undefined;
        }
        const items = this._searchStatePrevious
            .slice()
            .reverse()
            .map((searchState) => {
            return {
                label: searchState.searchString,
                searchState: searchState,
            };
        });
        const item = await vscode.window.showQuickPick(items, {
            placeHolder: 'Vim search history',
            ignoreFocusOut: false,
        });
        return item ? item.searchState : undefined;
    }
}
exports.globalState = new GlobalState();

//# sourceMappingURL=globalState.js.map