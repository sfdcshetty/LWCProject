/**
 * 7summits-Uber-Theme - Generates the assets used for the 7Summits Uber Theme
 * @version 1.0.0
 * @author 7Summits
 */
({
    doInit: function doInit(component, event, helper) {
        helper.getSiteName(component);
    },

    goToSiteHome: function goToSiteHome(component, event) {
        var url = event.currentTarget.dataset.url;
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            'url': url
        });
        action.fire();
    },

    toggleSearch: function toggleSearch(component, event, helper) {
        helper.toggleSearch(component);
    },

    hideSearch: function hideSearch(component, event, helper) {
        helper.hideSearch(component);
    }
});