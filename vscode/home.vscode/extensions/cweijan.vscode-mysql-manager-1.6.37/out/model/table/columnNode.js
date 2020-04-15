"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const vscode = require("vscode");
const Constants_1 = require("../../common/Constants");
const QueryUnit_1 = require("../../database/QueryUnit");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
class ColumnTreeItem extends vscode.TreeItem {
}
class ColumnNode {
    constructor(host, user, password, port, database, table, certPath, column) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.table = table;
        this.certPath = certPath;
        this.column = column;
        this.type = Constants_1.ModelType.COLUMN;
    }
    getIndex(columnKey) {
        switch (columnKey) {
            case 'UNI': return "UniqueKey";
            case 'MUL': return "IndexKey";
            case 'PRI': return "PrimaryKey";
        }
        return '';
    }
    getTreeItem() {
        return {
            columnName: `${this.column.COLUMN_NAME}`,
            detail: `${this.column.COLUMN_TYPE}`,
            document: `${this.column.COLUMN_COMMENT}`,
            label: `${this.column.COLUMN_NAME} : ${this.column.COLUMN_TYPE}  ${this.getIndex(this.column.COLUMN_KEY)}   ${this.column.COLUMN_COMMENT}`,
            collapsibleState: vscode.TreeItemCollapsibleState.None,
            contextValue: Constants_1.ModelType.COLUMN,
            iconPath: path.join(Constants_1.Constants.RES_PATH, this.column.COLUMN_KEY === "PRI" ? "b_primary.png" : "b_props.png"),
            command: {
                command: "mysql.column.update",
                title: "Update Column Statement",
                arguments: [this, true]
            }
        };
    }
    getChildren() {
        return __awaiter(this, void 0, void 0, function* () {
            return [];
        });
    }
    changeColumnName() {
        return __awaiter(this, void 0, void 0, function* () {
            const columnName = this.column.COLUMN_NAME;
            vscode.window.showInputBox({ value: columnName, placeHolder: 'newColumnName', prompt: `You will changed ${this.table}.${columnName} to new column name!` }).then((newColumnName) => __awaiter(this, void 0, void 0, function* () {
                if (!newColumnName)
                    return;
                const sql = `alter table ${this.database}.${this.table} change column ${columnName} ${newColumnName} ${this.column.COLUMN_TYPE} comment '${this.column.COLUMN_COMMENT}'`;
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), sql).then((rows) => {
                    DatabaseCache_1.DatabaseCache.clearColumnCache(`${this.host}_${this.port}_${this.user}_${this.database}_${this.table}`);
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                });
            }));
        });
    }
    addColumnTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.createSQLTextDocument(`ALTER TABLE ${this.database}.${this.table} ADD COLUMN columnName columnType NOT NULL comment '';`);
    }
    updateColumnTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.showSQLTextDocument(`ALTER TABLE ${this.database}.${this.table} CHANGE ${this.column.COLUMN_NAME} ${this.column.COLUMN_NAME} ${this.column.COLUMN_TYPE} NOT NULL comment '${this.column.COLUMN_COMMENT}';`);
    }
    dropColumnTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.createSQLTextDocument(`ALTER TABLE ${this.database}.${this.table} DROP COLUMN ${this.column.COLUMN_NAME};`);
    }
}
exports.ColumnNode = ColumnNode;
//# sourceMappingURL=columnNode.js.map