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
const QueryUnit_1 = require("../../database/QueryUnit");
const InfoNode_1 = require("../InfoNode");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const tableNode_1 = require("./tableNode");
const Constants_1 = require("../../common/Constants");
class TableGroup {
    constructor(host, user, password, port, database, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.certPath = certPath;
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}_${Constants_1.ModelType.TABLE_GROUP}`;
    }
    getTreeItem() {
        return {
            label: "TABLE",
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.TABLE_GROUP,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "table.svg")
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            let tableNodes = DatabaseCache_1.DatabaseCache.getTableListOfDatabase(this.identify);
            if (tableNodes && !isRresh) {
                return tableNodes;
            }
            return QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `SELECT TABLE_NAME FROM information_schema.TABLES  WHERE TABLE_SCHEMA = '${this.database}' and TABLE_TYPE<>'VIEW' LIMIT ${QueryUnit_1.QueryUnit.maxTableCount} ;`)
                .then((tables) => {
                tableNodes = tables.map((table) => {
                    return new tableNode_1.TableNode(this.host, this.user, this.password, this.port, this.database, table.TABLE_NAME, this.certPath);
                });
                DatabaseCache_1.DatabaseCache.setTableListOfDatabase(this.identify, tableNodes);
                if (tableNodes.length == 0) {
                    return [new InfoNode_1.InfoNode("This database has no table")];
                }
                return tableNodes;
            })
                .catch((err) => {
                return [new InfoNode_1.InfoNode(err)];
            });
        });
    }
}
exports.TableGroup = TableGroup;
//# sourceMappingURL=tableGroup.js.map