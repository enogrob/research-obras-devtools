"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const base_1 = require("./../actions/base");
const baseMotion_1 = require("../actions/baseMotion");
const insert_1 = require("./../actions/commands/insert");
const jump_1 = require("../jumps/jump");
const logger_1 = require("../util/logger");
const mode_1 = require("./mode");
const matcher_1 = require("./../common/matching/matcher");
const position_1 = require("./../common/motion/position");
const range_1 = require("./../common/motion/range");
const recordedState_1 = require("./../state/recordedState");
const register_1 = require("./../register/register");
const remapper_1 = require("../configuration/remapper");
const statusBar_1 = require("../statusBar");
const textEditor_1 = require("./../textEditor");
const error_1 = require("./../error");
const vimState_1 = require("./../state/vimState");
const vscode_context_1 = require("../util/vscode-context");
const commandLine_1 = require("../cmd_line/commandLine");
const configuration_1 = require("../configuration/configuration");
const decoration_1 = require("../configuration/decoration");
const util_1 = require("../util/util");
const actions_1 = require("./../actions/commands/actions");
const transformations_1 = require("./../transformations/transformations");
const globalState_1 = require("../state/globalState");
const statusBarTextUtils_1 = require("../util/statusBarTextUtils");
const notation_1 = require("../configuration/notation");
/**
 * ModeHandler is the extension's backbone. It listens to events and updates the VimState.
 * One of these exists for each editor - see ModeHandlerMap
 *
 * See:  https://github.com/VSCodeVim/Vim/blob/master/.github/CONTRIBUTING.md#the-vim-state-machine
 */
class ModeHandler {
    constructor(textEditor) {
        this._disposables = [];
        this._logger = logger_1.Logger.get('ModeHandler');
        this._remappers = new remapper_1.Remappers();
        this.vimState = new vimState_1.VimState(textEditor);
        this._disposables.push(this.vimState);
    }
    get currentMode() {
        return this._currentMode;
    }
    async setCurrentMode(modeName) {
        await this.vimState.setCurrentMode(modeName);
        this._currentMode = modeName;
    }
    static async create(textEditor = vscode.window.activeTextEditor) {
        const modeHandler = new ModeHandler(textEditor);
        await modeHandler.setCurrentMode(configuration_1.configuration.startInInsertMode ? mode_1.Mode.Insert : mode_1.Mode.Normal);
        modeHandler.syncCursors();
        return modeHandler;
    }
    /**
     * Syncs cursors between VSCode representation and vim representation
     */
    syncCursors() {
        setImmediate(() => {
            if (this.vimState.editor) {
                this.vimState.cursors = this.vimState.editor.selections.map(({ start, end }) => new range_1.Range(position_1.Position.FromVSCodePosition(start), position_1.Position.FromVSCodePosition(end)));
                this.vimState.cursorStartPosition = position_1.Position.FromVSCodePosition(this.vimState.editor.selection.start);
                this.vimState.cursorStopPosition = position_1.Position.FromVSCodePosition(
                // TODO: why are we doing this? If this should be stop, it's redundant; if it shouldn't be, it needs to be explained
                this.vimState.editor.selection.start);
                this.vimState.desiredColumn = this.vimState.cursorStopPosition.character;
            }
        }, 0);
    }
    /**
     * This is easily the worst function in VSCodeVim.
     *
     * We need to know when VSCode has updated our selection, so that we can sync
     * that internally. Unfortunately, VSCode has a habit of calling this
     * function at weird times, or or with incomplete information, so we have to
     * do a lot of voodoo to make sure we're updating the cursors correctly.
     *
     * Even worse, we don't even know how to test this stuff.
     *
     * Anyone who wants to change the behavior of this method should make sure
     * all selection related test cases pass. Follow this spec
     * https://gist.github.com/rebornix/d21d1cc060c009d4430d3904030bd4c1 to
     * perform the manual testing.
     */
    async handleSelectionChange(e) {
        let selection = e.selections[0];
        if ((e.selections.length !== this.vimState.cursors.length || this.vimState.isMultiCursor) &&
            this.vimState.currentMode !== mode_1.Mode.VisualBlock) {
            // Number of selections changed, make sure we know about all of them still
            this.vimState.cursors = e.textEditor.selections.map((sel) => new range_1.Range(
            // Adjust the cursor positions because cursors & selections don't match exactly
            sel.anchor.isAfter(sel.active)
                ? position_1.Position.FromVSCodePosition(sel.anchor).getLeft()
                : position_1.Position.FromVSCodePosition(sel.anchor), position_1.Position.FromVSCodePosition(sel.active)));
            return this.updateView(this.vimState);
        }
        /**
         * We only trigger our view updating process if it's a mouse selection.
         * Otherwise we only update our internal cursor positions accordingly.
         */
        if (e.kind !== vscode.TextEditorSelectionChangeKind.Mouse) {
            if (selection) {
                if (mode_1.isVisualMode(this.vimState.currentMode)) {
                    /**
                     * In Visual Mode, our `cursorPosition` and `cursorStartPosition` can not reflect `active`,
                     * `start`, `end` and `anchor` information in a selection.
                     * See `Fake block cursor with text decoration` section of `updateView` method.
                     */
                    return;
                }
                this.vimState.cursorStopPosition = position_1.Position.FromVSCodePosition(selection.active);
                this.vimState.cursorStartPosition = position_1.Position.FromVSCodePosition(selection.start);
            }
            return;
        }
        if (e.selections.length === 1) {
            this.vimState.isMultiCursor = false;
        }
        if (mode_1.isStatusBarMode(this.vimState.currentMode)) {
            return;
        }
        let toDraw = false;
        if (selection) {
            let newPosition = position_1.Position.FromVSCodePosition(selection.active);
            // Only check on a click, not a full selection (to prevent clicking past EOL)
            if (newPosition.character >= newPosition.getLineEnd().character && selection.isEmpty) {
                if (this.vimState.currentMode !== mode_1.Mode.Insert) {
                    this.vimState.lastClickWasPastEol = true;
                    // This prevents you from mouse clicking past the EOL
                    newPosition = newPosition.withColumn(Math.max(newPosition.getLineEnd().character - 1, 0));
                    // Switch back to normal mode since it was a click not a selection
                    await this.setCurrentMode(mode_1.Mode.Normal);
                    toDraw = true;
                }
            }
            else if (selection.isEmpty) {
                this.vimState.lastClickWasPastEol = false;
            }
            this.vimState.cursorStopPosition = newPosition;
            this.vimState.cursorStartPosition = newPosition;
            this.vimState.desiredColumn = newPosition.character;
            // start visual mode?
            if (selection.anchor.line === selection.active.line &&
                selection.anchor.character >= newPosition.getLineEnd().character - 1 &&
                selection.active.character >= newPosition.getLineEnd().character - 1) {
                // This prevents you from selecting EOL
            }
            else if (!selection.anchor.isEqual(selection.active)) {
                let selectionStart = new position_1.Position(selection.anchor.line, selection.anchor.character);
                if (selectionStart.character > selectionStart.getLineEnd().character) {
                    selectionStart = new position_1.Position(selectionStart.line, selectionStart.getLineEnd().character);
                }
                this.vimState.cursorStartPosition = selectionStart;
                if (selectionStart.isAfter(newPosition)) {
                    this.vimState.cursorStartPosition = this.vimState.cursorStartPosition.getLeft();
                }
                // If we prevented from clicking past eol but it is part of this selection, include the last char
                if (this.vimState.lastClickWasPastEol) {
                    const newStart = new position_1.Position(selection.anchor.line, selection.anchor.character + 1);
                    this.vimState.editor.selection = new vscode.Selection(newStart, selection.end);
                    this.vimState.cursorStartPosition = selectionStart;
                    this.vimState.lastClickWasPastEol = false;
                }
                if (configuration_1.configuration.mouseSelectionGoesIntoVisualMode &&
                    !mode_1.isVisualMode(this.vimState.currentMode) &&
                    this.currentMode !== mode_1.Mode.Insert) {
                    await this.setCurrentMode(mode_1.Mode.Visual);
                    // double click mouse selection causes an extra character to be selected so take one less character
                }
            }
            else if (this.vimState.currentMode !== mode_1.Mode.Insert) {
                await this.setCurrentMode(mode_1.Mode.Normal);
            }
            return this.updateView(this.vimState, { drawSelection: toDraw, revealRange: false });
        }
    }
    async handleMultipleKeyEvents(keys) {
        for (const key of keys) {
            await this.handleKeyEvent(key);
        }
    }
    async handleKeyEvent(key) {
        const now = Number(new Date());
        const printableKey = notation_1.Notation.printableKey(key);
        this._logger.debug(`handling key=${printableKey}.`);
        // rewrite copy
        if (configuration_1.configuration.overrideCopy) {
            // The conditions when you trigger a "copy" rather than a ctrl-c are
            // too sophisticated to be covered by the "when" condition in package.json
            if (key === '<D-c>') {
                key = '<copy>';
            }
            if (key === '<C-c>' && process.platform !== 'darwin') {
                if (!configuration_1.configuration.useCtrlKeys ||
                    this.vimState.currentMode === mode_1.Mode.Visual ||
                    this.vimState.currentMode === mode_1.Mode.VisualBlock ||
                    this.vimState.currentMode === mode_1.Mode.VisualLine) {
                    key = '<copy>';
                }
            }
        }
        // <C-d> triggers "add selection to next find match" by default,
        // unless users explicity make <C-d>: true
        if (key === '<C-d>' && !(configuration_1.configuration.handleKeys['<C-d>'] === true)) {
            key = '<D-d>';
        }
        this.vimState.cursorsInitialState = this.vimState.cursors;
        this.vimState.recordedState.commandList.push(key);
        const oldMode = this.vimState.currentMode;
        const oldVisibleRange = this.vimState.editor.visibleRanges[0];
        const oldStatusBarText = statusBar_1.StatusBar.getText();
        try {
            const isWithinTimeout = now - this.vimState.lastKeyPressedTimestamp < configuration_1.configuration.timeout;
            if (!isWithinTimeout) {
                // sufficient time has elapsed since the prior keypress,
                // only consider the last keypress for remapping
                this.vimState.recordedState.commandList = [
                    this.vimState.recordedState.commandList[this.vimState.recordedState.commandList.length - 1],
                ];
            }
            let handled = false;
            const isOperatorCombination = this.vimState.recordedState.operator;
            // Check for remapped keys if:
            // 1. We are not currently performing a non-recursive remapping
            // 2. We are not in normal mode performing on an operator
            //    Example: ciwjj should be remapped if jj -> <Esc> in insert mode
            //             dd should not remap the second "d", if d -> "_d in normal mode
            if (!this.vimState.isCurrentlyPerformingRemapping &&
                (!isOperatorCombination || this.vimState.currentMode !== mode_1.Mode.Normal)) {
                handled = await this._remappers.sendKey(this.vimState.recordedState.commandList, this, this.vimState);
            }
            if (handled) {
                this.vimState.recordedState.resetCommandList();
            }
            else {
                this.vimState = await this.handleKeyEventHelper(key, this.vimState);
            }
        }
        catch (e) {
            if (e instanceof error_1.VimError) {
                statusBar_1.StatusBar.displayError(this.vimState, e);
            }
            else {
                throw new Error(`Failed to handle key=${key}. ${e.message}`);
            }
        }
        this.vimState.lastKeyPressedTimestamp = now;
        // We don't want to immediately erase any message that resulted from the action just performed
        if (statusBar_1.StatusBar.getText() === oldStatusBarText) {
            // Clear the status bar of high priority messages if the mode has changed or the view has scrolled
            const forceClearStatusBar = (this.vimState.currentMode !== oldMode && this.vimState.currentMode !== mode_1.Mode.Normal) ||
                this.vimState.editor.visibleRanges[0] !== oldVisibleRange;
            statusBar_1.StatusBar.clear(this.vimState, forceClearStatusBar);
        }
        this._logger.debug(`handleKeyEvent('${printableKey}') took ${Number(new Date()) - now}ms`);
    }
    async handleKeyEventHelper(key, vimState) {
        if (vscode.window.activeTextEditor !== this.vimState.editor) {
            this._logger.warn('Current window is not active');
            return this.vimState;
        }
        // Catch any text change not triggered by us (example: tab completion).
        vimState.historyTracker.addChange(this.vimState.cursorsInitialState.map((c) => c.stop));
        vimState.keyHistory.push(key);
        let recordedState = vimState.recordedState;
        recordedState.actionKeys.push(key);
        let result = base_1.Actions.getRelevantAction(recordedState.actionKeys, vimState);
        switch (result) {
            case base_1.KeypressState.NoPossibleMatch:
                if (!this._remappers.isPotentialRemap) {
                    vimState.recordedState = new recordedState_1.RecordedState();
                }
                return vimState;
            case base_1.KeypressState.WaitingOnKeys:
                return vimState;
        }
        let action = result;
        let actionToRecord = action;
        if (recordedState.actionsRun.length === 0) {
            recordedState.actionsRun.push(action);
        }
        else {
            let lastAction = recordedState.actionsRun[recordedState.actionsRun.length - 1];
            if (lastAction instanceof actions_1.DocumentContentChangeAction) {
                lastAction.keysPressed.push(key);
                if (action instanceof insert_1.CommandInsertInInsertMode ||
                    action instanceof insert_1.CommandInsertPreviousText) {
                    // delay the macro recording
                    actionToRecord = undefined;
                }
                else {
                    // Push document content change to the stack
                    lastAction.contentChanges = lastAction.contentChanges.concat(vimState.historyTracker.currentContentChanges.map((diff) => ({
                        textDiff: diff,
                        positionDiff: new position_1.PositionDiff(),
                    })));
                    vimState.historyTracker.currentContentChanges = [];
                    recordedState.actionsRun.push(action);
                }
            }
            else {
                if (action instanceof insert_1.CommandInsertInInsertMode ||
                    action instanceof insert_1.CommandInsertPreviousText) {
                    // This means we are already in Insert Mode but there is still not DocumentContentChangeAction in stack
                    vimState.historyTracker.currentContentChanges = [];
                    let newContentChange = new actions_1.DocumentContentChangeAction();
                    newContentChange.keysPressed.push(key);
                    recordedState.actionsRun.push(newContentChange);
                    actionToRecord = newContentChange;
                }
                else {
                    recordedState.actionsRun.push(action);
                }
            }
        }
        if (vimState.isRecordingMacro &&
            actionToRecord &&
            !(actionToRecord instanceof actions_1.CommandQuitRecordMacro)) {
            vimState.recordedMacro.actionsRun.push(actionToRecord);
        }
        vimState = await this.runAction(vimState, recordedState, action);
        if (vimState.currentMode === mode_1.Mode.Insert) {
            recordedState.isInsertion = true;
        }
        // Update view
        await this.updateView(vimState);
        if (action.isJump) {
            globalState_1.globalState.jumpTracker.recordJump(jump_1.Jump.fromStateBefore(vimState), jump_1.Jump.fromStateNow(vimState));
        }
        if (!this._remappers.isPotentialRemap && recordedState.isInsertion) {
            vimState.recordedState.resetCommandList();
        }
        return vimState;
    }
    async runAction(vimState, recordedState, action) {
        let ranRepeatableAction = false;
        let ranAction = false;
        // If arrow keys or mouse was used prior to entering characters while in insert mode, create an undo point
        // this needs to happen before any changes are made
        /*
    
        TODO: This causes . to crash vscodevim for some reason.
    
        if (!vimState.isMultiCursor) {
          let prevPos = vimState.historyTracker.getLastHistoryEndPosition();
          if (prevPos !== undefined && !vimState.isRunningDotCommand) {
            if (vimState.cursorPositionJustBeforeAnythingHappened[0].line !== prevPos[0].line ||
              vimState.cursorPositionJustBeforeAnythingHappened[0].character !== prevPos[0].character) {
              globalState.previousFullAction = recordedState;
              vimState.historyTracker.finishCurrentStep();
            }
          }
        }
        */
        if (vimState.currentMode === mode_1.Mode.Visual) {
            vimState.cursors = vimState.cursors.map((c) => c.start.isBefore(c.stop) ? c.withNewStop(c.stop.getLeftThroughLineBreaks(true)) : c);
        }
        if (action instanceof baseMotion_1.BaseMovement) {
            ({ vimState, recordedState } = await this.executeMovement(vimState, action));
            ranAction = true;
        }
        if (action instanceof actions_1.BaseCommand) {
            vimState = await action.execCount(vimState.cursorStopPosition, vimState);
            vimState = await this.executeCommand(vimState);
            if (action.isCompleteAction) {
                ranAction = true;
            }
            if (action.canBeRepeatedWithDot) {
                ranRepeatableAction = true;
            }
        }
        if (action instanceof actions_1.DocumentContentChangeAction) {
            vimState = await action.exec(vimState.cursorStopPosition, vimState);
        }
        // Update mode (note the ordering allows you to go into search mode,
        // then return and have the motion immediately applied to an operator).
        const prevMode = this.currentMode;
        if (vimState.currentMode !== this.currentMode) {
            await this.setCurrentMode(vimState.currentMode);
            // We don't want to mark any searches as a repeatable action
            if (vimState.currentMode === mode_1.Mode.Normal &&
                prevMode !== mode_1.Mode.SearchInProgressMode &&
                prevMode !== mode_1.Mode.CommandlineInProgress &&
                prevMode !== mode_1.Mode.EasyMotionInputMode &&
                prevMode !== mode_1.Mode.EasyMotionMode) {
                ranRepeatableAction = true;
            }
        }
        // Set context for overriding cmd-V, this is only done in search entry and
        // commandline modes
        if (mode_1.isStatusBarMode(vimState.currentMode) !== mode_1.isStatusBarMode(prevMode)) {
            await vscode_context_1.VsCodeContext.Set('vim.overrideCmdV', mode_1.isStatusBarMode(vimState.currentMode));
        }
        if (recordedState.operatorReadyToExecute(vimState.currentMode)) {
            if (vimState.recordedState.operator) {
                vimState = await this.executeOperator(vimState);
                vimState.recordedState.hasRunOperator = true;
                ranRepeatableAction = vimState.recordedState.operator.canBeRepeatedWithDot;
                ranAction = true;
            }
        }
        if (vimState.currentMode === mode_1.Mode.Visual) {
            vimState.cursors = vimState.cursors.map((c) => c.start.isBefore(c.stop)
                ? c.withNewStop(c.stop.isLineEnd() ? c.stop.getRightThroughLineBreaks() : c.stop.getRight())
                : c);
        }
        // And then we have to do it again because an operator could
        // have changed it as well. (TODO: do you even decomposition bro)
        if (vimState.currentMode !== this.currentMode) {
            await this.setCurrentMode(vimState.currentMode);
            if (vimState.currentMode === mode_1.Mode.Normal) {
                ranRepeatableAction = true;
            }
        }
        if (ranAction && vimState.currentMode !== mode_1.Mode.Insert) {
            vimState.recordedState.resetCommandList();
        }
        ranRepeatableAction =
            (ranRepeatableAction && vimState.currentMode === mode_1.Mode.Normal) ||
                this.createUndoPointForBrackets(vimState);
        ranAction = ranAction && vimState.currentMode === mode_1.Mode.Normal;
        // Record down previous action and flush temporary state
        if (ranRepeatableAction) {
            globalState_1.globalState.previousFullAction = vimState.recordedState;
            if (recordedState.isInsertion) {
                register_1.Register.putByKey(recordedState, '.', undefined, true);
            }
        }
        // Update desiredColumn
        if (!action.preservesDesiredColumn()) {
            if (action instanceof baseMotion_1.BaseMovement) {
                // We check !operator here because e.g. d$ should NOT set the desired column to EOL.
                if (action.setsDesiredColumnToEOL && !recordedState.operator) {
                    vimState.desiredColumn = Number.POSITIVE_INFINITY;
                }
                else {
                    vimState.desiredColumn = vimState.cursorStopPosition.character;
                }
            }
            else if (vimState.currentMode !== mode_1.Mode.VisualBlock) {
                // TODO: explain why not VisualBlock
                vimState.desiredColumn = vimState.cursorStopPosition.character;
            }
        }
        if (ranAction) {
            vimState.recordedState = new recordedState_1.RecordedState();
            // Return to insert mode after 1 command in this case for <C-o>
            if (vimState.returnToInsertAfterCommand) {
                if (vimState.actionCount > 0) {
                    vimState.actionCount = 0;
                    await this.setCurrentMode(mode_1.Mode.Insert);
                }
                else {
                    vimState.actionCount++;
                }
            }
        }
        // track undo history
        if (!this.vimState.focusChanged) {
            // important to ensure that focus didn't change, otherwise
            // we'll grab the text of the incorrect active window and assume the
            // whole document changed!
            if (this.vimState.alteredHistory) {
                this.vimState.alteredHistory = false;
                vimState.historyTracker.ignoreChange();
            }
            else {
                vimState.historyTracker.addChange(this.vimState.cursorsInitialState.map((c) => c.stop));
            }
        }
        // Don't record an undo point for every action of a macro, only at the very end
        if (ranRepeatableAction && !vimState.isReplayingMacro) {
            vimState.historyTracker.finishCurrentStep();
        }
        recordedState.actionKeys = [];
        vimState.currentRegisterMode = register_1.RegisterMode.AscertainFromCurrentMode;
        if (this.currentMode === mode_1.Mode.Normal) {
            vimState.cursorStartPosition = vimState.cursorStopPosition;
        }
        // Ensure cursors are within bounds
        if (!vimState.editor.document.isClosed && vimState.editor === vscode.window.activeTextEditor) {
            vimState.cursors = vimState.cursors.map((cursor) => {
                // adjust start/stop
                const documentEndPosition = textEditor_1.TextEditor.getDocumentEnd(vimState.editor);
                const documentLineCount = textEditor_1.TextEditor.getLineCount(vimState.editor);
                if (cursor.start.line >= documentLineCount) {
                    cursor = cursor.withNewStart(documentEndPosition);
                }
                if (cursor.stop.line >= documentLineCount) {
                    cursor = cursor.withNewStop(documentEndPosition);
                }
                // adjust column
                if (vimState.currentMode === mode_1.Mode.Normal) {
                    const currentLineLength = textEditor_1.TextEditor.getLineLength(cursor.stop.line);
                    if (currentLineLength > 0) {
                        const lineEndPosition = cursor.start.getLineEnd().getLeftThroughLineBreaks(true);
                        if (cursor.start.character >= currentLineLength) {
                            cursor = cursor.withNewStart(lineEndPosition);
                        }
                        if (cursor.stop.character >= currentLineLength) {
                            cursor = cursor.withNewStop(lineEndPosition);
                        }
                    }
                }
                return cursor;
            });
        }
        // Update the current history step to have the latest cursor position
        vimState.historyTracker.setLastHistoryEndPosition(vimState.cursors.map((c) => c.stop));
        if (mode_1.isVisualMode(this.vimState.currentMode) && !this.vimState.isRunningDotCommand) {
            // Store selection for commands like gv
            this.vimState.lastVisualSelection = {
                mode: this.vimState.currentMode,
                start: this.vimState.cursorStartPosition,
                end: this.vimState.cursorStopPosition,
                visualLineStartColumn: this.vimState.visualLineStartColumn,
            };
        }
        return vimState;
    }
    async executeMovement(vimState, movement) {
        vimState.lastMovementFailed = false;
        let recordedState = vimState.recordedState;
        for (let i = 0; i < vimState.cursors.length; i++) {
            /**
             * Essentially what we're doing here is pretending like the
             * current VimState only has one cursor (the cursor that we just
             * iterated to).
             *
             * We set the cursor position to be equal to the iterated one,
             * and then set it back immediately after we're done.
             *
             * The slightly more complicated logic here allows us to write
             * Action definitions without having to think about multiple
             * cursors in almost all cases.
             */
            const oldCursorPositionStart = vimState.cursorStartPosition;
            const oldCursorPositionStop = vimState.cursorStopPosition;
            vimState.cursorStartPosition = vimState.cursors[i].start;
            let cursorPosition = vimState.cursors[i].stop;
            vimState.cursorStopPosition = cursorPosition;
            const result = await movement.execActionWithCount(cursorPosition, vimState, recordedState.count);
            // We also need to update the specific cursor, in case the cursor position was modified inside
            // the handling functions (e.g. 'it')
            vimState.cursors[i] = new range_1.Range(vimState.cursorStartPosition, vimState.cursorStopPosition);
            vimState.cursorStartPosition = oldCursorPositionStart;
            vimState.cursorStopPosition = oldCursorPositionStop;
            if (result instanceof position_1.Position) {
                vimState.cursors[i] = vimState.cursors[i].withNewStop(result);
                if (!mode_1.isVisualMode(this.currentMode) && !vimState.recordedState.operator) {
                    vimState.cursors[i] = vimState.cursors[i].withNewStart(result);
                }
            }
            else {
                if (result.failed) {
                    vimState.recordedState = new recordedState_1.RecordedState();
                    vimState.lastMovementFailed = true;
                }
                vimState.cursors[i] = new range_1.Range(result.start, result.stop);
                if (result.registerMode) {
                    vimState.currentRegisterMode = result.registerMode;
                }
            }
        }
        vimState.recordedState.count = 0;
        // Keep the cursor within bounds
        if (vimState.currentMode !== mode_1.Mode.Normal || recordedState.operator) {
            let stop = vimState.cursorStopPosition;
            // Vim does this weird thing where it allows you to select and delete
            // the newline character, which it places 1 past the last character
            // in the line. This is why we use > instead of >=.
            if (stop.character > textEditor_1.TextEditor.getLineLength(stop.line)) {
                vimState.cursorStopPosition = stop.getLineEnd();
            }
        }
        return { vimState, recordedState };
    }
    async executeOperator(vimState) {
        let recordedState = vimState.recordedState;
        const operator = recordedState.operator;
        // TODO - if actions were more pure, this would be unnecessary.
        const startingMode = vimState.currentMode;
        const startingRegisterMode = vimState.currentRegisterMode;
        const resultingCursors = [];
        for (let [i, { start, stop }] of vimState.cursors.entries()) {
            operator.multicursorIndex = i;
            if (start.isAfter(stop)) {
                [start, stop] = [stop, start];
            }
            if (!mode_1.isVisualMode(startingMode) && startingRegisterMode !== register_1.RegisterMode.LineWise) {
                stop = stop.getLeftThroughLineBreaks(true);
            }
            if (this.currentMode === mode_1.Mode.VisualLine) {
                start = start.getLineBegin();
                stop = stop.getLineEnd();
                vimState.currentRegisterMode = register_1.RegisterMode.LineWise;
            }
            await vimState.setCurrentMode(startingMode);
            // We run the repeat version of an operator if the last 2 operators are the same.
            if (recordedState.operators.length > 1 &&
                recordedState.operators.reverse()[0].constructor ===
                    recordedState.operators.reverse()[1].constructor) {
                vimState = await operator.runRepeat(vimState, start, recordedState.count);
            }
            else {
                vimState = await operator.run(vimState, start, stop);
            }
            for (const transformation of vimState.recordedState.transformations) {
                if (transformations_1.isTextTransformation(transformation) && transformation.cursorIndex === undefined) {
                    transformation.cursorIndex = operator.multicursorIndex;
                }
            }
            let resultingRange = new range_1.Range(vimState.cursorStartPosition, vimState.cursorStopPosition);
            resultingCursors.push(resultingRange);
        }
        if (vimState.recordedState.transformations.length > 0) {
            vimState = await this.executeCommand(vimState);
        }
        else {
            // Keep track of all cursors (in the case of multi-cursor).
            vimState.cursors = resultingCursors;
            vimState.editor.selections = vimState.cursors.map((cursor) => new vscode.Selection(cursor.start, cursor.stop));
        }
        return vimState;
    }
    async executeCommand(vimState) {
        var _a;
        const transformations = vimState.recordedState.transformations;
        if (transformations.length === 0) {
            return vimState;
        }
        const textTransformations = transformations.filter((x) => transformations_1.isTextTransformation(x));
        const multicursorTextTransformations = transformations.filter((x) => transformations_1.isMultiCursorTextTransformation(x));
        const otherTransformations = transformations.filter((x) => !transformations_1.isTextTransformation(x) && !transformations_1.isMultiCursorTextTransformation(x));
        let accumulatedPositionDifferences = {};
        const doTextEditorEdit = (command, edit) => {
            switch (command.type) {
                case 'insertText':
                    edit.insert(command.position, command.text);
                    break;
                case 'replaceText':
                    edit.replace(new vscode.Selection(command.end, command.start), command.text);
                    break;
                case 'deleteText':
                    let matchRange = matcher_1.PairMatcher.immediateMatchingBracket(command.position);
                    if (matchRange) {
                        edit.delete(matchRange);
                    }
                    edit.delete(new vscode.Range(command.position, command.position.getLeftThroughLineBreaks()));
                    break;
                case 'deleteRange':
                    edit.delete(new vscode.Selection(command.range.start, command.range.stop));
                    break;
                case 'moveCursor':
                    break;
                default:
                    this._logger.warn(`Unhandled text transformation type: ${command.type}.`);
                    break;
            }
            if (command.cursorIndex === undefined) {
                throw new Error('No cursor index - this should never ever happen!');
            }
            if (command.diff) {
                if (!accumulatedPositionDifferences[command.cursorIndex]) {
                    accumulatedPositionDifferences[command.cursorIndex] = [];
                }
                accumulatedPositionDifferences[command.cursorIndex].push(command.diff);
            }
        };
        if (textTransformations.length > 0) {
            if (transformations_1.areAnyTransformationsOverlapping(textTransformations)) {
                this._logger.debug(`Text transformations are overlapping. Falling back to serial
           transformations. This is generally a very bad sign. Try to make
           your text transformations operate on non-overlapping ranges.`);
                // TODO: Select one transformation for every cursor and run them all
                // in parallel. Repeat till there are no more transformations.
                for (const transformation of textTransformations) {
                    await this.vimState.editor.edit((edit) => doTextEditorEdit(transformation, edit));
                }
            }
            else {
                // This is the common case!
                /**
                 * batch all text operations together as a single operation
                 * (this is primarily necessary for multi-cursor mode, since most
                 * actions will trigger at most one text operation).
                 */
                await this.vimState.editor.edit((edit) => {
                    for (const command of textTransformations) {
                        doTextEditorEdit(command, edit);
                    }
                });
            }
        }
        if (multicursorTextTransformations.length > 0) {
            if (transformations_1.areAllSameTransformation(multicursorTextTransformations)) {
                /**
                 * Apply the transformation only once instead of to each cursor
                 * if they are all the same.
                 *
                 * This lets VSCode do multicursor snippets, auto braces and
                 * all the usual jazz VSCode does on text insertion.
                 */
                const { text } = multicursorTextTransformations[0];
                // await vscode.commands.executeCommand('default:type', { text });
                await textEditor_1.TextEditor.insert(text);
            }
            else {
                this._logger.warn(`Unhandled multicursor transformations. Not all transformations are the same!`);
            }
        }
        for (const transformation of otherTransformations) {
            switch (transformation.type) {
                case 'insertTextVSCode':
                    await textEditor_1.TextEditor.insert(transformation.text);
                    vimState.cursors[0] = range_1.Range.FromVSCodeSelection(this.vimState.editor.selection);
                    break;
                case 'showCommandHistory':
                    let cmd = await commandLine_1.commandLine.showHistory(vimState.currentCommandlineText);
                    if (cmd && cmd.length !== 0) {
                        await commandLine_1.commandLine.Run(cmd, this.vimState);
                        this.updateView(this.vimState);
                    }
                    break;
                case 'showSearchHistory':
                    const searchState = await globalState_1.globalState.showSearchHistory();
                    if (searchState) {
                        globalState_1.globalState.searchState = searchState;
                        const nextMatch = searchState.getNextSearchMatchPosition(vimState.cursorStartPosition, transformation.direction);
                        if (!nextMatch) {
                            throw error_1.VimError.fromCode(transformation.direction > 0 ? error_1.ErrorCode.SearchHitBottom : error_1.ErrorCode.SearchHitTop);
                        }
                        vimState.cursorStopPosition = nextMatch.pos;
                        this.updateView(this.vimState);
                        statusBarTextUtils_1.reportSearch(nextMatch.index, searchState.matchRanges.length, vimState);
                    }
                    break;
                case 'dot':
                    if (!globalState_1.globalState.previousFullAction) {
                        return vimState; // TODO(bell)
                    }
                    await this.rerunRecordedState(vimState, globalState_1.globalState.previousFullAction.clone());
                    break;
                case 'macro':
                    let recordedMacro = (await register_1.Register.getByKey(transformation.register))
                        .text;
                    vimState.isReplayingMacro = true;
                    if (transformation.register === ':') {
                        await commandLine_1.commandLine.Run(recordedMacro.commandString, vimState);
                    }
                    else if (transformation.replay === 'contentChange') {
                        vimState = await this.runMacro(vimState, recordedMacro);
                    }
                    else {
                        let keyStrokes = [];
                        for (let action of recordedMacro.actionsRun) {
                            keyStrokes = keyStrokes.concat(action.keysPressed);
                        }
                        this.vimState.recordedState = new recordedState_1.RecordedState();
                        await this.handleMultipleKeyEvents(keyStrokes);
                    }
                    vimState.isReplayingMacro = false;
                    vimState.historyTracker.lastInvokedMacro = recordedMacro;
                    if (vimState.lastMovementFailed) {
                        // movement in last invoked macro failed then we should stop all following repeating macros.
                        // Besides, we should reset `lastMovementFailed`.
                        vimState.lastMovementFailed = false;
                        return vimState;
                    }
                    break;
                case 'contentChange':
                    for (const change of transformation.changes) {
                        await textEditor_1.TextEditor.insert(change.text);
                        vimState.cursorStopPosition = position_1.Position.FromVSCodePosition(this.vimState.editor.selection.start);
                    }
                    const newPos = vimState.cursorStopPosition.add(transformation.diff);
                    this.vimState.editor.selection = new vscode.Selection(newPos, newPos);
                    break;
                case 'tab':
                    await vscode.commands.executeCommand('tab');
                    if (transformation.diff) {
                        if (transformation.cursorIndex === undefined) {
                            throw new Error('No cursor index - this should never ever happen!');
                        }
                        if (!accumulatedPositionDifferences[transformation.cursorIndex]) {
                            accumulatedPositionDifferences[transformation.cursorIndex] = [];
                        }
                        accumulatedPositionDifferences[transformation.cursorIndex].push(transformation.diff);
                    }
                    break;
                case 'reindent':
                    await vscode.commands.executeCommand('editor.action.reindentselectedlines');
                    if (transformation.diff) {
                        if (transformation.cursorIndex === undefined) {
                            throw new Error('No cursor index - this should never ever happen!');
                        }
                        if (!accumulatedPositionDifferences[transformation.cursorIndex]) {
                            accumulatedPositionDifferences[transformation.cursorIndex] = [];
                        }
                        accumulatedPositionDifferences[transformation.cursorIndex].push(transformation.diff);
                    }
                    break;
                default:
                    this._logger.warn(`Unhandled text transformation type: ${transformation.type}.`);
                    break;
            }
        }
        const selections = this.vimState.editor.selections.map((sel) => {
            let range = range_1.Range.FromVSCodeSelection(sel);
            if (range.start.isBefore(range.stop)) {
                range = range.withNewStop(range.stop.getLeftThroughLineBreaks(true));
            }
            return new vscode.Selection(range.start, range.stop);
        });
        const firstTransformation = transformations[0];
        const manuallySetCursorPositions = (firstTransformation.type === 'deleteRange' ||
            firstTransformation.type === 'replaceText' ||
            firstTransformation.type === 'insertText') &&
            firstTransformation.manuallySetCursorPositions;
        // We handle multiple cursors in a different way in visual block mode, unfortunately.
        // TODO - refactor that out!
        if (vimState.currentMode !== mode_1.Mode.VisualBlock && !manuallySetCursorPositions) {
            vimState.cursors = selections.map((sel, idx) => {
                var _a;
                const diffs = (_a = accumulatedPositionDifferences[idx]) !== null && _a !== void 0 ? _a : [];
                if (vimState.recordedState.operatorPositionDiff) {
                    diffs.push(vimState.recordedState.operatorPositionDiff);
                }
                return diffs.reduce((cursor, diff) => new range_1.Range(cursor.start.add(diff), cursor.stop.add(diff)), range_1.Range.FromVSCodeSelection(sel));
            });
            vimState.recordedState.operatorPositionDiff = undefined;
        }
        else if (((_a = accumulatedPositionDifferences[0]) === null || _a === void 0 ? void 0 : _a.length) > 0) {
            const diff = accumulatedPositionDifferences[0][0];
            vimState.cursorStopPosition = vimState.cursorStopPosition.add(diff);
            vimState.cursorStartPosition = vimState.cursorStartPosition.add(diff);
        }
        /**
         * This is a bit of a hack because Visual Block Mode isn't fully on board with
         * the new text transformation style yet.
         *
         * (TODO)
         */
        if (firstTransformation.type === 'deleteRange') {
            if (firstTransformation.collapseRange) {
                vimState.cursorStopPosition = new position_1.Position(vimState.cursorStopPosition.line, vimState.cursorStartPosition.character);
            }
        }
        vimState.recordedState.transformations = [];
        return vimState;
    }
    async rerunRecordedState(vimState, recordedState) {
        const actions = [...recordedState.actionsRun];
        const { hasRunSurround, surroundKeys } = recordedState;
        vimState.isRunningDotCommand = true;
        // If a previous visual selection exists, store it for use in replay of some commands
        if (vimState.lastVisualSelection) {
            vimState.dotCommandPreviousVisualSelection = new vscode.Selection(vimState.lastVisualSelection.start, vimState.lastVisualSelection.end);
        }
        recordedState = new recordedState_1.RecordedState();
        vimState.recordedState = recordedState;
        // Replay surround if applicable, otherwise rerun actions
        if (hasRunSurround) {
            await this.handleMultipleKeyEvents(surroundKeys);
        }
        else {
            for (const [i, action] of actions.entries()) {
                recordedState.actionsRun = actions.slice(0, i + 1);
                vimState = await this.runAction(vimState, recordedState, action);
                if (vimState.lastMovementFailed) {
                    return vimState;
                }
                await this.updateView(vimState);
            }
            recordedState.actionsRun = actions;
        }
        vimState.isRunningDotCommand = false;
        return vimState;
    }
    async runMacro(vimState, recordedMacro) {
        let recordedState = new recordedState_1.RecordedState();
        vimState.recordedState = recordedState;
        vimState.isRunningDotCommand = true;
        for (let action of recordedMacro.actionsRun) {
            let originalLocation = jump_1.Jump.fromStateNow(vimState);
            recordedState.actionsRun.push(action);
            vimState.keyHistory = vimState.keyHistory.concat(action.keysPressed);
            vimState = await this.runAction(vimState, recordedState, action);
            // We just finished a full action; let's clear out our current state.
            if (vimState.recordedState.actionsRun.length === 0) {
                recordedState = new recordedState_1.RecordedState();
                vimState.recordedState = recordedState;
            }
            if (vimState.lastMovementFailed) {
                break;
            }
            await this.updateView(vimState);
            if (action.isJump) {
                globalState_1.globalState.jumpTracker.recordJump(originalLocation, jump_1.Jump.fromStateNow(vimState));
            }
        }
        vimState.isRunningDotCommand = false;
        vimState.cursorsInitialState = vimState.cursors;
        return vimState;
    }
    async updateView(vimState, args = {
        drawSelection: true,
        revealRange: true,
    }) {
        // Draw selection (or cursor)
        if (args.drawSelection &&
            !vimState.recordedState.actionsRun.some((action) => action instanceof actions_1.DocumentContentChangeAction)) {
            let selectionMode = vimState.currentMode;
            if (vimState.currentMode === mode_1.Mode.SearchInProgressMode) {
                selectionMode = globalState_1.globalState.searchState.previousMode;
            }
            else if (vimState.currentMode === mode_1.Mode.CommandlineInProgress) {
                selectionMode = commandLine_1.commandLine.previousMode;
            }
            const selections = [];
            for (const cursor of vimState.cursors) {
                let { start, stop } = cursor;
                switch (selectionMode) {
                    case mode_1.Mode.Visual:
                        /**
                         * Always select the letter that we started visual mode on, no matter
                         * if we are in front or behind it. Imagine that we started visual mode
                         * with some text like this:
                         *
                         *   abc|def
                         *
                         * (The | represents the cursor.) If we now press w, we'll select def,
                         * but if we hit b we expect to select abcd, so we need to getRight() on the
                         * start of the selection when it precedes where we started visual mode.
                         */
                        if (start.isAfter(stop)) {
                            start = start.getRightThroughLineBreaks();
                        }
                        selections.push(new vscode.Selection(start, stop));
                        break;
                    case mode_1.Mode.VisualLine:
                        [start, stop] = position_1.Position.sorted(start, stop);
                        selections.push(new vscode.Selection(start.getLineBegin(), stop.getLineEnd()));
                        break;
                    case mode_1.Mode.VisualBlock:
                        for (const line of textEditor_1.TextEditor.iterateLinesInBlock(vimState, cursor)) {
                            selections.push(new vscode.Selection(line.start, line.end));
                        }
                        break;
                    default:
                        // Note that this collapses the selection onto one position
                        selections.push(new vscode.Selection(stop, stop));
                        break;
                }
            }
            if (selectionMode === mode_1.Mode.VisualLine) {
                for (let i = 0; i < vimState.cursors.length; i++) {
                    // Maintain cursor position based on which direction the selection is going
                    const { start, stop } = vimState.cursors[i];
                    const selectionStart = position_1.Position.FromVSCodePosition(selections[i].start);
                    const selectionEnd = position_1.Position.FromVSCodePosition(selections[i].end);
                    if (start.line <= stop.line) {
                        vimState.cursors[i] = new range_1.Range(selectionStart, selectionEnd);
                    }
                    else {
                        vimState.cursors[i] = new range_1.Range(selectionEnd, selectionStart);
                    }
                    // Adjust the selection so that active and anchor are correct; this
                    // makes relative line numbers display correctly
                    if (selectionStart.line <= selectionEnd.line && stop.line <= start.line) {
                        selections[i] = new vscode.Selection(selectionEnd, selectionStart);
                    }
                }
            }
            this.vimState.editor.selections = selections;
        }
        // Scroll to position of cursor
        if (vimState.editor.visibleRanges.length > 0 &&
            !vimState.postponedCodeViewChanges.some((change) => change.command === 'editorScroll')) {
            const isCursorAboveRange = (visibleRange) => visibleRange.start.line - vimState.cursorStopPosition.line >= 15;
            const isCursorBelowRange = (visibleRange) => vimState.cursorStopPosition.line - visibleRange.end.line >= 15;
            const { visibleRanges } = vimState.editor;
            const centerViewportAroundCursor = visibleRanges.every(isCursorAboveRange) || visibleRanges.every(isCursorBelowRange);
            const revealType = centerViewportAroundCursor
                ? vscode.TextEditorRevealType.InCenter
                : vscode.TextEditorRevealType.Default;
            if (this.vimState.currentMode === mode_1.Mode.SearchInProgressMode) {
                const nextMatch = globalState_1.globalState.searchState.getNextSearchMatchPosition(vimState.cursorStopPosition);
                if (nextMatch === null || nextMatch === void 0 ? void 0 : nextMatch.match) {
                    this.vimState.editor.revealRange(new vscode.Range(nextMatch.pos, nextMatch.pos), revealType);
                }
                else if (vimState.firstVisibleLineBeforeSearch !== undefined) {
                    const offset = vimState.editor.visibleRanges[0].start.line - vimState.firstVisibleLineBeforeSearch;
                    util_1.scrollView(vimState, offset);
                }
            }
            else if (args.revealRange) {
                this.vimState.editor.revealRange(new vscode.Range(vimState.cursorStopPosition, vimState.cursorStopPosition), revealType);
            }
        }
        // cursor style
        let cursorStyle = configuration_1.configuration.getCursorStyleForMode(mode_1.Mode[this.currentMode]);
        if (!cursorStyle) {
            const cursorType = mode_1.getCursorType(this.currentMode);
            cursorStyle = mode_1.getCursorStyle(cursorType);
            if (cursorType === mode_1.VSCodeVimCursorType.Native &&
                configuration_1.configuration.editorCursorStyle !== undefined) {
                cursorStyle = configuration_1.configuration.editorCursorStyle;
            }
        }
        this.vimState.editor.options.cursorStyle = cursorStyle;
        // cursor block
        let cursorRange = [];
        if (mode_1.getCursorType(this.currentMode) === mode_1.VSCodeVimCursorType.TextDecoration &&
            this.currentMode !== mode_1.Mode.Insert) {
            // Fake block cursor with text decoration. Unfortunately we can't have a cursor
            // in the middle of a selection natively, which is what we need for Visual Mode.
            if (this.currentMode === mode_1.Mode.Visual) {
                for (const { start: cursorStart, stop: cursorStop } of vimState.cursors) {
                    if (cursorStart.isBefore(cursorStop)) {
                        cursorRange.push(new vscode.Range(cursorStop.getLeft(), cursorStop));
                    }
                    else {
                        cursorRange.push(new vscode.Range(cursorStop, cursorStop.getRight()));
                    }
                }
            }
            else {
                for (const { stop: cursorStop } of vimState.cursors) {
                    cursorRange.push(new vscode.Range(cursorStop, cursorStop.getRight()));
                }
            }
        }
        this.vimState.editor.setDecorations(decoration_1.decoration.Default, cursorRange);
        // TODO: draw marks (#3963)
        // Draw search highlight
        let searchRanges = [];
        if (globalState_1.globalState.searchState &&
            ((configuration_1.configuration.incsearch && this.currentMode === mode_1.Mode.SearchInProgressMode) ||
                (configuration_1.configuration.hlsearch && globalState_1.globalState.hl))) {
            searchRanges.push.apply(searchRanges, globalState_1.globalState.searchState.matchRanges);
            const nextMatch = globalState_1.globalState.searchState.getNextSearchMatchRange(vimState.cursorStopPosition);
            // TODO: why are we putting the next match in separately; isn't this redundant?
            if (nextMatch) {
                const { start, end, match } = nextMatch;
                if (match) {
                    searchRanges.push(new vscode.Range(start, end));
                }
            }
        }
        this.vimState.editor.setDecorations(decoration_1.decoration.SearchHighlight, searchRanges);
        const easyMotionHighlightRanges = this.currentMode === mode_1.Mode.EasyMotionInputMode
            ? vimState.easyMotion.searchAction
                .getMatches(vimState.cursorStopPosition, vimState)
                .map((match) => match.toRange())
            : [];
        this.vimState.editor.setDecorations(decoration_1.decoration.EasyMotion, easyMotionHighlightRanges);
        for (const viewChange of this.vimState.postponedCodeViewChanges) {
            await vscode.commands.executeCommand(viewChange.command, viewChange.args);
            vimState.cursors = util_1.getCursorsAfterSync();
        }
        this.vimState.postponedCodeViewChanges = [];
        if (this.currentMode === mode_1.Mode.EasyMotionMode) {
            // Update all EasyMotion decorations
            this.vimState.easyMotion.updateDecorations();
        }
        statusBar_1.StatusBar.clear(this.vimState, false);
        await vscode_context_1.VsCodeContext.Set('vim.mode', mode_1.Mode[this.vimState.currentMode]);
        // Tell VSCode that the cursor position changed, so it updates its highlights for
        // `editor.occurrencesHighlight`.
        const range = new vscode.Range(vimState.cursorStartPosition, vimState.cursorStopPosition);
        if (!/\s+/.test(vimState.editor.document.getText(range))) {
            await vscode.commands.executeCommand('editor.action.wordHighlight.trigger');
        }
    }
    // Return true if a new undo point should be created based on brackets and parenthesis
    createUndoPointForBrackets(vimState) {
        // }])> keys all start a new undo state when directly next to an {[(< opening character
        const key = vimState.recordedState.actionKeys[vimState.recordedState.actionKeys.length - 1];
        if (key === undefined) {
            return false;
        }
        if (vimState.currentMode === mode_1.Mode.Insert) {
            // Check if the keypress is a closing bracket to a corresponding opening bracket right next to it
            let result = matcher_1.PairMatcher.nextPairedChar(vimState.cursorStopPosition, key);
            if (result !== undefined) {
                if (vimState.cursorStopPosition.isEqual(result)) {
                    return true;
                }
            }
            result = matcher_1.PairMatcher.nextPairedChar(vimState.cursorStopPosition.getLeft(), key);
            if (result !== undefined) {
                if (vimState.cursorStopPosition.getLeft(2).isEqual(result)) {
                    return true;
                }
            }
        }
        return false;
    }
    dispose() {
        this._disposables.map((d) => d.dispose());
    }
}
exports.ModeHandler = ModeHandler;

//# sourceMappingURL=modeHandler.js.map
