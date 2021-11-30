({
	doInit : function(component, event, helper) {
        var recordTypeOptions = component.get("v.recordTypeOptions");
        component.set("v.selectedRecordTypeId", recordTypeOptions[0].value);
	},
    
    createNewRecord : function(component, event, helper){
        var windowHash = window.location.hash;
        var objectName = component.get("v.objectName");
        var recordTypeId = component.get("v.selectedRecordTypeId");
        var primaryOwnerId = component.get("v.primaryOwnerId");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": objectName,
            "recordTypeId": recordTypeId,
            "defaultFieldValues": {
				'FinServ__PrimaryOwner__c' : primaryOwnerId
			},
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
            }
        });
        createRecordEvent.fire();
        component.destroy();
    },
    
    closeModal : function(component, event){
        component.destroy();
    }
})