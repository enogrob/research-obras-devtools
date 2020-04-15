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
const mysqldump_1 = require("mysqldump");
const path = require("path");
const vscode = require("vscode");
const Constants_1 = require("../../common/Constants");
const OutputChannel_1 = require("../../common/OutputChannel");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const QueryUnit_1 = require("../../database/QueryUnit");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
const functionGroup_1 = require("../other/functionGroup");
const procedureGroup_1 = require("../other/procedureGroup");
const triggerGroup_1 = require("../other/triggerGroup");
const tableGroup_1 = require("../table/tableGroup");
const viewGroup_1 = require("../table/viewGroup");
class DatabaseNode {
    constructor(host, user, password, port, database, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.certPath = certPath;
        this.type = Constants_1.ModelType.DATABASE;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}`;
        return {
            label: this.database,
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.DATABASE,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "database.svg")
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            return [new tableGroup_1.TableGroup(this.host, this.user, this.password, this.port, this.database, this.certPath),
                new viewGroup_1.ViewGroup(this.host, this.user, this.password, this.port, this.database, this.certPath),
                new procedureGroup_1.ProcedureGroup(this.host, this.user, this.password, this.port, this.database, this.certPath),
                new functionGroup_1.FunctionGroup(this.host, this.user, this.password, this.port, this.database, this.certPath),
                new triggerGroup_1.TriggerGroup(this.host, this.user, this.password, this.port, this.database, this.certPath)];
        });
    }
    importData(fsPath) {
        OutputChannel_1.Console.log(`Doing import ${this.host}:${this.port}_${this.database}...`);
        ConnectionManager_1.ConnectionManager.getConnection(this).then(connection => {
            QueryUnit_1.QueryUnit.runFile(connection, fsPath);
        });
    }
    backupData(exportPath) {
        OutputChannel_1.Console.log(`Doing backup ${this.host}_${this.database}...`);
        mysqldump_1.default({
            connection: {
                host: this.host,
                user: this.user,
                password: this.password,
                database: this.database,
                port: parseInt(this.port)
            },
            dump: {
                schema: {
                    table: {
                        ifNotExist: false,
                        dropIfExist: true,
                        charset: false
                    },
                    engine: false
                }
            },
            dumpToFile: `${exportPath}\\${this.database}_${this.host}.sql`
        }).then(() => {
            vscode.window.showInformationMessage(`Backup ${this.host}_${this.database} success!`);
        }).catch((err) => {
            vscode.window.showErrorMessage(`Backup ${this.host}_${this.database} fail!\n${err}`);
        });
        OutputChannel_1.Console.log("backup end.");
    }
    deleteDatatabase() {
        vscode.window.showInputBox({ prompt: `Are you want to Delete Database ${this.database} ?     `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `DROP DATABASE ${this.database}`).then(() => {
                    DatabaseCache_1.DatabaseCache.clearDatabaseCache(`${this.host}_${this.port}_${this.user}`);
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                    vscode.window.showInformationMessage(`Delete database ${this.database} success!`);
                });
            }
            else {
                vscode.window.showInformationMessage(`Cancel delete database ${this.database}!`);
            }
        }));
    }
    newQuery() {
        return __awaiter(this, void 0, void 0, function* () {
            QueryUnit_1.QueryUnit.createSQLTextDocument();
            ConnectionManager_1.ConnectionManager.getConnection(this, true);
        });
    }
}
exports.DatabaseNode = DatabaseNode;
//# sourceMappingURL=databaseNode.js.map