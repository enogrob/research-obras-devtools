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
const ConnectionManager_1 = require("../../database/ConnectionManager");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const QueryUnit_1 = require("../../database/QueryUnit");
const InfoNode_1 = require("../InfoNode");
const databaseNode_1 = require("./databaseNode");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
class UserGroup extends databaseNode_1.DatabaseNode {
    constructor(host, user, password, port, database, certPath) {
        super(host, user, password, port, database, certPath);
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.certPath = certPath;
        this.type = Constants_1.ModelType.DATABASE;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.user}_${Constants_1.ModelType.USER_GROUP}`;
        return {
            label: "USER",
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.USER_GROUP,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "user.svg")
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            let userNodes = [];
            return QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `SELECT DISTINCT USER FROM mysql.user;`)
                .then((tables) => {
                userNodes = tables.map((table) => {
                    return new UserNode(this.host, this.user, this.password, this.port, table.USER, this.certPath);
                });
                return userNodes;
            })
                .catch((err) => {
                return [new InfoNode_1.InfoNode(err)];
            });
        });
    }
    createTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.createSQLTextDocument(`CREATE USER 'username'@'host' IDENTIFIED BY 'password';`);
    }
}
exports.UserGroup = UserGroup;
class UserNode {
    constructor(host, user, password, port, name, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.name = name;
        this.certPath = certPath;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.name}`;
        return {
            label: this.name,
            contextValue: Constants_1.ModelType.USER,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "user.svg"),
            command: {
                command: "mysql.user.sql",
                title: "Run User Detail Statement",
                arguments: [this, true]
            }
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            return [];
        });
    }
    selectSqlTemplate() {
        return __awaiter(this, void 0, void 0, function* () {
            const sql = `SELECT USER 0USER,HOST 1HOST,Super_priv,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Index_priv,Alter_priv FROM mysql.user where user='${this.name}';`;
            QueryUnit_1.QueryUnit.runQuery(sql, this);
        });
    }
    drop() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        vscode.window.showInputBox({ prompt: `Are you want to drop user ${this.user} ?     `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `DROP user ${this.name}`).then(() => {
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                    vscode.window.showInformationMessage(`Drop user ${this.name} success!`);
                });
            }
            else {
                vscode.window.showInformationMessage(`Cancel drop user ${this.name}!`);
            }
        }));
    }
    changePasswordTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.createSQLTextDocument(`update mysql.user set password=PASSWORD("newPassword") where User='${this.name}';\nFLUSH PRIVILEGES;\n-- since mysql version 5.7, password column need change to authentication_string=PASSWORD("test")`);
    }
}
exports.UserNode = UserNode;
//# sourceMappingURL=userGroup.js.map