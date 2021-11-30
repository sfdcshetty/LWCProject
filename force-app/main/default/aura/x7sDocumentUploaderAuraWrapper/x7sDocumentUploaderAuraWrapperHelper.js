/**
 * Created by karolbrennan on 4/23/21.
 */

({
    uploadHandler : function(component, event, helper, fileList, index) {
        let uploadingFile = {};
        component.set ('v.uploadingFile', uploadingFile);
        
        if (index === fileList.length) {
            component.set ('v.uploading', false);
            return;
        }

        let uploadStatus = {};
        uploadStatus.files = JSON.parse(JSON.stringify(fileList));
        uploadStatus.uploading = true;
        uploadStatus.currentFile = fileList[index];
        if(index === 0) {
            uploadStatus.progress = 0;
        } else {
            uploadStatus.progress = ((index+1) / fileList.length) * 100;
        }
        uploadStatus.message = `Uploading file ${index+1} of ${fileList.length}...`;
        component.set('v.uploadStatus', uploadStatus);

        var file = fileList[index]; // To store the current file 
        
        // Here you can map the Fields for the cloud file record.
        let cloudFileRecord = component.get ('v.cloudRecord');
        cloudFileRecord['TVA_CFB__Folder__c'] = file.type;
        cloudFileRecord['Portal_Folder__c'] = file.type;
        cloudFileRecord['Portal_Document__c'] = component.get('v.parentId');
        cloudFileRecord['WEG_Document_Name__c'] = file.name;
        cloudFileRecord['Name'] = file.name;
        cloudFileRecord['Document_Submission_Note__c'] = component.get('v.submissionMessage');
        
        var uploadFilesComp = component.find ('uploadFilesComp');
        if (!$A.util.isUndefined (uploadFilesComp) && !$A.util.isEmpty (uploadFilesComp)) {
            uploadFilesComp.set ('v.CloudFile', cloudFileRecord);            
            uploadFilesComp.set ('v.selectedFile', file.file);

            uploadFilesComp.uploadFilesHandler (function (result) {
                // For the successful file upload you will get below details as the result .
                // {"sobjectType":"TVA_CFB__Cloud_Files__c", “Id":"a050I000018SlQ1QAK", //"TVA_CFB__E_Tag__c":"91798daf1e84bce62c281b93d6899b6e", //"TVA_CFB__Amazon_Version_ID__c":"rdzdPyG0vPwOZsS1V2dNSIFVSQBQHuIC", //"TVA_CFB__Reponse_Code__c":"204"}
                
                if (result && result.Id) {
                    fileList[index].success = true;
                    component.set ('v.successFilesCount', uploadFilesComp.get ('v.successFiles'));
                } else {
                    fileList[index].success = false;
                    component.set ('v.errorFiles', uploadFilesComp.get ('v.errorFiles'));
                }
                if((index+1) === fileList.length){
                    uploadStatus.uploading = false;
                    uploadStatus.progress = 100;
                    uploadStatus.files = fileList;
                    component.set('v.uploadStatus', uploadStatus);
                }
                helper.uploadHandler (component, event, helper, fileList, ++index);
                component.find('x7sDocumentUploader').handleUpdateVault();
            });
        }
    },
});