/*--
  ~ Copyright (c) 2020. 7Summits Inc. All rights reserved.
  --*/

  ({
    doInit : function(component, event, helper) {
        window.addEventListener("scroll", function() {
            helper.handleFixedNav(component, event, helper);
        });
        window.addEventListener("resize", function() {
            helper.handleFixedNav(component, event, helper);
        });
    }
})