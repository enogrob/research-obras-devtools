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
const tableNode_1 = require("./tableNode");
const DatabaseCache_1 = require("../../database/DatabaseCache");
const Constants_1 = require("../../common/Constants");
const ConnectionManager_1 = require("../../database/ConnectionManager");
const QueryUnit_1 = require("../../database/QueryUnit");
const MysqlTreeDataProvider_1 = require("../../provider/MysqlTreeDataProvider");
class ViewNode extends tableNode_1.TableNode {
    constructor() {
        super(...arguments);
        this.type = Constants_1.ModelType.VIEW;
    }
    getTreeItem() {
        this.identify = `${this.host}_${this.port}_${this.user}_${this.database}_${this.table}`;
        return {
            label: this.table,
            collapsibleState: DatabaseCache_1.DatabaseCache.getElementState(this),
            contextValue: Constants_1.ModelType.VIEW,
            iconPath: path.join(Constants_1.Constants.RES_PATH, "view.svg"),
            command: {
                command: "mysql.template.sql",
                title: "Run Select Statement",
                arguments: [this, true]
            }
        };
    }
    drop() {
        vscode.window.showInputBox({ prompt: `Are you want to drop view ${this.table} ?     `, placeHolder: 'Input y to confirm.' }).then((inputContent) => __awaiter(this, void 0, void 0, function* () {
            if (inputContent.toLocaleLowerCase() == 'y') {
                QueryUnit_1.QueryUnit.queryPromise(yield ConnectionManager_1.ConnectionManager.getConnection(this), `DROP view ${this.database}.${this.table}`).then(() => {
                    DatabaseCache_1.DatabaseCache.clearTableCache(`${this.host}_${this.port}_${this.user}_${this.database}`);
                    MysqlTreeDataProvider_1.MySQLTreeDataProvider.refresh();
                    vscode.window.showInformationMessage(`Drop view ${this.table} success!`);
                });
            }
            else {
                vscode.window.showInformationMessage(`Cancel drop view ${this.table}!`);
            }
        }));
    }
}
exports.ViewNode = ViewNode;
//# sourceMappingURL=viewNode.js.map