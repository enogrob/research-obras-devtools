"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const configuration_1 = require("./../configuration/configuration");
const notation_1 = require("../configuration/notation");
class BaseAction {
    constructor() {
        /**
         * Can this action be paired with an operator (is it like w in dw)? All
         * BaseMovements can be, and some more sophisticated commands also can be.
         */
        this.isMotion = false;
        /**
         * If isJump is true, then the cursor position will be added to the jump list on completion.
         */
        this.isJump = false;
        this.canBeRepeatedWithDot = false;
        this.mustBeFirstKey = false;
        this.isOperator = false;
        /**
         * The keys pressed at the time that this action was triggered.
         */
        this.keysPressed = [];
        /**
         * True if this action has the potential to change the document's text, and therefore trigger an
         * undo step. This is for optimization purposes - we skip the expensive process of figuring out
         * what changed to create that undo step if this returns false.
         *
         * Most commands do not modify the document, so this is false by default. This means if you add a
         * command that can modify the document or switch modes, you MUST set mightChangeDocument = true. Otherwise undo
         * will not work properly.
         *
         *
         * TODO: if all actions were pure, I think this would be unnecessary, as we could deduce it from
         * vimState.transformations being empty or not.
         */
        this.mightChangeDocument = false;
    }
    /**
     * Whether we should change `vimState.desiredColumn`
     */
    preservesDesiredColumn() {
        return false;
    }
    /**
     * Is this action valid in the current Vim state?
     */
    doesActionApply(vimState, keysPressed) {
        if (this.mustBeFirstKey &&
            vimState.recordedState.commandWithoutCountPrefix.length > keysPressed.length) {
            return false;
        }
        return (this.modes.includes(vimState.currentMode) &&
            BaseAction.CompareKeypressSequence(this.keys, keysPressed));
    }
    /**
     * Could the user be in the process of doing this action.
     */
    couldActionApply(vimState, keysPressed) {
        if (!this.modes.includes(vimState.currentMode)) {
            return false;
        }
        const keys2D = BaseAction.is2DArray(this.keys) ? this.keys : [this.keys];
        const keysSlice = keys2D.map(x => x.slice(0, keysPressed.length));
        if (!BaseAction.CompareKeypressSequence(keysSlice, keysPressed)) {
            return false;
        }
        if (this.mustBeFirstKey &&
            vimState.recordedState.commandWithoutCountPrefix.length - keysPressed.length > 0) {
            return false;
        }
        return true;
    }
    static CompareKeypressSequence(one, two) {
        if (BaseAction.is2DArray(one)) {
            for (const sequence of one) {
                if (BaseAction.CompareKeypressSequence(sequence, two)) {
                    return true;
                }
            }
            return false;
        }
        if (one.length !== two.length) {
            return false;
        }
        for (let i = 0, j = 0; i < one.length; i++, j++) {
            const left = one[i], right = two[j];
            if (left === '<any>' || right === '<any>') {
                continue;
            }
            if (left === '<number>' && this.isSingleNumber.test(right)) {
                continue;
            }
            if (right === '<number>' && this.isSingleNumber.test(left)) {
                continue;
            }
            if (left === '<alpha>' && this.isSingleAlpha.test(right)) {
                continue;
            }
            if (right === '<alpha>' && this.isSingleAlpha.test(left)) {
                continue;
            }
            if (left === '<character>' && !notation_1.Notation.IsControlKey(right)) {
                continue;
            }
            if (right === '<character>' && !notation_1.Notation.IsControlKey(left)) {
                continue;
            }
            if (left === '<leader>' && right === configuration_1.configuration.leader) {
                continue;
            }
            if (right === '<leader>' && left === configuration_1.configuration.leader) {
                continue;
            }
            if (left === configuration_1.configuration.leader || right === configuration_1.configuration.leader) {
                return false;
            }
            if (left !== right) {
                return false;
            }
        }
        return true;
    }
    toString() {
        return this.keys.join('');
    }
    static is2DArray(x) {
        return Array.isArray(x[0]);
    }
}
exports.BaseAction = BaseAction;
BaseAction.isSingleNumber = /^[0-9]$/;
BaseAction.isSingleAlpha = /^[a-zA-Z]$/;
var KeypressState;
(function (KeypressState) {
    KeypressState[KeypressState["WaitingOnKeys"] = 0] = "WaitingOnKeys";
    KeypressState[KeypressState["NoPossibleMatch"] = 1] = "NoPossibleMatch";
})(KeypressState = exports.KeypressState || (exports.KeypressState = {}));
class Actions {
    /**
     * Gets the action that should be triggered given a key
     * sequence.
     *
     * If there is a definitive action that matched, returns that action.
     *
     * If an action could potentially match if more keys were to be pressed, returns true. (e.g.
     * you pressed "g" and are about to press "g" action to make the full action "gg".)
     *
     * If no action could ever match, returns false.
     */
    static getRelevantAction(keysPressed, vimState) {
        let isPotentialMatch = false;
        const possibleActionsForMode = Actions.actionMap.get(vimState.currentMode) || [];
        for (const actionType of possibleActionsForMode) {
            const action = new actionType();
            if (action.doesActionApply(vimState, keysPressed)) {
                action.keysPressed = vimState.recordedState.actionKeys.slice(0);
                return action;
            }
            if (action.couldActionApply(vimState, keysPressed)) {
                isPotentialMatch = true;
            }
        }
        return isPotentialMatch ? KeypressState.WaitingOnKeys : KeypressState.NoPossibleMatch;
    }
}
exports.Actions = Actions;
/**
 * Every Vim action will be added here with the @RegisterAction decorator.
 */
Actions.actionMap = new Map();
function RegisterAction(action) {
    const actionInstance = new action();
    for (const modeName of actionInstance.modes) {
        let actions = Actions.actionMap.get(modeName);
        if (!actions) {
            actions = [];
            Actions.actionMap.set(modeName, actions);
        }
        if (actionInstance.keys === undefined) {
            // action that can't be called directly
            continue;
        }
        actions.push(action);
    }
}
exports.RegisterAction = RegisterAction;

//# sourceMappingURL=base.js.map
