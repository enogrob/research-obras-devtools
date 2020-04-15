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
const vscode = require("vscode");
const Constants_1 = require("../common/Constants");
const ConnectionNode_1 = require("../model/ConnectionNode");
const DatabaseCache_1 = require("../database/DatabaseCache");
class MySQLTreeDataProvider {
    constructor(context) {
        this.context = context;
        this._onDidChangeTreeData = new vscode.EventEmitter();
        this.onDidChangeTreeData = this._onDidChangeTreeData.event;
        MySQLTreeDataProvider.instance = this;
        this.init();
    }
    /**
     * reload treeview context
     */
    init() {
        return __awaiter(this, void 0, void 0, function* () {
            yield (yield this.getConnectionNodes()).forEach((connectionNode) => __awaiter(this, void 0, void 0, function* () {
                (yield connectionNode.getChildren(true)).forEach((databaseNode) => __awaiter(this, void 0, void 0, function* () {
                    (yield databaseNode.getChildren(true)).forEach((tableNode) => __awaiter(this, void 0, void 0, function* () {
                        tableNode.getChildren(true);
                    }));
                }));
            }));
            DatabaseCache_1.DatabaseCache.clearColumnCache();
            MySQLTreeDataProvider.refresh();
        });
    }
    getTreeItem(element) {
        return element.getTreeItem();
    }
    getChildren(element) {
        if (!element) {
            return this.getConnectionNodes();
        }
        return element.getChildren();
    }
    addConnection(connectionOptions) {
        return __awaiter(this, void 0, void 0, function* () {
            let connections = this.context.globalState.get(Constants_1.CacheKey.ConectionsKey);
            if (!connections) {
                connections = {};
            }
            connections[`${connectionOptions.host}_${connectionOptions.port}_${connectionOptions.user}`] = connectionOptions;
            yield this.context.globalState.update(Constants_1.CacheKey.ConectionsKey, connections);
            MySQLTreeDataProvider.refresh();
        });
    }
    /**
     * refresh treeview context
     */
    static refresh(element) {
        this.instance._onDidChangeTreeData.fire(element);
    }
    getConnectionNodes() {
        return __awaiter(this, void 0, void 0, function* () {
            const connectionNodes = [];
            const connections = this.context.globalState.get(Constants_1.CacheKey.ConectionsKey);
            if (connections) {
                for (const key of Object.keys(connections)) {
                    connectionNodes.push(new ConnectionNode_1.ConnectionNode(key, connections[key].host, connections[key].user, connections[key].password, connections[key].port, connections[key].certPath));
                }
            }
            return connectionNodes;
        });
    }
}
exports.MySQLTreeDataProvider = MySQLTreeDataProvider;
//# sourceMappingURL=MysqlTreeDataProvider.js.map