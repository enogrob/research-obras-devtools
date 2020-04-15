"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const config_1 = require("./config");
class StatusBarItem {
    constructor(repoManager, logger) {
        this.isVisible = false;
        this.numRepos = 0;
        this.disposables = [];
        this.logger = logger;
        const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 1);
        statusBarItem.text = 'Git Graph';
        statusBarItem.tooltip = 'View Git Graph';
        statusBarItem.command = 'git-graph.view';
        this.statusBarItem = statusBarItem;
        this.disposables.push(statusBarItem);
        repoManager.onDidChangeRepos((event) => {
            this.setNumRepos(event.numRepos);
        }, this.disposables);
        this.setNumRepos(Object.keys(repoManager.getRepos()).length);
    }
    dispose() {
        this.disposables.forEach((disposable) => disposable.dispose());
        this.disposables = [];
    }
    setNumRepos(numRepos) {
        this.numRepos = numRepos;
        this.refresh();
    }
    refresh() {
        const shouldBeVisible = config_1.getConfig().showStatusBarItem && this.numRepos > 0;
        if (this.isVisible !== shouldBeVisible) {
            if (shouldBeVisible) {
                this.statusBarItem.show();
                this.logger.log('Showing "Git Graph" Status Bar Item');
            }
            else {
                this.statusBarItem.hide();
                this.logger.log('Hiding "Git Graph" Status Bar Item');
            }
            this.isVisible = shouldBeVisible;
        }
    }
}
exports.StatusBarItem = StatusBarItem;
//# sourceMappingURL=statusBarItem.js.map