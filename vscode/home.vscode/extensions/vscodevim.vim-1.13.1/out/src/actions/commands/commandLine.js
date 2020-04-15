"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
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
const vscode = require("vscode");
const base_1 = require("../base");
const actions_1 = require("./actions");
const mode_1 = require("../../mode/mode");
const commandLine_1 = require("../../cmd_line/commandLine");
const globalState_1 = require("../../state/globalState");
const register_1 = require("../../register/register");
const statusBarTextUtils_1 = require("../../util/statusBarTextUtils");
const recordedState_1 = require("../../state/recordedState");
const textEditor_1 = require("../../textEditor");
const statusBar_1 = require("../../statusBar");
const subparser_1 = require("../../cmd_line/subparser");
const path_1 = require("../../util/path");
const clipboard_1 = require("../../util/clipboard");
const position_1 = require("../../common/motion/position");
const error_1 = require("../../error");
const searchState_1 = require("../../state/searchState");
const util_1 = require("../../util/util");
/**
 * Commands that are only relevant when entering a command or search
 */
// TODO: Much of the code in this file is duplicated.
//       We need an interface to the status bar which can be used by both modes.
// Command tab backward from behind shift tab
let CommandTabInCommandline = class CommandTabInCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = [['<tab>'], ['<shift+tab>']];
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    cycleCompletion(vimState, isTabForward) {
        const autoCompleteItems = commandLine_1.commandLine.autoCompleteItems;
        if (autoCompleteItems.length === 0) {
            return;
        }
        commandLine_1.commandLine.autoCompleteIndex = isTabForward
            ? (commandLine_1.commandLine.autoCompleteIndex + 1) % autoCompleteItems.length
            : (commandLine_1.commandLine.autoCompleteIndex - 1 + autoCompleteItems.length) % autoCompleteItems.length;
        const lastPos = commandLine_1.commandLine.preCompleteCharacterPos;
        const lastCmd = commandLine_1.commandLine.preCompleteCommand;
        const evalCmd = lastCmd.slice(0, lastPos);
        const restCmd = lastCmd.slice(lastPos);
        vimState.currentCommandlineText =
            evalCmd + autoCompleteItems[commandLine_1.commandLine.autoCompleteIndex] + restCmd;
        vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length - restCmd.length;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            const isTabForward = key === '<tab>';
            if (commandLine_1.commandLine.autoCompleteItems.length !== 0 &&
                this.keys.some(k => commandLine_1.commandLine.lastKeyPressed === k[0])) {
                this.cycleCompletion(vimState, isTabForward);
                commandLine_1.commandLine.lastKeyPressed = key;
                return vimState;
            }
            let newCompletionItems = [];
            const currentCmd = vimState.currentCommandlineText;
            const cursorPos = vimState.statusBarCursorCharacterPos;
            // Sub string since vim does completion before the cursor
            let evalCmd = currentCmd.slice(0, cursorPos);
            let restCmd = currentCmd.slice(cursorPos);
            // \s* is the match the extra space before any character like ':  edit'
            const cmdRegex = /^\s*\w+$/;
            const fileRegex = /^\s*\w+\s+/g;
            if (cmdRegex.test(evalCmd)) {
                // Command completion
                newCompletionItems = Object.keys(subparser_1.commandParsers)
                    .filter(cmd => cmd.startsWith(evalCmd))
                    // Remove the already typed portion in the array
                    .map(cmd => cmd.slice(cmd.search(evalCmd) + evalCmd.length))
                    .sort();
            }
            else if (fileRegex.exec(evalCmd)) {
                // File completion by searching if there is a space after the first word/command
                // ideally it should be a process of white-listing to selected commands like :e and :vsp
                let filePathInCmd = evalCmd.substring(fileRegex.lastIndex);
                const currentUri = vscode.window.activeTextEditor.document.uri;
                const isRemote = !!vscode.env.remoteName;
                const { fullDirPath, baseName, partialPath, path: p } = path_1.getPathDetails(filePathInCmd, currentUri, isRemote);
                // Update the evalCmd in case of windows, where we change / to \
                evalCmd = evalCmd.slice(0, fileRegex.lastIndex) + partialPath;
                // test if the baseName is . or ..
                const shouldAddDotItems = /^\.\.?$/g.test(baseName);
                const dirItems = yield path_1.readDirectory(fullDirPath, p.sep, currentUri, isRemote, shouldAddDotItems);
                newCompletionItems = dirItems
                    .filter(name => name.startsWith(baseName))
                    .map(name => name.slice(name.search(baseName) + baseName.length))
                    .sort();
            }
            const newIndex = isTabForward ? 0 : newCompletionItems.length - 1;
            commandLine_1.commandLine.autoCompleteIndex = newIndex;
            // If here only one items we fill cmd direct, so the next tab will not cycle the one item array
            commandLine_1.commandLine.autoCompleteItems = newCompletionItems.length <= 1 ? [] : newCompletionItems;
            commandLine_1.commandLine.preCompleteCharacterPos = cursorPos;
            commandLine_1.commandLine.preCompleteCommand = evalCmd + restCmd;
            const completion = newCompletionItems.length === 0 ? '' : newCompletionItems[newIndex];
            vimState.currentCommandlineText = evalCmd + completion + restCmd;
            vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length - restCmd.length;
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandTabInCommandline = __decorate([
    base_1.RegisterAction
], CommandTabInCommandline);
let CommandEnterInCommandline = class CommandEnterInCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = [['\n'], ['<C-m>']];
        this.mightChangeDocument = true;
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            yield commandLine_1.commandLine.Run(vimState.currentCommandlineText.trim(), vimState);
            yield vimState.setCurrentMode(mode_1.Mode.Normal);
            return vimState;
        });
    }
};
CommandEnterInCommandline = __decorate([
    base_1.RegisterAction
], CommandEnterInCommandline);
let CommandInsertInCommandline = 
// TODO: break up
class CommandInsertInCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = [
            ['<character>'],
            ['<up>'],
            ['<down>'],
            ['<C-b>'],
            ['<C-e>'],
            ['<C-h>'],
            ['<C-p>'],
            ['<C-n>'],
            ['<C-f>'],
            ['<C-u>'],
            ['<Home>'],
            ['<End>'],
            ['<Del>'],
        ];
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            // handle special keys first
            if (key === '<BS>' || key === '<shift+BS>' || key === '<C-h>') {
                if (vimState.statusBarCursorCharacterPos === 0) {
                    yield vimState.setCurrentMode(mode_1.Mode.Normal);
                    return vimState;
                }
                vimState.currentCommandlineText =
                    vimState.currentCommandlineText.slice(0, vimState.statusBarCursorCharacterPos - 1) +
                        vimState.currentCommandlineText.slice(vimState.statusBarCursorCharacterPos);
                vimState.statusBarCursorCharacterPos = Math.max(vimState.statusBarCursorCharacterPos - 1, 0);
            }
            else if (key === '<C-f>') {
                new actions_1.CommandShowCommandHistory().exec(position, vimState);
            }
            else if (key === '<C-u>') {
                vimState.currentCommandlineText = vimState.currentCommandlineText.slice(vimState.statusBarCursorCharacterPos);
                vimState.statusBarCursorCharacterPos = 0;
            }
            else if (key === '<Del>') {
                vimState.currentCommandlineText =
                    vimState.currentCommandlineText.slice(0, vimState.statusBarCursorCharacterPos) +
                        vimState.currentCommandlineText.slice(vimState.statusBarCursorCharacterPos + 1);
            }
            else if (key === '<Home>' || key === '<C-b>') {
                vimState.statusBarCursorCharacterPos = 0;
            }
            else if (key === '<End>' || key === '<C-e>') {
                vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length;
            }
            else if (key === '<up>' || key === '<C-p>') {
                commandLine_1.commandLine.commandlineHistoryIndex -= 1;
                // Clamp the history index to stay within bounds of command history length
                commandLine_1.commandLine.commandlineHistoryIndex = Math.max(commandLine_1.commandLine.commandlineHistoryIndex, 0);
                if (commandLine_1.commandLine.historyEntries[commandLine_1.commandLine.commandlineHistoryIndex] !== undefined) {
                    vimState.currentCommandlineText =
                        commandLine_1.commandLine.historyEntries[commandLine_1.commandLine.commandlineHistoryIndex];
                }
                vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length;
            }
            else if (key === '<down>' || key === '<C-n>') {
                commandLine_1.commandLine.commandlineHistoryIndex += 1;
                // If past the first history item, allow user to enter their own new command string (not using history)
                if (commandLine_1.commandLine.commandlineHistoryIndex > commandLine_1.commandLine.historyEntries.length - 1) {
                    if (commandLine_1.commandLine.previousMode === mode_1.Mode.Normal) {
                        vimState.currentCommandlineText = '';
                    }
                    else {
                        vimState.currentCommandlineText = "'<,'>";
                    }
                    commandLine_1.commandLine.commandlineHistoryIndex = commandLine_1.commandLine.historyEntries.length;
                    vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length;
                    return vimState;
                }
                if (commandLine_1.commandLine.historyEntries[commandLine_1.commandLine.commandlineHistoryIndex] !== undefined) {
                    vimState.currentCommandlineText =
                        commandLine_1.commandLine.historyEntries[commandLine_1.commandLine.commandlineHistoryIndex];
                }
                vimState.statusBarCursorCharacterPos = vimState.currentCommandlineText.length;
            }
            else {
                let modifiedString = vimState.currentCommandlineText.split('');
                modifiedString.splice(vimState.statusBarCursorCharacterPos, 0, key);
                vimState.currentCommandlineText = modifiedString.join('');
                vimState.statusBarCursorCharacterPos += key.length;
            }
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandInsertInCommandline = __decorate([
    base_1.RegisterAction
    // TODO: break up
], CommandInsertInCommandline);
let CommandInsertInSearchMode = 
// TODO: break up
class CommandInsertInSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.SearchInProgressMode];
        this.keys = [
            ['<character>'],
            ['<up>'],
            ['<down>'],
            ['<C-b>'],
            ['<C-e>'],
            ['<C-h>'],
            ['<C-p>'],
            ['<C-n>'],
            ['<C-f>'],
            ['<C-u>'],
            ['<C-m>'],
            ['<Home>'],
            ['<End>'],
            ['<Del>'],
        ];
        this.isJump = true;
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            const searchState = globalState_1.globalState.searchState;
            const prevSearchList = globalState_1.globalState.searchStatePrevious;
            // handle special keys first
            if (key === '<BS>' || key === '<shift+BS>' || key === '<C-h>') {
                if (searchState.searchString.length === 0) {
                    return new CommandEscInSearchMode().exec(position, vimState);
                }
                if (vimState.statusBarCursorCharacterPos === 0) {
                    return vimState;
                }
                searchState.searchString =
                    searchState.searchString.slice(0, vimState.statusBarCursorCharacterPos - 1) +
                        searchState.searchString.slice(vimState.statusBarCursorCharacterPos);
                vimState.statusBarCursorCharacterPos = Math.max(vimState.statusBarCursorCharacterPos - 1, 0);
            }
            else if (key === '<C-f>') {
                return new actions_1.CommandShowSearchHistory(globalState_1.globalState.searchState.searchDirection).exec(position, vimState);
            }
            else if (key === '<C-u>') {
                searchState.searchString = searchState.searchString.slice(vimState.statusBarCursorCharacterPos);
                vimState.statusBarCursorCharacterPos = 0;
            }
            else if (key === '<Del>') {
                searchState.searchString =
                    searchState.searchString.slice(0, vimState.statusBarCursorCharacterPos) +
                        searchState.searchString.slice(vimState.statusBarCursorCharacterPos + 1);
            }
            else if (key === '<Home>' || key === '<C-b>') {
                vimState.statusBarCursorCharacterPos = 0;
            }
            else if (key === '<End>' || key === '<C-e>') {
                vimState.statusBarCursorCharacterPos = globalState_1.globalState.searchState.searchString.length;
            }
            else if (key === '\n' || key === '<C-m>') {
                yield vimState.setCurrentMode(globalState_1.globalState.searchState.previousMode);
                // Repeat the previous search if no new string is entered
                if (searchState.searchString === '') {
                    if (prevSearchList.length > 0) {
                        searchState.searchString = prevSearchList[prevSearchList.length - 1].searchString;
                    }
                }
                vimState.statusBarCursorCharacterPos = 0;
                register_1.Register.putByKey(searchState.searchString, '/', undefined, true);
                globalState_1.globalState.addSearchStateToHistory(searchState);
                if (searchState.matchRanges.length === 0) {
                    statusBar_1.StatusBar.displayError(vimState, error_1.VimError.fromCode(error_1.ErrorCode.PatternNotFound, searchState.searchString));
                    return vimState;
                }
                // Move cursor to next match
                const nextMatch = searchState.getNextSearchMatchPosition(vimState.cursorStopPosition);
                if (nextMatch === undefined) {
                    statusBar_1.StatusBar.displayError(vimState, error_1.VimError.fromCode(searchState.searchDirection === searchState_1.SearchDirection.Backward
                        ? error_1.ErrorCode.SearchHitTop
                        : error_1.ErrorCode.SearchHitBottom));
                    return vimState;
                }
                vimState.cursorStopPosition = nextMatch.pos;
                globalState_1.globalState.hl = true;
                statusBarTextUtils_1.reportSearch(nextMatch.index, searchState.matchRanges.length, vimState);
                return vimState;
            }
            else if (key === '<up>' || key === '<C-p>') {
                globalState_1.globalState.searchStateIndex -= 1;
                // Clamp the history index to stay within bounds of search history length
                globalState_1.globalState.searchStateIndex = Math.max(globalState_1.globalState.searchStateIndex, 0);
                if (prevSearchList[globalState_1.globalState.searchStateIndex] !== undefined) {
                    searchState.searchString = prevSearchList[globalState_1.globalState.searchStateIndex].searchString;
                    vimState.statusBarCursorCharacterPos = searchState.searchString.length;
                }
            }
            else if (key === '<down>' || key === '<C-n>') {
                globalState_1.globalState.searchStateIndex += 1;
                // If past the first history item, allow user to enter their own search string (not using history)
                if (globalState_1.globalState.searchStateIndex > globalState_1.globalState.searchStatePrevious.length - 1) {
                    searchState.searchString = '';
                    globalState_1.globalState.searchStateIndex = globalState_1.globalState.searchStatePrevious.length;
                    return vimState;
                }
                if (prevSearchList[globalState_1.globalState.searchStateIndex] !== undefined) {
                    searchState.searchString = prevSearchList[globalState_1.globalState.searchStateIndex].searchString;
                }
                vimState.statusBarCursorCharacterPos = searchState.searchString.length;
            }
            else {
                let modifiedString = searchState.searchString.split('');
                modifiedString.splice(vimState.statusBarCursorCharacterPos, 0, key);
                searchState.searchString = modifiedString.join('');
                vimState.statusBarCursorCharacterPos += key.length;
            }
            return vimState;
        });
    }
};
CommandInsertInSearchMode = __decorate([
    base_1.RegisterAction
    // TODO: break up
], CommandInsertInSearchMode);
let CommandEscInCommandline = class CommandEscInCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = [['<Esc>'], ['<C-c>'], ['<C-[>']];
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            yield vimState.setCurrentMode(mode_1.Mode.Normal);
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandEscInCommandline = __decorate([
    base_1.RegisterAction
], CommandEscInCommandline);
let CommandEscInSearchMode = class CommandEscInSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.SearchInProgressMode];
        this.keys = [['<Esc>'], ['<C-c>'], ['<C-[>']];
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const searchState = globalState_1.globalState.searchState;
            vimState.cursorStopPosition = searchState.searchCursorStartPosition;
            const prevSearchList = globalState_1.globalState.searchStatePrevious;
            globalState_1.globalState.searchState = prevSearchList
                ? prevSearchList[prevSearchList.length - 1]
                : undefined;
            if (vimState.firstVisibleLineBeforeSearch !== undefined) {
                const offset = vimState.editor.visibleRanges[0].start.line - vimState.firstVisibleLineBeforeSearch;
                util_1.scrollView(vimState, offset);
            }
            yield vimState.setCurrentMode(searchState.previousMode);
            vimState.statusBarCursorCharacterPos = 0;
            globalState_1.globalState.addSearchStateToHistory(searchState);
            return vimState;
        });
    }
};
CommandEscInSearchMode = __decorate([
    base_1.RegisterAction
], CommandEscInSearchMode);
let CommandRemoveWordCommandline = class CommandRemoveWordCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = ['<C-w>'];
    }
    runsOnceForEveryCursor() {
        return false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            const pos = vimState.statusBarCursorCharacterPos;
            const cmdText = vimState.currentCommandlineText;
            const characterAt = position_1.Position.getWordLeft(cmdText, pos);
            // Needs explicit check undefined because zero is falsy and zero is a valid character pos.
            if (characterAt !== undefined) {
                vimState.currentCommandlineText = cmdText
                    .substring(0, characterAt)
                    .concat(cmdText.slice(pos));
                vimState.statusBarCursorCharacterPos = pos - (pos - characterAt);
            }
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandRemoveWordCommandline = __decorate([
    base_1.RegisterAction
], CommandRemoveWordCommandline);
let CommandRemoveWordInSearchMode = class CommandRemoveWordInSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.SearchInProgressMode];
        this.keys = ['<C-w>'];
    }
    runsOnceForEveryCursor() {
        return false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const searchState = globalState_1.globalState.searchState;
            const pos = vimState.statusBarCursorCharacterPos;
            const searchString = searchState.searchString;
            const characterAt = position_1.Position.getWordLeft(searchString, pos);
            // Needs explicit check undefined because zero is falsy and zero is a valid character pos.
            if (characterAt !== undefined) {
                searchState.searchString = searchString
                    .substring(0, characterAt)
                    .concat(searchString.slice(pos));
                vimState.statusBarCursorCharacterPos = pos - (pos - characterAt);
            }
            return vimState;
        });
    }
};
CommandRemoveWordInSearchMode = __decorate([
    base_1.RegisterAction
], CommandRemoveWordInSearchMode);
let CommandInsertRegisterContentInCommandLine = class CommandInsertRegisterContentInCommandLine extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = ['<C-r>', '<character>'];
        this.isCompleteAction = false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            vimState.recordedState.registerName = this.keysPressed[1];
            const register = yield register_1.Register.get(vimState);
            let text;
            if (register.text instanceof Array) {
                text = register.text.join('\n');
            }
            else if (register.text instanceof recordedState_1.RecordedState) {
                let keyStrokes = [];
                for (let action of register.text.actionsRun) {
                    keyStrokes = keyStrokes.concat(action.keysPressed);
                }
                text = keyStrokes.join('\n');
            }
            else {
                text = register.text;
            }
            if (register.registerMode === register_1.RegisterMode.LineWise) {
                text += '\n';
            }
            vimState.currentCommandlineText += text;
            vimState.statusBarCursorCharacterPos += text.length;
            return vimState;
        });
    }
};
CommandInsertRegisterContentInCommandLine = __decorate([
    base_1.RegisterAction
], CommandInsertRegisterContentInCommandLine);
let CommandInsertRegisterContentInSearchMode = class CommandInsertRegisterContentInSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.SearchInProgressMode];
        this.keys = ['<C-r>', '<character>'];
        this.isCompleteAction = false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            vimState.recordedState.registerName = this.keysPressed[1];
            const register = yield register_1.Register.get(vimState);
            let text;
            if (register.text instanceof Array) {
                text = register.text.join('\n');
            }
            else if (register.text instanceof recordedState_1.RecordedState) {
                let keyStrokes = [];
                for (let action of register.text.actionsRun) {
                    keyStrokes = keyStrokes.concat(action.keysPressed);
                }
                text = keyStrokes.join('\n');
            }
            else {
                text = register.text;
            }
            if (register.registerMode === register_1.RegisterMode.LineWise) {
                text += '\n';
            }
            const searchState = globalState_1.globalState.searchState;
            searchState.searchString += text;
            vimState.statusBarCursorCharacterPos += text.length;
            return vimState;
        });
    }
};
CommandInsertRegisterContentInSearchMode = __decorate([
    base_1.RegisterAction
], CommandInsertRegisterContentInSearchMode);
let CommandInsertWord = class CommandInsertWord extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress, mode_1.Mode.SearchInProgressMode];
        this.keys = ['<C-r>', '<C-w>'];
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            // Skip forward to next word, not going past EOL
            while (!/[a-zA-Z0-9_]/.test(textEditor_1.TextEditor.getCharAt(position))) {
                position = position.getRight();
            }
            const word = textEditor_1.TextEditor.getWord(position.getLeftIfEOL());
            if (word !== undefined) {
                if (vimState.currentMode === mode_1.Mode.SearchInProgressMode) {
                    const searchState = globalState_1.globalState.searchState;
                    searchState.searchString += word;
                }
                else {
                    vimState.currentCommandlineText += word;
                }
                vimState.statusBarCursorCharacterPos += word.length;
            }
            return vimState;
        });
    }
};
CommandInsertWord = __decorate([
    base_1.RegisterAction
], CommandInsertWord);
let CommandNavigateInCommandlineOrSearchMode = class CommandNavigateInCommandlineOrSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress, mode_1.Mode.SearchInProgressMode];
        this.keys = [['<left>'], ['<right>']];
    }
    runsOnceForEveryCursor() {
        return this.keysPressed[0] === '\n';
    }
    getTrimmedStatusBarText() {
        // first regex removes the : / and | from the string
        // second regex removes a single space from the end of the string
        let trimmedStatusBarText = statusBar_1.StatusBar.getText()
            .replace(/^(?:\/|\:)(.*)(?:\|)(.*)/, '$1$2')
            .replace(/(.*) $/, '$1');
        return trimmedStatusBarText;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            let statusBarText = this.getTrimmedStatusBarText();
            if (key === '<right>') {
                vimState.statusBarCursorCharacterPos = Math.min(vimState.statusBarCursorCharacterPos + 1, statusBarText.length);
            }
            else if (key === '<left>') {
                vimState.statusBarCursorCharacterPos = Math.max(vimState.statusBarCursorCharacterPos - 1, 0);
            }
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandNavigateInCommandlineOrSearchMode = __decorate([
    base_1.RegisterAction
], CommandNavigateInCommandlineOrSearchMode);
let CommandPasteInCommandline = class CommandPasteInCommandline extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.CommandlineInProgress];
        this.keys = [['<C-v>'], ['<D-v>']];
    }
    runsOnceForEveryCursor() {
        return false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const key = this.keysPressed[0];
            const pos = vimState.statusBarCursorCharacterPos;
            const cmdText = vimState.currentCommandlineText;
            const textFromClipboard = yield clipboard_1.Clipboard.Paste();
            vimState.currentCommandlineText = cmdText
                .substring(0, pos)
                .concat(textFromClipboard)
                .concat(cmdText.slice(pos));
            vimState.statusBarCursorCharacterPos += textFromClipboard.length;
            commandLine_1.commandLine.lastKeyPressed = key;
            return vimState;
        });
    }
};
CommandPasteInCommandline = __decorate([
    base_1.RegisterAction
], CommandPasteInCommandline);
let CommandPasteInSearchMode = class CommandPasteInSearchMode extends actions_1.BaseCommand {
    constructor() {
        super(...arguments);
        this.modes = [mode_1.Mode.SearchInProgressMode];
        this.keys = [['<C-v>'], ['<D-v>']];
    }
    runsOnceForEveryCursor() {
        return false;
    }
    exec(position, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            const searchState = globalState_1.globalState.searchState;
            const searchString = searchState.searchString;
            const pos = vimState.statusBarCursorCharacterPos;
            const textFromClipboard = yield clipboard_1.Clipboard.Paste();
            searchState.searchString = searchString
                .substring(0, pos)
                .concat(textFromClipboard)
                .concat(searchString.slice(pos));
            vimState.statusBarCursorCharacterPos += textFromClipboard.length;
            return vimState;
        });
    }
};
CommandPasteInSearchMode = __decorate([
    base_1.RegisterAction
], CommandPasteInSearchMode);

//# sourceMappingURL=commandLine.js.map
