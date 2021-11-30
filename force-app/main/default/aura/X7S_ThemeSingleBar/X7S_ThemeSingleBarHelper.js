/**
 * 7summits-Uber-Theme - Generates the assets used for the 7Summits Uber Theme
 * @version 1.0.0
 * @author 7Summits
 */
({

    toggleSearch: function toggleSearch(component) {
        var searchIsOpen = component.get("v.searchIsOpen");
        component.set("v.searchIsOpen", !searchIsOpen);
    },

    hideSearch: function hideSearch(component) {
        component.set("v.searchIsOpen", false);
    },

    getSiteName: function getSiteName(component) {
        var action = component.get("c.getSiteName");

        action.setCallback(this, function (actionResult) {
            var siteName = actionResult.getReturnValue();

            component.set("v.siteName", siteName);
        });

        $A.enqueueAction(action);
    }
});