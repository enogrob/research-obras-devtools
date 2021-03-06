"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const range_1 = require("./../common/motion/range");
exports.isTextTransformation = (x) => {
    return (x.type === 'insertText' ||
        x.type === 'replaceText' ||
        x.type === 'deleteText' ||
        x.type === 'deleteRange' ||
        x.type === 'moveCursor');
};
exports.isMultiCursorTextTransformation = (x) => {
    var _a;
    return (_a = (x.type === 'insertTextVSCode' && x.isMultiCursor)) !== null && _a !== void 0 ? _a : false;
};
const getRangeFromTextTransformation = (transformation) => {
    switch (transformation.type) {
        case 'insertText':
            return new range_1.Range(transformation.position, transformation.position);
        case 'replaceText':
            return new range_1.Range(transformation.start, transformation.end);
        case 'deleteText':
            return new range_1.Range(transformation.position, transformation.position);
        case 'deleteRange':
            return transformation.range;
        case 'moveCursor':
            return undefined;
    }
    throw new Error('Unhandled text transformation: ' + transformation);
};
exports.areAnyTransformationsOverlapping = (transformations) => {
    for (let i = 0; i < transformations.length; i++) {
        for (let j = i + 1; j < transformations.length; j++) {
            const first = transformations[i];
            const second = transformations[j];
            const firstRange = getRangeFromTextTransformation(first);
            const secondRange = getRangeFromTextTransformation(second);
            if (!firstRange || !secondRange) {
                continue;
            }
            if (firstRange.overlaps(secondRange)) {
                return true;
            }
        }
    }
    return false;
};
exports.areAllSameTransformation = (transformations) => {
    const firstTransformation = transformations[0];
    return transformations.every((t) => {
        return Object.entries(t).every(([key, value]) => {
            return firstTransformation[key] === value;
        });
    });
};

//# sourceMappingURL=transformations.js.map
