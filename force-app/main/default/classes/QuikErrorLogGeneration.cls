public class QuikErrorLogGeneration {
    public static void createErrorLog(String requestBody, String responseBody, String envpId, String errorInfo,String className, String methodName, integer lineNumber) {
        System.debug(':::errorLog:: envpId:: ' + envpId);
        QuikSign_Error_Log__c errorLog = new QuikSign_Error_Log__c();
        errorLog.Request_Body__c = requestBody;
        errorLog.Response_Body__c = responseBody;
        errorLog.Error_Message__c = errorInfo;
        errorLog.Class_Name__c = className;
        errorLog.Method_Name__c = methodName;
        if(lineNumber != null){
            errorLog.Line_Number__c = string.valueOf(lineNumber);
        }
        List<AS_Quik_Forms_Group__c> aqfc = new List<AS_Quik_Forms_Group__c>();
        String quickFormName = '';
        String quickFormId = '';
        if(envpId != '' && envpId != null) {
            aqfc = [SELECT Id, Name, Docusign_Envelope_Id__c FROM AS_Quik_Forms_Group__c 
                    WHERE Docusign_Envelope_Id__c = :envpId LIMIT 1];
            if(aqfc.size() > 0) {
                System.debug(':::aqfc:: ' + aqfc[0]);
                errorLog.AS_Quik_Forms_Group__c = aqfc[0].Id;
                quickFormName = aqfc[0].Name;
                quickFormId = aqfc[0].Id;
            }
        }
        insert errorLog;
        System.debug(':::errorLog:: Id:: ' + errorLog.Id);
        
    }
    
}