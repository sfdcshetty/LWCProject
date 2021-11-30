({
	doInit : function(component, event, helper) {        
        var sObjectName = '';
        var recordId  = component.get('v.recordId');
        if(recordId.startsWith('a0z')) {
            sObjectName = 'Account_Servicing__c';
            helper.reviewHelper (component, event, helper, recordId);
        } 
    }
})