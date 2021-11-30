({
    doInit : function (component, event, helper) {
        helper.showSpinner (component, event, helper);
        component.set ('v.readOnly', true);
        component.set ('v.Document_Folder', 'Document Submission');
        var type = '';
        if (!component.get ('v.recordId').startsWith ('a0z')) {
            type = 'Version';
            
            var action = component.get("c.getFileName");
            action.setParams({
                "recordId": component.get ('v.recordId'),
                "type" : type
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    
                    component.find ('name').set ('v.value', result);
                }
            });
            
            $A.enqueueAction(action);
        }
        var pickListValuesAction = component.get("c.getDocumentTypes");
        
        pickListValuesAction.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                var documentTypes = [];
                for (var i = 0; i < result.length; i++) {
                    var selected = false;
                    if (result [i] === 'Document Submission') {
                        selected = true;
                    	component.set ('v.selectedValue', 'Document Submission');
                    }
                    documentTypes.push ({label: result[i], value: result[i], selected: selected});
                    
                }
                
                component.set ('v.documentTypes', documentTypes);
                helper.showSpinner (component, event, helper);
            }
            else {
                helper.showSpinner (component, event, helper);
            }
        });

    	$A.enqueueAction(pickListValuesAction);
        
        var defaultFolder = component.get("c.defaultFolder");
        defaultFolder.setParams (
            {
                objectName : 'Account_Servicing__c',
                folderValue : 'Document Submission'
            });
        defaultFolder.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set ("v.selectedFolderRecord", result);
                var appEvent = $A.get("e.c:Docuvault_LookupEvent");
                appEvent.setParams({"record" : result });  
                appEvent.fire();
            }
            
        });
        
        $A.enqueueAction(defaultFolder);
    },
     
    closeAction : function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

    },
    documentFolderHandler : function (component, event, helper) {
        var record = event.getParams ('record');
        if (record.record != null)
        	component.set ('v.Document_Folder', record.record.TVA_CFB__Value__c);
        else
            component.set ('v.Document_Folder', '');
    },
    createRecord : function (component, event, helper) {
        component.set ('v.disableButtons', true);
        helper.showSpinner (component, event, helper);
        var cloudFile = {
            'Name' : component.find ('name').get ('v.value'),
            'TVA_CFB__File_Type__c' : 'pdf',
            'WEGP1_DocumentType__c' : component.get ('v.selectedValue'),
            'TVA_CFB__Folder__c' : component.get ('v.Document_Folder'),
            'WEGP1_Ready_for_Review__c' : component.find ('readyForReview').get ('v.checked')
        };
        var type = '';
        if (component.get ('v.recordId').startsWith ('a0z')) {
            console.log('aaaa');
            cloudFile['TVA_CFB__Parent_ID__c'] = component.get ('v.recordId');
            cloudFile['WEG_Account_Servicing__c'] = component.get ('v.recordId');
            //cloudFile['WEGP1_Household__c'] = component.get ('v.recordId');
            cloudFile['TVA_CFB__Version__c'] = 1;
        }
        else {
            type = 'Version';
            cloudFile ['Id'] = component.get ('v.recordId');
        }
        console.log (cloudFile);
        var action = component.get("c.createCloudFile");
        action.setParams({
            "cloudFile": cloudFile,
            "type" : type
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log (result);
                if (result != null) {
                    helper.showSpinner (component, event, helper);
                    var recordName = result.TVA_CFB__E_Tag__c+'_'+result.Id+'.pdf';
                    var ddpId = $A.get ("$Label.c.DDPIdAS");
                    var deliveryOptionId = $A.get ("$Label.c.DeliveryOptionIdAS");
                    component.set ('v.src', '/apex/ProcessDDP?id='+result.Id
                                   +'&ddpId='+ddpId+'&deliveryOptionId='+deliveryOptionId);
                    helper.showToast (component, event, helper, 'success', 
                                      'File Name : '+recordName);
                } else {
                    helper.showSpinner (component, event, helper);
                    helper.showToast (component, event, helper, 'error', 'Some thing went wrong. Please try again.');
                }
            }
            else {
                var errors = response.getError();
                helper.showSpinner (component, event, helper);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast (component, event, helper, 'error', errors[0].message);
                    }
                } else {
                    helper.showToast (component, event, helper, 'error', 'Unknown error');
                }
                
            }
        });

    	$A.enqueueAction(action);
    },
    closeMessage : function(component, event, helper) {
        var notification = component.find ('notification');
        $A.util.addClass (notification, 'slds-hide');
        component.set ('v.message', '');
        component.set ('v.disableButtons', false);
        component.set ('v.readOnly', true);
        component.find ('documentSubmission').set ('v.checked', true);	
        component.find ('readyForReview').set ('v.checked', true);	
        component.set ('v.Document_Folder', 'Document Submission');
        component.find ('name').set ('v.value', '');
        var defaultFolder = component.get ('v.selectedFolderRecord') ;
        var appEvent = $A.get("e.c:Docuvault_LookupEvent");
        appEvent.setParams({"record" : defaultFolder});  
        appEvent.fire();
        var documentTypesVal = [];
        var documentTypes = component.get ('v.documentTypes');
        for (var i = 0; i < documentTypes.length; i++) {
            var selected = false;
            if (documentTypes[i].value === 'Document Submission') {
                selected = true;
                component.set ('v.selectedValue', 'Document Submission');
            }
            documentTypesVal.push ({label: documentTypes[i].label, value: documentTypes[i].value, selected: selected});
            
        }
        component.set ('v.documentTypes', documentTypesVal);
    },
    clickEvent : function(component, event, helper) {
		var documentSubmission = component.find ('documentSubmission');
        var checkVal = documentSubmission.get ('v.checked');
        component.set ('v.readOnly', checkVal);
        var documentTypes = component.get ('v.documentTypes');
        var appEvent = $A.get("e.c:Docuvault_LookupEvent");
        var defaultFolder = component.get ('v.selectedFolderRecord') ;
        var documentTypesVal = [];
        if (checkVal) {
			component.find ('readyForReview').set ('v.checked', true);	
            component.set ('v.Document_Folder', 'Document Submission');
            
            appEvent.setParams({"record" : defaultFolder});  
            appEvent.fire();
            for (var i = 0; i < documentTypes.length; i++) {
                var selected = false;
                if (documentTypes[i].value === 'Document Submission') {
                    selected = true;
                    component.set ('v.selectedValue', 'Document Submission');
                }
                documentTypesVal.push ({label: documentTypes[i].label, value: documentTypes[i].value, selected: selected});
                
            }
            component.set ('v.documentTypes', documentTypesVal);
        }
        else {
            component.find ('readyForReview').set ('v.checked', false);
            component.set ('v.Document_Folder', '');
            appEvent.setParams({"record" : {}});  
            appEvent.fire();
            component.set ('v.selectedValue', '');
            for (var i = 0; i < documentTypes.length; i++) {
                documentTypesVal.push ({label: documentTypes[i].label, value: documentTypes[i].value, selected: selected});
            }
            component.set ('v.documentTypes', documentTypesVal);
        }
           
	}
})