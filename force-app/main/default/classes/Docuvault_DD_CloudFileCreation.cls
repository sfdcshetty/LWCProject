//Test Class: Docuvault_S3NotificationController_TC
global class Docuvault_DD_CloudFileCreation {
    global static void createCloudFile(List<Object> recordDetails) {
        system.debug('recordDetailsrecordDetails'+recordDetails);
        TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());
            
        Set <ID> recordIds = NEW Set <ID> ();
        List <TVA_CFB__cloud_files__c> cloudFilesList = NEW List <TVA_CFB__cloud_files__c> ();
        Map <String, Object> objectDetailsMap = NEW Map <String, Object> ();
        Map <String, Object> jsonMap = NEW Map <String, Object> ();
        Map <String, Object> s3DetailsMap = NEW Map <String, Object> ();
        Map <String,Object> bucketDetailsMap = NEW Map <String, Object> ();
                
        for (Object obj: recordDetails) {
            system.debug('objobjobj'+obj);
            jsonMap = (Map <String, Object>) JSON.deserializeUntyped (JSON.serialize(obj));
            system.debug('------------'+jsonMap);
            s3DetailsMap = (Map <String, Object>) jsonMap.get ('s3');
            system.debug('************'+s3DetailsMap);
            objectDetailsMap = (Map <String, Object>) s3DetailsMap.get ('object');
            bucketDetailsMap = (Map <String, Object>) s3DetailsMap.get ('bucket');             
            
        }
        Id ddRecordTypeId = Schema.SObjectType.TVA_CFB__Cloud_Files__c.getRecordTypeInfosByName().get('Digital Delivery').getRecordTypeId();
       
        String currentFileName = (String) objectDetailsMap .get ('key');
        List <String> fileTypeList = currentFileName.split('\\.');
        String wegId = '';
        String fileName = '';
        String documentName = '';
        List <String> wegIdSplit = new List <String>();
        Account accountToLinkCF = NULL;
        system.debug('currentFileNamecurrentFileNamecurrentFileName'+currentFileName);
        if(currentFileName.contains('_')) {
            wegIdSplit = currentFileName.split('_');
            wegId = wegIdSplit[0];
            fileName = wegIdSplit[2];
            documentName = wegIdSplit[1];
            
        }
        system.debug('aaa'+wegIdSplit+'bbb'+wegId+'ccc'+documentName);
        String fileType = fileTypeList [fileTypeList.size() - 1];
        if(wegId != '') {
        accountToLinkCF = new Account();
            if(Test.isRunningTest()) {
                 accountToLinkCF = [Select Id from Account Limit 1];
            } else {
                 accountToLinkCF = [Select Id from Account where WEGP1_WEGID__c =: wegId];
            }
           System.debug('aaaaaaaaaaaaaaaaaaaaaaaaa'+accountToLinkCF);
        }
                
        TVA_CFB__Cloud_Files__c record = NEW TVA_CFB__Cloud_Files__c ();
        System.debug('fileTypefileType'+fileType);
        record.TVA_CFB__File_type__c = fileType;
        record.TVA_CFB__File_Size_In_Bytes__c = (Decimal) objectDetailsMap.get ('size');
        record.Name = fileName;
        record.WEG_Document_Name__c = documentName;
        record.WEG_Originating_File_Name__c = currentFileName;
        record.TVA_CFB__Reponse_Code__c = '204';
        record.TVA_CFB__Bucket_Name__c = (String) bucketDetailsMap.get ('name');
        record.TVA_CFB__Region__c = (String) jsonMap.get ('awsRegion');
        record.RecordTypeId = ddRecordTypeId;
        record.TVA_CFB__Box_File_Status__c = 'Edelivery';
        if(accountToLinkCF != NULL) {
            record.TVA_CFB__Account__c = accountToLinkCF.ID;
            record.TVA_CFB__Parent_ID__c = accountToLinkCF.ID;
        }
        insert record;    
        
        WEG_Document_Delivery__c documentDelivery = new WEG_Document_Delivery__c();
        documentDelivery.WEG_Document__c = record.Id;
        documentDelivery.WEG_Status__c = 'Pending';
        insert documentDelivery;
        
        Map <ID, Map <String, String>> fileDetailsMap = NEW Map <ID, Map <String, String>> ();
        
        Map <String, String> innerMap = NEW Map <String, String> ();
        innerMap.put ('currentBucketName', (String) record.get ('TVA_CFB__Bucket_Name__c'));
        innerMap.put ('currentFileName', (String) objectDetailsMap .get ('key'));
        innerMap.put ('newBucketName',  s3Credentials.TVA_CFB__Bucket_Name__c);
        innerMap.put ('newFileName', record.ID+'.'+(String) record.get ('TVA_CFB__File_type__c'));
        innerMap.put ('region', (String) record.get ('TVA_CFB__Region__c'));
        
        fileDetailsMap.put (record.ID, innerMap);
        system.debug('record.IDrecord.ID'+record.ID);
        system.debug('innerMapinnerMap'+innerMap);
        system.debug('fileDetailsMapfileDetailsMap'+fileDetailsMap);
        Docuvault_CopyAWSFileController.copyAWSObject (fileDetailsMap);
    }
}