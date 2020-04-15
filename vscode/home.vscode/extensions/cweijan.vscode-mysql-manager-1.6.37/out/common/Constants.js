"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const path = require("path");
class Constants {
}
Constants.RES_PATH = path.join(vscode.extensions.getExtension('cweijan.vscode-mysql-manager').extensionPath, "resources");
Constants.DEFAULT_SIZE = 200;
exports.Constants = Constants;
class CacheKey {
}
CacheKey.ConectionsKey = "mysql.connections";
CacheKey.CollapseSate = "mysql.database.cache.collapseState";
exports.CacheKey = CacheKey;
class CommandKey {
}
CommandKey.RecordHistory = "mysql.hisotry.record";
CommandKey.Refresh = "mysql.refresh";
exports.CommandKey = CommandKey;
class Cursor {
    static getRangeStartTo(end) {
        return new vscode.Range(this.FIRST_POSITION, end);
    }
}
Cursor.FIRST_POSITION = new vscode.Position(0, 0);
exports.Cursor = Cursor;
class ModelType {
}
ModelType.CONNECTION = "connection";
ModelType.DATABASE = "database";
ModelType.USER_GROUP = "userGroup";
ModelType.USER = "user";
ModelType.TABLE = "table";
ModelType.COLUMN = "column";
ModelType.INFO = "info";
ModelType.TABLE_GROUP = "tableGroup";
ModelType.VIEW = "view";
ModelType.VIEW_GROUP = "viewGroup";
ModelType.TRIGGER_GROUP = "triggerGroup";
ModelType.TRIGGER = "trigger";
ModelType.PROCEDURE_GROUP = "procedureGroup";
ModelType.PROCEDURE = "procedure";
ModelType.FUNCTION_GROUP = "functionGroup";
ModelType.FUNCTION = "function";
exports.ModelType = ModelType;
class OperateType {
}
OperateType.execute = 'execute';
OperateType.previous = 2;
OperateType.next = 3;
OperateType.save = 4;
OperateType.delete = 5;
OperateType.export = 6;
exports.OperateType = OperateType;
//# sourceMappingURL=Constants.js.map