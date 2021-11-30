({
    searchHelper : function(component, event, getInputkeyWord) {
        var action = component.get("c.searchRecords");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objName' : component.get("v.objectAPIName"),
            'fieldAPI': component.get("v.fieldApis"),
            'fldVal': component.get("v.fieldValues"),
            'dataLimit': component.get("v.dataLimit")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);    
    }   
})