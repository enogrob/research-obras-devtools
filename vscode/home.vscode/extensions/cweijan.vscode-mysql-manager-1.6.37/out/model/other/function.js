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
const QueryUnit_1 = require("../../database/QueryUnit");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const Constants_1 = require("../../common/Constants");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
class FunctionNode {
    constructor(host, user, password, port, database, name, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.name = name;
        this.certPath = certPath;
        this.type = Constants_1.ModelType.FUNCTION;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}_${this.name}`;
        return {
            label: this.name,
            // collapsibleState: DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.FUNCTION,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "function.svg"),
            command: {
                command: "mysql.show.function",
                title: "Show Function Create Source",
                arguments: [this, true]
            }
        };
    }
    showSource() {
        return __awaiter(this, void 0, void 0, function* () {
            QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this, true), `SHOW CREATE FUNCTION ${this.database}.${this.name}`)
                .then((procedDtail) => {
                procedDtail = procedDtail[0];
                QueryUnit_1.QueryUnit.showSQLTextDocument(`DROP FUNCTION IF EXISTS ${procedDtail['Function']}; \n\n${procedDtail['Create Function']}`);
            });
        });
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            return [];
        });
    }
    drop() {
        vscode.window.showInputBox({ prompt: `Are you want to drop function ${this.name} ?     `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `DROP function ${this.database}.${this.name}`).then(() => {
                    DatabaseCache_1.DatabaseCache.clearTableCache(`${this.host}_${this.port}_${this.user}_${this.database}_${Constants_1.ModelType.FUNCTION_GROUP}`);
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                    vscode.window.showInformationMessage(`Drop function ${this.name} success!`);
                });
            }
            else {
                vscode.window.showInformationMessage(`Cancel drop function ${this.name}!`);
            }
        }));
    }
}
exports.FunctionNode = FunctionNode;
//# sourceMappingURL=function.js.map