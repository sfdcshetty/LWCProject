({
    doInit : function(component, event, helper) {
        console.log (component.get ('v.recordId'));
        var action = component.get ('c.getRelatedAccountID');		
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log (result);
                component.set ('v.parentId', result);
                if (!$A.util.isEmpty (result) && !$A.util.isUndefined (result)) {
                    if (result.length == 18 || result.length == 15) {
                        var layout ='{"Description" : "Short_Description__c"}';
                        var tableColumns = 'Short_Description__c,Created_By__c,Created_Date__c';
                        var DynamicRecordActions ='{"Actions": [{"label": "Update Description","header": "Update Description","component": "c:Docuvault_EditFileDescription","labelIcon": "utility:edit","showHeader": "true","componentWidth": "40%","componentHeight": "12rem"}]}';
                        $A.createComponent(
                            "TVA_CFB:Docuvault_FolderStructure",
                            {
                                "recordId" : result,
                                "enablefolderRename" : false,
                                "enableFolderPublicLink" : false,
                                "enableFolderPasswordProtectedLink" : false,
                                "enableFolderRemoveLink" : false,
                                "enableChangeFolder" : false,
                                "enableFolderDownload" : false,
                                "enableThumbnailPreview" : true,
                                "enableRecord_Download" : true,
                                "enableRecord_ViewFile" : true,
                                "enableRecord_VersionUpload" : false,
                                "enableRecord_PublicLink" : false,
                                "enableRecord_PasswordProtectedLink" : false,
                                "enableUploadAS_SF_File" : false,
                                "enableRecord_DeleteFile" : false,
                                "hoverLayout" : layout,
                                "recordActions" : DynamicRecordActions,
                                "tableColumns" : tableColumns
                            },
                            function (FolderView, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    var body = component.get("v.FolderView");
                                    body.push (FolderView);
                                    component.set("v.FolderView", body);
                                }
                                
                            }
                        );
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})