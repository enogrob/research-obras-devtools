"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const Constants_1 = require("../common/Constants");
const tableNode_1 = require("../model/table/tableNode");
class DatabaseCache {
    static evictAllCache() {
        if (this.context == null)
            throw new Error("DatabaseCache is not init!");
        this.connectionNodeMapDatabaseNode = [];
        this.databaseNodeMapTableNode = {};
        this.tableNodeMapColumnNode = {};
    }
    /**
     * support to complection manager
     */
    static getDatabaseNodeList() {
        let databaseNodeList = [];
        Object.keys(this.connectionNodeMapDatabaseNode).forEach(key => {
            let tempList = this.connectionNodeMapDatabaseNode[key];
            if (tempList) {
                databaseNodeList = databaseNodeList.concat(tempList);
            }
        });
        return databaseNodeList;
    }
    /**
     * support to complection manager
     */
    static getTableNodeList() {
        let tableNodeList = [];
        Object.keys(this.databaseNodeMapTableNode).forEach(key => {
            let tempList = this.databaseNodeMapTableNode[key];
            if (tempList && (tempList[0] instanceof tableNode_1.TableNode)) {
                tableNodeList = tableNodeList.concat(tempList);
            }
        });
        return tableNodeList;
    }
    /**
     * get element current collapseState or default collapseState
     * @param element
     */
    static getElementState(element) {
        if (element.type == Constants_1.ModelType.COLUMN || element.type == Constants_1.ModelType.INFO) {
            return vscode_1.TreeItemCollapsibleState.None;
        }
        if (!this.collpaseState || Object.keys(this.collpaseState).length == 0) {
            this.collpaseState = this.context.globalState.get(Constants_1.CacheKey.CollapseSate);
        }
        if (!this.collpaseState) {
            this.collpaseState = {};
        }
        if (this.collpaseState[element.identify]) {
            return this.collpaseState[element.identify];
        }
        else if (element.type == Constants_1.ModelType.CONNECTION || element.type == Constants_1.ModelType.TABLE_GROUP) {
            return vscode_1.TreeItemCollapsibleState.Expanded;
        }
        else {
            return vscode_1.TreeItemCollapsibleState.Collapsed;
        }
    }
    /**
     * update tree node collapseState
     * @param element
     * @param collapseState
     */
    static storeElementState(element, collapseState) {
        if (element.type == Constants_1.ModelType.COLUMN || element.type == Constants_1.ModelType.INFO) {
            return;
        }
        this.collpaseState[element.identify] = collapseState;
        this.context.globalState.update(Constants_1.CacheKey.CollapseSate, this.collpaseState);
    }
    /**
     * cache init, Mainly initializing context object
     * @param context
     */
    static initCache(context) {
        this.context = context;
    }
    /**
     * clear database data for connection
     * @param connectionIdentify
     */
    static clearDatabaseCache(connectionIdentify) {
        if (connectionIdentify) {
            delete this.connectionNodeMapDatabaseNode[connectionIdentify];
        }
        else {
            this.connectionNodeMapDatabaseNode = {};
        }
    }
    /**
     * clear table data for database
     * @param databaseIdentify
     */
    static clearTableCache(databaseIdentify) {
        if (databaseIdentify) {
            delete this.databaseNodeMapTableNode[databaseIdentify];
        }
        else {
            this.databaseNodeMapTableNode = {};
        }
    }
    /**
     * claer column data for table
     * @param tableIdentify
     */
    static clearColumnCache(tableIdentify) {
        if (tableIdentify) {
            delete this.tableNodeMapColumnNode[tableIdentify];
        }
        else {
            this.tableNodeMapColumnNode = {};
        }
    }
    /**
     * get connectino tree data
     * @param connectcionIdentify
     */
    static getDatabaseListOfConnection(connectcionIdentify) {
        if (this.connectionNodeMapDatabaseNode[connectcionIdentify]) {
            return this.connectionNodeMapDatabaseNode[connectcionIdentify];
        }
        else {
            return null;
        }
    }
    static getTableListOfDatabase(databaseIdentify) {
        let result = [];
        this.tableTypeList.forEach(tableType => {
            let tableList = this.databaseNodeMapTableNode[databaseIdentify + "_" + tableType];
            if (tableList)
                result = result.concat(tableList);
        });
        if (result.length == 0)
            return null;
        return result;
    }
    /**
     * get table tree data
     * @param tableIdentify
     */
    static getColumnListOfTable(tableIdentify) {
        if (this.tableNodeMapColumnNode[tableIdentify]) {
            return this.tableNodeMapColumnNode[tableIdentify];
        }
        else {
            return null;
        }
    }
    static setDataBaseListOfConnection(connectionIdentify, DatabaseNodeList) {
        this.connectionNodeMapDatabaseNode[connectionIdentify] = DatabaseNodeList;
    }
    static setTableListOfDatabase(databaseIdentify, tableNodeList) {
        this.databaseNodeMapTableNode[databaseIdentify] = tableNodeList;
    }
    static setColumnListOfTable(tableIdentify, columnList) {
        this.tableNodeMapColumnNode[tableIdentify] = columnList;
    }
}
DatabaseCache.connectionNodeMapDatabaseNode = {};
DatabaseCache.databaseNodeMapTableNode = {};
DatabaseCache.tableNodeMapColumnNode = {};
/**
 * get database tree data
 * @param databaseIdentify
 */
DatabaseCache.tableTypeList = [Constants_1.ModelType.TABLE_GROUP, Constants_1.ModelType.VIEW_GROUP, Constants_1.ModelType.FUNCTION_GROUP, Constants_1.ModelType.TRIGGER_GROUP, Constants_1.ModelType.PROCEDURE_GROUP];
exports.DatabaseCache = DatabaseCache;
//# sourceMappingURL=DatabaseCache.js.map