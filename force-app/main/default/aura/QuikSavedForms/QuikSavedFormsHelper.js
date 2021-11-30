({
    getASQuikFormRecords : function(component, event, helper, accServRecId) {
        var action = component.get('c.displayASQuikFormRecords');
        action.setParams({"accServRecId":accServRecId,"formType":"Print"});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set('v.asQuikFormsList', result.asForms);
            component.set('v.allowEsign', result.allowEsign);
            component.set('v.displaySpinner', false);
        });
        $A.enqueueAction(action);
    }
})