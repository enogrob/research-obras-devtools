"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const mysql = require("mysql");
const OutputChannel_1 = require("../common/OutputChannel");
const Global_1 = require("../common/Global");
const QueryUnit_1 = require("./QueryUnit");
class ConnectionManager {
    static updateLastActiveConnection(connectionOptions) {
        this.lastConnectionOption = connectionOptions;
    }
    static getLastActiveConnection() {
        if (!this.lastConnectionOption) {
            return undefined;
        }
        if (this.lastActiveConnection && this.lastActiveConnection.state == 'authenticated') {
            return this.lastActiveConnection;
        }
        return this.getConnection(Object.assign({ multipleStatements: true }, this.lastConnectionOption));
    }
    static getConnection(connectionOptions, changeActive = false) {
        if (!connectionOptions.multipleStatements)
            connectionOptions.multipleStatements = true;
        const key = `${connectionOptions.host}_${connectionOptions.port}_${connectionOptions.user}_${connectionOptions.password}`;
        return new Promise((resolve, reject) => {
            if (this.connectionCache[key] && this.connectionCache[key].conneciton.state == 'authenticated') {
                if (connectionOptions.database) {
                    QueryUnit_1.QueryUnit.queryPromise(this.connectionCache[key].conneciton, `use ${connectionOptions.database}`).then(() => {
                        if (changeActive || this.lastActiveConnection == undefined) {
                            this.lastConnectionOption = this.connectionCache[key].connectionOptions;
                            this.lastActiveConnection = this.connectionCache[key].conneciton;
                            Global_1.Global.updateStatusBarItems(connectionOptions);
                        }
                        resolve(this.connectionCache[key].conneciton);
                    }).catch(error => {
                        reject(error);
                    });
                }
                else {
                    if (changeActive || this.lastActiveConnection == undefined) {
                        this.lastConnectionOption = this.connectionCache[key].connectionOptions;
                        this.lastActiveConnection = this.connectionCache[key].conneciton;
                        Global_1.Global.updateStatusBarItems(connectionOptions);
                    }
                    resolve(this.connectionCache[key].conneciton);
                }
            }
            else {
                this.connectionCache[key] = {
                    connectionOptions: connectionOptions,
                    conneciton: this.createConnection(connectionOptions)
                };
                this.connectionCache[key].conneciton.connect((err) => {
                    if (!err) {
                        if (changeActive || this.lastActiveConnection == undefined) {
                            this.lastConnectionOption = connectionOptions;
                            this.lastActiveConnection = this.connectionCache[key].conneciton;
                            Global_1.Global.updateStatusBarItems(connectionOptions);
                        }
                        resolve(this.lastActiveConnection);
                    }
                    else {
                        this.connectionCache[key] = undefined;
                        OutputChannel_1.Console.log(`${err.stack}\n${err.message}`);
                        reject(err.message);
                    }
                });
            }
        });
    }
    static createConnection(connectionOptions) {
        const newConnectionOptions = Object.assign({ useConnectionPooling: true }, connectionOptions);
        if (connectionOptions.certPath && fs.existsSync(connectionOptions.certPath)) {
            newConnectionOptions.ssl = {
                ca: fs.readFileSync(connectionOptions.certPath),
            };
        }
        this.lastConnectionOption = newConnectionOptions;
        return mysql.createConnection(newConnectionOptions);
    }
}
ConnectionManager.connectionCache = {};
exports.ConnectionManager = ConnectionManager;
//# sourceMappingURL=ConnectionManager.js.map