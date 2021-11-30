({
    fetchData : function(component, event) {
        component.set("v.showSpinner", true);
        
        var financialAccountData;
        component.set('v.financialAccountData', new Object());
        var fetchFinancialAccountData = component.get("c.getGridRecordsForReadOnlyMode");
        fetchFinancialAccountData.setParams({ 
            objectName : component.get("v.objectName"),
            recordTypes : component.get("v.recordTypes"),
            fields : component.get("v.fieldSetName"),
            accountId : component.get("v.recordId"),
            accountType : component.get("v.accountType"),
            groupBy : component.get("v.groupBy"),
            sortBy : component.get("v.sortBy"),
            statuses: component.get("v.statuses"),
            gridTitle: component.get("v.title")
        });
        
        fetchFinancialAccountData.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server State:>> " + response.getState());
                component.set("v.isEditMode", false);
                var financialAccountsData = JSON.parse(response.getReturnValue());
                console.log("response>>" + response.getReturnValue());
                
                var pageSizeLimit = component.get("v.pageSizeLimit");
                if(financialAccountsData.listSize > pageSizeLimit){
                	component.set("v.listSize", pageSizeLimit+"+");
                }else{
                	component.set("v.listSize", financialAccountsData.listSize);    
                }
                component.set('v.finAccGridWrap', financialAccountsData);
                component.set("v.readOnlyMode", true);
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(fetchFinancialAccountData);
    },
    
    editRecord : function(component, event, recordId) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId,
            closeCallback:function() {
                alert('You closed the alert!');
            }
            
        });
        editRecordEvent.fire();
        component.set("v.isForceSaveFired", true);
    },
    
    removeRecordFromGrid : function(component, event, recordId, selectedAction) {
        var action = component.get("c.updatesObject");
        action.setParams({ 
            recordId : recordId,
            removeOrHistoric : selectedAction,
            objectName : component.get('v.objectName')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:>>'+state);	
            if (state == "SUCCESS") {
                
                var updateResult = response.getReturnValue();
                var errorToastMessage = '';
                if(!updateResult.isSuccess){
                    errorToastMessage  = updateResult.errorMessage;
                }
                if(errorToastMessage != ''){
                    component.find('toast').showNotice({
                        "variant": "warning",
                        "header": "Update failed!",
                        "message": "Following error(s) has occurred while updating \n" + errorToastMessage,
                        closeCallback: function() {
                        }
                    });
                }
                this.fetchData(component, event);
                //$A.get('e.force:refreshView').fire();	    
            }
        });
        $A.enqueueAction(action);        
    },
    
    showRecordActionList_H : function(component, event) {
        var currentelemt = event.getSource();
        var name = currentelemt.get("v.name");
        var menuActionOptions = component.get("v.recordEditOptions");
        // check if status is not WEG Held or WEG Held Other
        var isReadOnlyMode = component.get("v.readOnlyMode");
        
        if(isReadOnlyMode){
            var financialAccountsData = component.get("v.finAccGridWrap");
            var i, j;
            for(i=0; i < financialAccountsData.categoryWrapperList.length;i++){
                for(j=0; j < financialAccountsData.categoryWrapperList[i].sObjects.length; j++){  
                    var sObject = financialAccountsData.categoryWrapperList[i].sObjects[j];
                    if(sObject.recordId === name){
                        var adjContWitInd = menuActionOptions.indexOf("Adjust Contributions/Withdrawals");
                        if(sObject.showCreateAdjustmentAction && adjContWitInd == -1){
                            menuActionOptions.push("Adjust Contributions/Withdrawals");
                        }
                        if(!sObject.showCreateAdjustmentAction && adjContWitInd != -1){
                            menuActionOptions.splice(adjContWitInd, 1);
                        }
                        
                        var viewAdjInd = menuActionOptions.indexOf("View Adjustments");
                        if(sObject.showViewAdjustmentAction && viewAdjInd == -1){
                            menuActionOptions.push("View Adjustments");
                        }
                        if(!sObject.showViewAdjustmentAction && viewAdjInd != -1){
                            menuActionOptions.splice(viewAdjInd, 1);
                        }
                        
                        var markForRemovalInd = menuActionOptions.indexOf("Mark for Removal");
                        if(sObject.showMarkForRemoval && markForRemovalInd == -1){
                            menuActionOptions.push("Mark for Removal");
                        }
                        if(!sObject.showMarkForRemoval && markForRemovalInd != -1){
                            menuActionOptions.splice(markForRemovalInd, 1);
                        }
                        
                    }
                }  
            }
        }
        component.set("v.recordEditOptions", menuActionOptions);    
        var menulist = document.getElementById(name + 'menulist');
        menulist.style.display = 'block';
        component.set("v.currentElementId", name);
    },
    
    hideRecordActionList_H : function(component, event) {
        var currentelemt = component.get("v.currentElementId");
        if(currentelemt) {
            var menulist = document.getElementById(currentelemt + 'menulist');
            if(menulist){
                menulist.style.display = 'none';
                component.set("v.currentElementId", "");
            }
        }        
    },
    
    editGridRecords : function(component, event){
        component.set("v.showSpinner", true);
        //var nameToCompare = 'FinServ__FinancialAccount__c';
        var fetchFinancialAccountData = component.get("c.getGridRecordsForEditMode");
        fetchFinancialAccountData.setParams({ 
            objectName : component.get("v.objectName"),
            recordTypes : component.get("v.recordTypes"),
            fields : component.get("v.fieldSetName"),
            accountId : component.get("v.recordId"),
            accountType : component.get("v.accountType"),
            groupBy : component.get("v.groupBy"),
            sortBy : component.get("v.sortBy"),
            statuses: component.get("v.statuses")
        });
        
        fetchFinancialAccountData.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isEditMode", false);
                var financialAccountsData = JSON.parse(response.getReturnValue());
                var i, j, k;
                var editMode = false;
                var record, outerInd, recordListInd;
                for(i=0; i < financialAccountsData.categoryWrapperList.length; i++){
                    for(j=0; j < financialAccountsData.categoryWrapperList[i].recordFieldValuesList.length; j++){
                        record = financialAccountsData.categoryWrapperList[i].recordFieldValuesList[j];
                        for(k=0; k < record.length; k++){
                            if(record[k].isUpdatable === true ){
                                record[k].isEdit = true;
                                editMode = true;
                            }
                            var data = financialAccountsData.categoryWrapperList[i].recordFieldValuesList[j][k];
                            if(data.fieldType === 'PERCENT'){
                                data.fieldValue = data.fieldValue/100;
                            }
                        }
                    }
                }        
                if(editMode){
                    var pageSizeLimit = component.get("v.pageSizeLimit");
                    if(financialAccountsData.listSize > pageSizeLimit){
                        component.set("v.listSize", pageSizeLimit+"+");
                    }else{
                        component.set("v.listSize", financialAccountsData.listSize);    
                    }
                    component.set("v.isEditMode", true); 
                    component.set("v.financialAccountData",financialAccountsData);
                    component.set("v.readOnlyMode", false);
                }  
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(fetchFinancialAccountData);    
    }
})