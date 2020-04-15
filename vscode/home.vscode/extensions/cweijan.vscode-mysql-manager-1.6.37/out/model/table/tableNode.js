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
const mysqldump_1 = require("mysqldump");
const QueryUnit_1 = require("../../database/QueryUnit");
const columnNode_1 = require("./columnNode");
const InfoNode_1 = require("../InfoNode");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const Constants_1 = require("../../common/Constants");
const OutputChannel_1 = require("../../common/OutputChannel");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
class TableNode {
    constructor(host, user, password, port, database, table, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.table = table;
        this.certPath = certPath;
        this.type = Constants_1.ModelType.TABLE;
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}_${this.table}`;
    }
    getTreeItem() {
        return {
            label: this.table,
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.TABLE,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "table.svg"),
            command: {
                command: "mysql.template.sql",
                title: "Run Select Statement",
                arguments: [this, true]
            }
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            let columnNodes = DatabaseCache_1.DatabaseCache.getColumnListOfTable(this.identify);
            if (columnNodes && !isRresh) {
                return columnNodes;
            }
            return QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `SELECT COLUMN_NAME,COLUMN_TYPE,COLUMN_COMMENT,COLUMN_TYPE,COLUMN_KEY FROM information_schema.columns WHERE table_schema = '${this.database}' AND table_name = '${this.table}';`)
                .then((columns) => {
                columnNodes = columns.map((column) => {
                    return new columnNode_1.ColumnNode(this.host, this.user, this.password, this.port, this.database, this.table, this.certPath, column);
                });
                DatabaseCache_1.DatabaseCache.setColumnListOfTable(this.identify, columnNodes);
                return columnNodes;
            })
                .catch((err) => {
                return [new InfoNode_1.InfoNode(err)];
            });
        });
    }
    changeTableName() {
        vscode.window.showInputBox({ value: this.table, placeHolder: 'newTableName', prompt: `You will changed ${this.database}.${this.table} to new table name!` }).then((newTableName) => __awaiter(this, void 0, void 0, function* () {
            if (!newTableName)
                return;
            const sql = `alter table ${this.database}.${this.table} rename ${newTableName}`;
            QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), sql).then((rows) => {
                DatabaseCache_1.DatabaseCache.clearTableCache(`${this.host}_${this.port}_${this.user}_${this.database}`);
                MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
            });
        }));
    }
    dropTable() {
        vscode.window.showInputBox({ prompt: `Are you want to drop table ${this.table} ?     `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `DROP TABLE ${this.database}.${this.table}`).then(() => {
                    DatabaseCache_1.DatabaseCache.clearTableCache(`${this.host}_${this.port}_${this.user}_${this.database}`);
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                    vscode.window.showInformationMessage(`Drop table ${this.table} success!`);
                });
            }
            else {
                vscode.window.showInformationMessage(`Cancel drop table ${this.table}!`);
            }
        }));
    }
    truncateTable() {
        vscode.window.showInputBox({ prompt: `Are you want to clear table ${this.table} all data ?          `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `truncate table ${this.database}.${this.table}`).then(() => {
                    vscode.window.showInformationMessage(`Clear table ${this.table} all data success!`);
                });
            }
        }));
    }
    indexTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.showSQLTextDocument(`-- ALTER TABLE ${this.database}.${this.table} DROP INDEX [indexName];
-- ALTER TABLE ${this.database}.${this.table} ADD [UNIQUE|KEY|PRIMARY KEY] INDEX ([column]);`);
        setTimeout(() => {
            QueryUnit_1.QueryUnit.runQuery(`SELECT column_name,table_schema,index_name,non_unique FROM INFORMATION_SCHEMA.STATISTICS WHERE table_schema='${this.database}' and table_name='${this.table}';`, this);
        }, 10);
    }
    selectSqlTemplate(run) {
        return __awaiter(this, void 0, void 0, function* () {
            const sql = `SELECT * FROM ${this.database}.${this.table} LIMIT ${Constants_1.Constants.DEFAULT_SIZE};`;
            if (run) {
                ConnectionManager_1.ConnectionManager.getConnection(this, true);
                QueryUnit_1.QueryUnit.runQuery(sql, this);
            }
            else {
                QueryUnit_1.QueryUnit.createSQLTextDocument(sql);
            }
        });
    }
    insertSqlTemplate() {
        this
            .getChildren()
            .then((children) => {
            const childrenNames = children.map((child) => child.column.COLUMN_NAME);
            let sql = `insert into ${this.database}.${this.table}\n`;
            sql += `(${childrenNames.toString().replace(/,/g, ", ")})\n`;
            sql += "values\n";
            sql += `(${childrenNames.toString().replace(/,/g, ", ")});`;
            QueryUnit_1.QueryUnit.createSQLTextDocument(sql);
        });
    }
    deleteSqlTemplate() {
        this
            .getChildren()
            .then((children) => {
            const keysNames = children.filter((child) => child.column.COLUMN_KEY).map((child) => child.column.COLUMN_NAME);
            const where = keysNames.map((name) => `${name} = ${name}`);
            let sql = `delete from ${this.database}.${this.table} \n`;
            sql += `where ${where.toString().replace(/,/g, "\n   and ")}`;
            QueryUnit_1.QueryUnit.createSQLTextDocument(sql);
        });
    }
    updateSqlTemplate() {
        this
            .getChildren()
            .then((children) => {
            const keysNames = children.filter((child) => child.column.COLUMN_KEY).map((child) => child.column.COLUMN_NAME);
            const childrenNames = children.filter((child) => !child.column.COLUMN_KEY).map((child) => child.column.COLUMN_NAME);
            const sets = childrenNames.map((name) => `${name} = ${name}`);
            const where = keysNames.map((name) => `${name} = ${name}`);
            let sql = `update ${this.database}.${this.table} \nset ${sets.toString().replace(/,/g, "\n  , ")}\n`;
            sql += `where ${where.toString().replace(/,/g, "\n   and ")}`;
            QueryUnit_1.QueryUnit.createSQLTextDocument(sql);
        });
    }
    backupData(exportPath) {
        OutputChannel_1.Console.log(`Doing backup ${this.host}_${this.database}_${this.table}...`);
        mysqldump_1.default({
            connection: {
                host: this.host,
                user: this.user,
                password: this.password,
                database: this.database,
                port: parseInt(this.port)
            },
            dump: {
                tables: [this.table],
                schema: {
                    table: {
                        ifNotExist: false,
                        dropIfExist: true,
                        charset: false
                    },
                    engine: false
                }
            },
            dumpToFile: `${exportPath}\\${this.database}.${this.table}_${this.host}.sql`
        }).then(() => {
            vscode.window.showInformationMessage(`Backup ${this.host}_${this.database}_${this.table} success!`);
        }).catch((err) => {
            vscode.window.showErrorMessage(`Backup ${this.host}_${this.database}_${this.table} fail!\n${err}`);
        });
        OutputChannel_1.Console.log("backup end.");
    }
}
exports.TableNode = TableNode;
//# sourceMappingURL=tableNode.js.map