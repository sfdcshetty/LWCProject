/**
 * Created by karolbrennan on 4/23/21.
 */

({
    doInit : function(component, event, helper) {
        var action = component.get ('c.getRelatedAccountID');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set ('v.parentId', result);
                console.log (result);
            }
        });
        $A.enqueueAction(action);
    },
    handleFileUpload: function(component, event, helper){
        const isUploading = component.get ('v.uploading');
        if (isUploading) {
            return;
        }
        component.set ('v.uploading', true);
        let files = event.getParam('files');
        // var files = component.find ('inp').get ('v.files');
        component.set('v.submissionMessage', event.getParam('message'));
        component.set("v.fileList", files);
        helper.uploadHandler(component, event, helper, files, 0);
    },
    /*Component Reset*/
    resetComponent : function (component, event, helper) {
        let uploadStatus = {};
        component.set('v.uploadStatus', uploadStatus);
        component.set ('v.successFilesCount', 0);
        component.set ('v.errorFilesCount', 0);
        let cloudRecord = {
            'sobjectType' : 'TVA_CFB__Cloud_Files__c'
        };
        component.set ('v.cloudRecord', cloudRecord);
    },
});