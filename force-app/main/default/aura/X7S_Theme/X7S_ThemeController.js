/**
 * Created by jonbalza on 2019-05-30.
 */
({
    handleInit : function(component, event, helper) {
        window.addEventListener("scroll", function() {
            helper.handleFixedNav(component, event, helper);
        });
        window.addEventListener("resize", function() {
            helper.handleFixedNav(component, event, helper);
        });
    }
})