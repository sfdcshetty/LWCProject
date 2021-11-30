//TestClassName: Docuvault_DD_ShareOnPortal_TC
global class Docuvault_DD_ShareOnPortal {
    private ApexPages.StandardSetController standardController;
    public  List<ID> cloudFileIDs {get; set;}
    public Integer count { get; set; }
    
    public Docuvault_DD_ShareOnPortal(ApexPages.StandardSetController stdController) {
        this.standardController = stdController;
        cloudFileIDs = NEW List <ID> ();
        for (TVA_CFB__Cloud_Files__c record: (List <TVA_CFB__Cloud_Files__c>)standardController.getSelected()) { 
            cloudFileIDs.add (record.Id);
        }
        count = cloudFileIDs.size ();
    }
    
    @RemoteAction
    public static String updateCloudFileRecords(List<Id> cloudFileIds) {
        String message = ''; 
        List<TVA_CFB__Cloud_Files__C> cloudFilesToUpdate = new List<TVA_CFB__Cloud_Files__c>();
        List<WEG_Document_Delivery__c> documentDeliveryToUpdate = new List<WEG_Document_Delivery__c> ();
        
        List<TVA_CFB__Cloud_Files__c> cloudFileRecords = [SELECT Name, CreatedById, Share_On_Portal__c, WEGP1_Household__c, 
                                                          WEGP1_Household__r.WEGP1_Primary_Individual__c, 
                                                          WEGP1_Household__r.WEGP1_Secondary_Individual__c, 
                                                          TVA_CFB__File_Size_in_Bytes__c, Portal_Folder__c, 
                                                          TVA_CFB__Bucket_Name__c, TVA_CFB__File_Type__c, WEG_Document_Name__c, 
                                                          TVA_CFB__Region__c, Send_Notification__c, Last_shared_on_Portal__c, 
                                                          Primary_Portal_User__c, Secondary_Portal_User__c 
                                                          FROM TVA_CFB__Cloud_Files__c WHERE Id IN : cloudFileIds];
        for(TVA_CFB__Cloud_Files__c  cloudFile : cloudFileRecords) {
            cloudFile.Share_On_Portal__c = true;
            cloudFilesToUpdate.add(cloudFile);
        }
        
        if(cloudFilesToUpdate.size() > 0) {
            update cloudFilesToUpdate;    
            System.debug('cloudFilesToUpdatecloudFilesToUpdate'+cloudFilesToUpdate);
        }
        
        if(cloudFilesToUpdate.size () > 1) {
            Database.executeBatch (new Docuvault_CreatePortalFile (cloudFileIds), 1);
        }
        
        for(WEG_Document_Delivery__c  documentDelivery : [SELECT WEG_Status__c, WEG_Document__c FROM WEG_Document_Delivery__c 
                                                          WHERE WEG_Document__c in : cloudFileIds]) 
        {
            for(TVA_CFB__Cloud_Files__c  cloudFile : cloudFileRecords) {
                if(documentDelivery.WEG_Document__c == cloudFile.Id) {
                    documentDelivery.WEG_Journal__c = cloudFile.WEGP1_Household__c;
                    documentDelivery.WEG_Primary_Individual__c = cloudFile.WEGP1_Household__r.WEGP1_Primary_Individual__c;
                    documentDelivery.WEG_Secondary_Individual__c = cloudFile.WEGP1_Household__r.WEGP1_Secondary_Individual__c;
                }
            }
            documentDelivery.WEG_Status__c= 'Published';
            documentDeliveryToUpdate.add(documentDelivery);                                        
        }
        
        if(documentDeliveryToUpdate .size() != null) {
            update documentDeliveryToUpdate ;    
        }
        return message;
    }    
}