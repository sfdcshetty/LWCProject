({
    uploadHandler : function(component, event, helper, filesList, index) {
        var uploadingFile = {};
        component.set ('v.uploadingFile', uploadingFile);
        // To check all the files uploading process is completed and to display a toaster
        if (index == filesList.length) {
            $A.get ("e.force:refreshView").fire ();
            var title = $A.get ('$Label.TVA_CFB.Successful_Upload');
            var message = 'Success: '+ component.get ('v.successFilesCount') 
            + ' Error: '+ component.get ('v.errorFilesCount');
            this.showToast (component, message, title, 'Success');
            this.resetComponent (component, event, helper);
        }
        if (index != (filesList.length)) {
            var file = filesList[index]; // To store the current file 
            
            // Here you can map the Fields for the cloud file record.
            var cloudFileRecord = component.get ('v.cloudRecord');
            // To map the folder as Tax Documents
            cloudFileRecord['TVA_CFB__Folder__c'] = 'Documents';
            cloudFileRecord['TVA_CFB__Account__c'] = '0012f00000cWqTp';
            cloudFileRecord['TVA_CFB__Parent_ID__c'] = '0012f00000cWqTp';
            
            var uploadFilesComp = component.find ('uploadFilesComp');
            if (!$A.util.isUndefined (uploadFilesComp) 
                && !$A.util.isEmpty (uploadFilesComp)) 
            {
                uploadFilesComp.set ('v.CloudFile', cloudFileRecord);
                console.log (file);
                uploadFilesComp.set ('v.selectedFile', file);
                uploadFilesComp.uploadFilesHandler (function (result) {
                    ++index;
                    console.log(JSON.stringify(result));
                    // For the successful file upload you will get below details as the result .
                    // {"sobjectType":"TVA_CFB__Cloud_Files__c", “Id":"a050I000018SlQ1QAK", //"TVA_CFB__E_Tag__c":"91798daf1e84bce62c281b93d6899b6e", //"TVA_CFB__Amazon_Version_ID__c":"rdzdPyG0vPwOZsS1V2dNSIFVSQBQHuIC", //"TVA_CFB__Reponse_Code__c":"204"}
                    
                    if (result != '') {
                        component.set ('v.successFilesCount', uploadFilesComp.get ('v.successFiles'));
                    } else {
                        component.set ('v.errorFiles', uploadFilesComp.get ('v.errorFiles'));
                    }
                    component.set ('v.progressBar', '0%');
                    helper.uploadHandler (component, event, helper, filesList, index);
                });
            }
        }
    },
    /* Lightning custom toast helper*/
    showToast : function(component, message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },
    
    /*Component Reset*/
    resetComponent : function (component, event, helper) {
        component.set ('v.successFilesCount', 0);
        component.set ('v.errorFilesCount', 0);
        
        var cloudRecord = {
            'sobjectType' : 'TVA_CFB__Cloud_Files__c'
        };
        component.set ('v.cloudRecord', cloudRecord);
    }
})