/**
 * Created by jonbalza on 2019-05-30.
 */
({
    handleFixedNav: function(component, event, helper) {
        const scrollPos = window.scrollY || document.documentElement.scrollTop;
        const isScrolled = component.get("v.isScrolled");
        const scrollOffset = 20;

        if (scrollPos > (0 + scrollOffset) && !isScrolled) {
            component.set("v.isScrolled", true);
        }
        else if (scrollPos < (0 + scrollOffset) && isScrolled) {
            component.set("v.isScrolled", false);
        }
    }
})