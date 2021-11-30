public with sharing class x7s_RecentDocumentsController {


    @AuraEnabled
    public static List<TVA_CFB__Cloud_Files__c> getListOfDocumentsForCurrentUser() {
        String thisUserId = UserInfo.getUserId();
        return getListOfDocuments(thisUserId);
    }

    @AuraEnabled
    public static List<TVA_CFB__Cloud_Files__c> getListOfDocuments(String userId) {
        User userRec = [
                SELECT ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c
                FROM User
                WHERE Id = :userId
                LIMIT 1
        ];

        System.debug(userRec.Contact.Account.WEGP1_Primary_Household__c);
        List<TVA_CFB__Cloud_Files__c> listCloudFiles = [
                SELECT ID,name,TVA_CFB__View_File__c,Portal_Document__c,Portal_Folder__c,
                        TVA_CFB__Folder__c,TVA_CFB__Download_File__c,CreatedById, CreatedBy.Name, LastModifiedDate, Share_On_Portal__c,
                        Shared_By_Email__c, Shared_By_Name__c, Send_Shareable_Email_Link__c, Last_Shared_on_Portal__c
                FROM TVA_CFB__Cloud_Files__c
                WHERE WEGP1_Household__c = :userRec.Contact.Account.WEGP1_Primary_Household__c OR CreatedById = :userId
                ORDER BY LastModifiedDate DESC
//                WHERE Share_On_Portal__c = true AND WEGP1_Household__c = :userRec.Contact.Account.WEGP1_Primary_Household__c
        ];
        return listCloudFiles;
    }

    @AuraEnabled
    public static List<TVA_CFB__DocuVault_Folders__c> getDocuvaultFolders() {
        return [SELECT TVA_CFB__Object_Name__c,TVA_CFB__Record_Type_ID__c, TVA_CFB__Value__c from TVA_CFB__DocuVault_Folders__c];
    }

    @AuraEnabled
    public Static List<String> getListOfFolderNames(){
        List<String> returnList = new List<String>();
        for(Schema.PicklistEntry picklistEntry : Schema.getGlobalDescribe().get('TVA_CFB__Cloud_Files__c').getDescribe().fields.getMap().get('Portal_Folder__c').getDescribe().picklistValues){
            returnList.add(picklistEntry.value);
        }
        return returnList;
    }

    @AuraEnabled
    public static Boolean deleteCloudFile(String fileId){
        try {
            List<TVA_CFB__Cloud_Files__c> listCloudFiles = [
                    SELECT ID,name,TVA_CFB__View_File__c,Portal_Document__c,Portal_Folder__c,
                            TVA_CFB__Folder__c,TVA_CFB__Download_File__c,CreatedById, CreatedBy.Name, LastModifiedDate, Share_On_Portal__c,
                            Shared_By_Email__c, Shared_By_Name__c, Send_Shareable_Email_Link__c, Last_Shared_on_Portal__c
                    FROM TVA_CFB__Cloud_Files__c
                    WHERE Id = :fileId
            ];

            if(listCloudFiles.size() > 0){
                TVA_CFB__Cloud_Files__c file = listCloudFiles[0];
                file.TVA_CFB__Folder__c = 'Trash';
                file.Portal_Folder__c = 'Trash';
                update file;

                return true;
            }
        }catch(Exception ex){
            System.debug('x7s_RecentDocumentsController.deleteCloudFile - ' + ex.getLineNumber() + ':' + ex.getMessage());
            return false;
        }

        return false;
    }
    
}