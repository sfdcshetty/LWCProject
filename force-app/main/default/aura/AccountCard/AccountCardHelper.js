({
	handleSelect : function(component, event, recordId, selVal, userId, accountId, contactId) {
        console.log('fire event', component.get('v.primaryIndIdUserContact'));
        console.log('fire event2', contactId);


        if(selVal == 'call') {
            var callEvent = $A.get("e.force:createRecord");
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            callEvent.setParams({
                "entityApiName": "Task",
                'recordTypeId': '0121K000000vgXSQAY',
                "defaultFieldValues": {
                    'Subject' : 'Call',
                    'TaskSubtype' : 'Call',
                    'Status' : 'Completed',
                    'ActivityDate' : today,
                    'WhoId': recordId
                }
            });
            callEvent.fire();

        } else if (selVal == 'task') {
            var taskEvent = $A.get("e.force:createRecord");
            taskEvent.setParams({
                "entityApiName": "Task",
                "defaultFieldValues": {
                    'WhoId': recordId
                }
            });
            taskEvent.fire();                        
        } else if(selVal == 'event') {
            var newEvent = $A.get("e.force:createRecord");
            newEvent.setParams({
                "entityApiName": "Event",
                "defaultFieldValues": {
                    'WhoId': recordId
                }
            });
            newEvent.fire();            
        } else if(selVal == 'todo') {
            var newEvent = $A.get("e.force:createRecord");
            if(contactId != ''){
                newEvent.setParams({
                    "entityApiName": "ToDo__c",
                    "defaultFieldValues": {
                        'Assigned_To_Individual__c': contactId
                    }
                });
            }else{
                newEvent.setParams({
                    "entityApiName": "ToDo__c",
                    "defaultFieldValues": {
                        'Assigned_To_Individual__c': component.get('v.secondaryIndId')
                    }
                });
            }
            newEvent.fire();            
        } else if(selVal == 'message') {
            console.log (userId);
            var msgEvent = $A.get("e.force:createRecord");
            if (userId == '') {
                msgEvent.setParams({
                    "entityApiName": "Secure_Messaging__c",
                    "defaultFieldValues": {
                        'Account__c': component.get('v.recordId')
                    }
                });
            } else {
                msgEvent.setParams({
                    "entityApiName": "Secure_Messaging__c",
                    "defaultFieldValues": {
                        'Account__c': accountId,
                        'Customer_User__c' : userId,
                        'Contact__c' : contactId
                    }
                });
            }
            msgEvent.fire();    
        }		
	}
})