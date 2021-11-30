({
    onTabCreated: function(cmp) {
        var workspace = cmp.find("workspace");
        var limit = cmp.get("v.limit");
        workspace.getAllTabInfo().then(function (tabInfo) {
            if (tabInfo.length > limit) {
                for (var i = 0; i < tabInfo.length; i++) {
                    if (!tabInfo[i].pinned) {
                        workspace.closeTab({tabId: tabInfo[i].tabId});
                        return;
                    }
                }
            }
        });
    }
})