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
const Constants_1 = require("../../common/Constants");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const QueryUnit_1 = require("../../database/QueryUnit");
const InfoNode_1 = require("../InfoNode");
const Procedure_1 = require("./Procedure");
class ProcedureGroup {
    constructor(host, user, password, port, database, certPath) {
        this.host = host;
        this.user = user;
        this.password = password;
        this.port = port;
        this.database = database;
        this.certPath = certPath;
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}_${Constants_1.ModelType.PROCEDURE_GROUP}`;
    }
    getTreeItem() {
        return {
            label: "PROCEDURE",
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.PROCEDURE_GROUP,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "procedure.svg")
        };
    }
    getChildren(isRresh = false) {
        return __awaiter(this, void 0, void 0, function* () {
            let tableNodes = DatabaseCache_1.DatabaseCache.getTableListOfDatabase(this.identify);
            if (tableNodes && !isRresh) {
                return tableNodes;
            }
            return QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `SELECT ROUTINE_NAME FROM information_schema.routines WHERE ROUTINE_SCHEMA = '${this.database}' and ROUTINE_TYPE='PROCEDURE'`)
                .then((tables) => {
                tableNodes = tables.map((table) => {
                    return new Procedure_1.ProcedureNode(this.host, this.user, this.password, this.port, this.database, table.ROUTINE_NAME, this.certPath);
                });
                DatabaseCache_1.DatabaseCache.setTableListOfDatabase(this.identify, tableNodes);
                if (tableNodes.length == 0) {
                    return [new InfoNode_1.InfoNode("This database has no procedure")];
                }
                return tableNodes;
            })
                .catch((err) => {
                return [new InfoNode_1.InfoNode(err)];
            });
        });
    }
    createTemplate() {
        ConnectionManager_1.ConnectionManager.getConnection(this, true);
        QueryUnit_1.QueryUnit.createSQLTextDocument(`CREATE
/*[DEFINER = { user | CURRENT_USER }]*/
PROCEDURE [name]()
BEGIN

END;`);
    }
}
exports.ProcedureGroup = ProcedureGroup;
//# sourceMappingURL=procedureGroup.js.map