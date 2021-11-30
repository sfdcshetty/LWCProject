({
    getASQuikFormRecords : function(component, event, helper, accServRecId) {
        var action = component.get('c.getASFormGroupRecords');
        action.setParams({
            "RecordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set('v.envelopeList', result);
            component.set('v.displaySpinner', false);
        });
        $A.enqueueAction(action);
    }
})