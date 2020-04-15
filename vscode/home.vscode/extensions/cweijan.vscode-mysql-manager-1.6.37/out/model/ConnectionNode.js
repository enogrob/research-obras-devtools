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
const Constants_1 = require("../common/Constants");
const OutputChannel_1 = require("../common/OutputChannel");
const ConnectionManager_1 = require("../database/ConnectionManager");
const DatabaseCache_1 = require("../database/DatabaseCache");
const QueryUnit_1 = require("../database/QueryUnit");
const MysqlTreeDataProvider_1 = require("../provider/MysqlTreeDataProvider");
const databaseNode_1 = require("./database/databaseNode");
const userGroup_1 = require("./database/userGroup");
const InfoNode_1 = require("./InfoNode");
class ConnectionNode {
    constructor(id, host, user, password, port, certPath) {
        this.id = id;
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.certPath = certPath;
        this.type = Constants_1.ModelType.CONNECTION;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.user}`;
        return {
            label: this.identify,
            id: this.host,
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.CONNECTION,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "server.png")
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            this.identify = `${this.host}_${this.port}_${this.user}`;
            let databaseNodes = DatabaseCache_1.DatabaseCache.getDatabaseListOfConnection(this.identify);
            if (databaseNodes && !isRresh) {
                return databaseNodes;
            }
            return QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), "SHOW DATABASES")
                .then((databases) => {
                databaseNodes = databases.map((database) => {
                    return new databaseNode_1.DatabaseNode(this.host, this.user, this.password, this.port, database.Database, this.certPath);
                });
                databaseNodes.unshift(new userGroup_1.UserGroup(this.host, this.user, this.password, this.port, 'mysql', this.certPath));
                DatabaseCache_1.DatabaseCache.setDataBaseListOfConnection(this.identify, databaseNodes);
                return databaseNodes;
            })
                .catch((err) => {
                return [new InfoNode_1.InfoNode(err)];
            });
        });
    }
    newQuery() {
        return __awaiter(this, void 0, void 0, function* () {
            QueryUnit_1.QueryUnit.createSQLTextDocument();
            ConnectionManager_1.ConnectionManager.getConnection(this);
        });
    }
    createDatabase() {
        vscode.window.showInputBox({ placeHolder: 'Input you want to create new database name.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `create database ${inputContent} default character set = 'utf8' `).then(() => {
                DatabaseCache_1.DatabaseCache.clearDatabaseCache(this.identify);
                MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                vscode.window.showInformationMessage(`create database ${inputContent} success!`);
            });
        }));
    }
    deleteConnection(context) {
        return __awaiter(this, void 0, void 0, function* () {
            const connections = context.globalState.get(Constants_1.CacheKey.ConectionsKey);
            delete connections[this.id];
            yield context.globalState.update(Constants_1.CacheKey.ConectionsKey, connections);
            MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
        });
    }
    importData(fsPath) {
        OutputChannel_1.Console.log(`Doing import ${this.host}:${this.port}...`);
        ConnectionManager_1.ConnectionManager.getConnection(this).then(connection => {
            QueryUnit_1.QueryUnit.runFile(connection, fsPath);
        });
    }
}
exports.ConnectionNode = ConnectionNode;
//# sourceMappingURL=ConnectionNode.js.map