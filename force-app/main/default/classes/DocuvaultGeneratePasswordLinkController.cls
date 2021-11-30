/*
    Created By         : Docuvault Team
    Created Date       : 11-09-2017
    Test Class Name    : DocuvaultGeneratePasswordLinkController_TC
    Description        : Class to generate the password protected link 
*/

public with sharing class DocuvaultGeneratePasswordLinkController {
    @AuraEnabled
    public static string generateShareableLink (ID recordId, String emailAddress) {
        String returnMsg = '';
        try {
            TVA_CFB__Cloud_Files__c cloudFile = NEW TVA_CFB__Cloud_Files__c ();
            cloudFile = [ SELECT 
                         Email__c, TVA_CFB__Password_Protect__c, TVA_CFB__Password__c,
                         TVA_CFB__Cloud_Public_Access_URL__c, TVA_CFB__Public_Short_URL__c,
                         Send_Shareable_Email_Link__c, TVA_CFB__File_Size_in_Bytes__c
                        FROM
                            TVA_CFB__Cloud_Files__c
                        WHERE
                            ID =: recordId ];
            if (cloudFile.TVA_CFB__File_Size_in_Bytes__c < 10000000) {
                if (cloudFile.TVA_CFB__Password_Protect__c 
                    && 
                    (cloudFile.TVA_CFB__Cloud_Public_Access_URL__c != NULL 
                     || cloudFile.TVA_CFB__Public_Short_URL__c != NULL ) 
                    && cloudFile.TVA_CFB__Password__c != NULL) {
                        
                    cloudFile.Email__c = emailAddress;
                    cloudFile.Send_Shareable_Email_Link__c = TRUE;
                    Database.Update (cloudFile, false);
                    returnMsg = 'Success';
                } else {
                    Integer len = 8;
                    Blob blobKey = crypto.generateAesKey(128);
                    String key = EncodingUtil.convertToHex(blobKey);
                    String pwd = key.substring(0, len);
                    TVA_CFB.GeneratePasswordProtectedLink obj = NEW TVA_CFB.GeneratePasswordProtectedLink ();
                    Map <ID, String> cloudFileDetails = NEW Map <ID, String> ();
                    cloudFileDetails .put (cloudFile.ID, pwd);
                    Map <String, String> resultsMap = obj.generateLink (cloudFileDetails);
                    
                    if (resultsMap.containsKey ('Failed')) {
                        returnMsg = resultsMap.get ('Failed');
                    }
                    else {
                        cloudFile.Send_Shareable_Email_Link__c = TRUE;
                        cloudFile.TVA_CFB__Password_Protect__c = True;
                        cloudFile.Email__c = emailAddress;
                        Update cloudFile;
                        returnMsg = 'Success';
                    }
    
                }
            }
            else {
                returnMsg = 'Unable to send an Email for more than 10 MB file.';
            }
            
            return returnMsg;
        }
        catch (Exception e) {
            return e.getMessage ();
        }
    }
}