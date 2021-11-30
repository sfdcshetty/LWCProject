({
	init: function(component) {
        //note, we get options and set options_
        //options_ is the private version and we use this from now on.
        //this is to allow us to sort the options array before rendering
        if (component.get("v.initialized")){
            return;
        }
        component.set("v.initialized",true);
        
        // grab the 'public' options variable
        var options = component.get("v.options");
        if (!options)
            options = [{label: "Example 1", value: "Example1"}, {label: "Example 2", value: "Example2"}];
        
        // grab the 'public' selected items variable (array)
        var selectedItems = component.get('v.selectedItems');
        
        // select the options that were initially supplied
        options.forEach(function(element) {
            if (selectedItems.includes(element.value)) {
                element.selected = true;
            }
        });
        
        // set the 'private' options variable (all component features use this)
        component.set("v.options_", options);
        
        /*options.sort(function compare(a, b) {
            if (a.value == 'All') {
                return -1;
            } else if (a.value < b.value) {
                return -1;
            }
            if (a.value > b.value) {
                return 1;
            }
            return 0;
        });*/
        
        // get the selected labels and update the info text
        var labels = this.getSelectedLabels(component);
        this.setInfoText(component, labels);
    },
    setInfoText: function(component, labels) {
        // sets the text to be displayed at the top of the multi-picklist
        if (labels.length == 0) {
            component.set("v.placeholder_", component.get("v.placeholder"));
        }
        if (labels.length == 1) {
            component.set("v.placeholder_", labels[0]);
        }
        else if (labels.length > 1) {
            component.set("v.placeholder_", labels.length + " options selected");
        }
    },
    getSelectedValues: function(component) {
        // get the options from the component
        var options = component.get("v.options_");
        
        // iterate the options, gather the selected values
        var values = [];
        options.forEach(function(element) {
            if (element.selected) {
                values.push(element.value);
            }
        });
        
        // return the selected values
        return values;
    },
    getSelectedLabels: function(component) {
        // get the options from the component
        var options = component.get("v.options_");
        
        // iterate the options, gather the selected labels
        var labels = [];
        options.forEach(function(element) {
            if (element.selected) {
                labels.push(element.label);
            }
        });
        
        // return the selected labels
        return labels;
    },
    fireSelectChangeEvent: function(component,values) {
        var compEvent = component.getEvent("multiSelectChangedEvent");
        compEvent.setParams({"multiSelectValues" : values});
        compEvent.fire();
    }
})