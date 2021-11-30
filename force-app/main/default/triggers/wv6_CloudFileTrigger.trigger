trigger wv6_CloudFileTrigger on TVA_CFB__Cloud_Files__c (after update) {
    if(userinfo.getUserType() == 'CSPLitePortal' || userinfo.getUserType() == 'PowerCustomerSuccess'){ 
        
        List<String> protalIds = new List<String>();
        List<ID> userIDs = new List<ID>();
        for(TVA_CFB__Cloud_Files__c cloudFile: Trigger.new){
            protalIds.add(cloudFile.Portal_Document__c);
            userIDs.add(cloudFile.ownerID);
        }
        
        try{
            if(protalIds.size()>0){
                Map<String,Document__c> documentIDRecMap = new Map<String,Document__c>([Select id, Account__c, Account__r.OwnerID, Account__r.Owner.CSChatterGroup__c,Account__r.Owner.name from Document__c where id IN: protalIds]);
                
                Map<String,User> userMap = new Map<String,User>([Select id,name from user where ID IN: userIDs]);
                
                List<FeedItem> feedItemList = new List<FeedItem>();
                for(TVA_CFB__Cloud_Files__c cloudFile: Trigger.new) {
                    TVA_CFB__Cloud_Files__c oldCloudFile = Trigger.oldMap.get(cloudFile.Id);
                    if(((oldCloudFile.TVA_CFB__E_Tag__c == null || oldCloudFile.TVA_CFB__E_Tag__c == '') && cloudFile.TVA_CFB__E_Tag__c != null && cloudFile.TVA_CFB__E_Tag__c != '') 
                       || Test.isRunningTest()) {
                        if(documentIDRecMap.containsKey(cloudFile.Portal_Document__c)){
                            Document__c doc = documentIDRecMap.get(cloudFile.Portal_Document__c);
                            if(doc.Account__c != NULL && doc.Account__r.Owner.CSChatterGroup__c != NULL){
                                FeedItem post = new FeedItem();
                                post.Title = 'Cloud File link';
                                post.Body = userMap.get(cloudFile.OwnerID).name +' has uploaded a new document to the Client Portal.';  //+ ' for Account '+ mapCustomerIDRecord.get(sm.ownerID).contact.Account.name;
                                post.LinkUrl = '/'+cloudFile.ID;
                                post.ParentId = doc.Account__r.Owner.CSChatterGroup__c; 
                                feedItemList.add(post);
                            }
                        }
                    }
                }
                
                if(feedItemList.size()>0){
                    insert feedItemList;
                }
            }
        }catch(exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
}