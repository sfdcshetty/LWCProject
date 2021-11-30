({
    init: function(component, event, helper) {
        helper.init(component);
    },
    handleClick: function(component, event, helper) {
        // toggle the drop down
        if (component.get("v.dropdownOpen")) {
            var mainDiv = component.find('main-div');
        	$A.util.removeClass(mainDiv, 'slds-is-open');
            component.set("v.dropdownOpen", false);
        }
        else {
            var mainDiv = component.find('main-div');
            $A.util.addClass(mainDiv, 'slds-is-open');
            component.set("v.dropdownOpen", true);
        }
    },
    handleMouseLeave: function(component, event, helper) {
        // hide the drop down
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
        component.set("v.dropdownOpen", false);
        
        // get the selected labels and update the info text
        var labels = helper.getSelectedLabels(component);
        helper.setInfoText(component, labels);
        
        // get the selected values and fire the event to update the parent
        var values = helper.getSelectedValues(component);
        helper.fireSelectChangeEvent(component, values);
    },
    handleSelection: function(component, event, helper) {
        // get the event target
        var item = event.currentTarget;
        if (item && item.dataset) {
            // option clicked -- get the value and whether it was selected or unselected
            var value = item.dataset.value;
            var selected = item.dataset.selected;
            
            // grab the list of options from the component
            var options = component.get("v.options_");
            
            // update the element/option clicked
            options.forEach(function(element) {
                if (element.value == value) {
                    element.selected = selected == "true" ? false : true;
                }
            });
            
            //shift key ADDS to the list (unless clicking on a previously selected item)
            //also, shift key does not close the dropdown (uses mouse out to do that)
            /*if (event.shiftKey) {
                options.forEach(function(element) {
                    if (element.value == value) {
                        element.selected = selected == "true" ? false : true;
                    }
                });
            } else {
                options.forEach(function(element) {
                    if (element.value == value) {
                        element.selected = selected == "true" ? false : true;
                    } else {
                        element.selected = false;
                    }
                });
                var mainDiv = component.find('main-div');
                $A.util.removeClass(mainDiv, 'slds-is-open');
            }*/
            
            // update the options on the componenet
            component.set("v.options_", options);
        }
    }
    /*handleMouseOutButton: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    //if dropdown over, user has hovered over the dropdown, so don't close.
                    if (component.get("v.dropdownOver")) {
                        return;
                    }
                    var mainDiv = component.find('main-div');
                    $A.util.removeClass(mainDiv, 'slds-is-open');
                }
            }), 200
        );
    }*/
})