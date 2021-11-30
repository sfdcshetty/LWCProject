/******************************************************************************************************************************
 * Trigger Name  : wv6_SecureMessagingTrigger
 * Description   : 1. Before Insert - Update the Account lookup and Send to USer details when first time Community portal user creates the Secure
 *                                    message record.
 *                 2. After Insert  - Send Chatter post to Advisor's chatter group, when Secured Message record is created
 *
 * Test class    :
 * Author        : Rohan Lokhande
 *
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            03/21/2018             Created
 * Wave6                     10/12/2018             Replaced Account look-up on Secure Message with Contact
******************************************************************************************************************************/

trigger wv6_SecureMessagingTrigger on Secure_Messaging__c (before insert,after insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        String userType = userinfo.getUserType();
        system.debug('userinfo.getUserType()====>'+userinfo.getUserType());
        system.debug('---->'+Trigger.new);
        //Check if user is community user
        //if(userType == 'CSPLitePortal'){
        if(userType == 'PowerCustomerSuccess'){
            User usr = [select id,Contact.ID,Contact.AccountID,Contact.Account.OwnerID, Contact.Account.WEGP1_Primary_Household__c,
                        Contact.Account.WEGP1_Primary_Household__r.OwnerID, Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_CSM__c
                        from user where id=:userinfo.getUserId()];
            if(usr.Contact != NULL && usr.Contact.AccountID != NULL){  // && usr.Contact.Account.WEGP1_Primary_Household__c != NULL){
                if(Trigger.isBefore){
                    for(Secure_Messaging__c secureMsg : Trigger.new){
                        //If its null, means Contact id is not populated using reply functionality and is brand new secure message
                        if(secureMsg.Contact__c == NULL){
                            secureMsg.Contact__c = usr.Contact.ID;
                            secureMsg.Customer_User__c = usr.Contact.Account.WEGP1_Primary_Household__r.OwnerID;
                            //secureMsg.Customer_User__c = usr.Contact.Account.WEGP1_Primary_Household__c;
                            //secureMsg.OwnerId = usr.Contact.Account.WEGP1_Primary_Household__r.OwnerID;
                            secureMsg.Primary_CSM__c = usr.Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_CSM__c;
                            secureMsg.Household_Account__c = usr.Contact.Account.WEGP1_Primary_Household__c;
                        }
                        system.debug('secureMsg=======>'+secureMsg);
                    }
                }
            }
        }else {
            //When Advisor/Primary CSM creates the new message for Customer
            List<String> contactIDs = new List<String>();
            Map<String, User> contactIDUserIDMap = new Map<String, User>();
            for(Secure_Messaging__c secureMsg : Trigger.new){
                system.debug('====>'+secureMsg.Contact__c);
                if(String.isNotBlank(secureMsg.Contact__c)){
                    contactIDs.add(secureMsg.Contact__c);
                }
                
            }
            List<User> userList = [Select id,ContactID,Contact.AccountID,
                                Contact.Account.WEGP1_Primary_Household__c,
                                   Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_CSM__c
                                   from User
                                   where ContactID IN: contactIDs and isActive = TRUE];
            if(userList.size()>0){
                for(User usr : userList){
                    if(!contactIDUserIDMap.containsKey(usr.ContactID)){
                        contactIDUserIDMap.put(usr.ContactID,usr);
                    } 
                }
            }
            for(Secure_Messaging__c secureMsg : Trigger.new){
                if(contactIDUserIDMap.containsKey(secureMsg.Contact__c)){
                    secureMsg.Customer_User__c = contactIDUserIDMap.get(secureMsg.Contact__c).ID;
                    secureMsg.Household_Account__c = contactIDUserIDMap.get(secureMsg.Contact__c).Contact.Account.WEGP1_Primary_Household__c;
                    secureMsg.Primary_CSM__c = contactIDUserIDMap.get(secureMsg.Contact__c).Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_CSM__c;
                    system.debug('secureMsg.Customer_User__c==================>'+secureMsg.Customer_User__c);
                }else{
                    secureMsg.addError('Portal user not found. It is either inactive or does not exist.');
                }
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        system.debug('userinfo.getUserType()====>'+userinfo.getUserType());
        List <ComplianceArchivingHelper.IdListReturned> objList = new List <ComplianceArchivingHelper.IdListReturned> ();
        //if(userinfo.getUserType() == 'CSPLitePortal'){
        if(userinfo.getUserType() == 'PowerCustomerSuccess'){
            system.debug('entering AFTER PowerCustomerSuccess IF clause====>'+userinfo.getUserType());
            Map<String,String> mapUserIDChatterID = new Map<String,String>();
            List<String> advisorUserIds = new List<String>();
            List<String> portalUserIds = new List<String>();
            system.debug('sm====>'+Trigger.new);
            for(Secure_Messaging__c sm : Trigger.new){
                if(sm.Customer_User__c != NULL){
                    advisorUserIds.add(sm.Customer_User__c);
                    portalUserIds.add(sm.OwnerID);
                    ComplianceArchivingHelper.IdListReturned obj = new ComplianceArchivingHelper.IdListReturned ();
                    obj.returnedObj = 'Secure Message';
                    obj.returnIds = sm.ID;
                    objList.add (obj);
                }
            }

            if(advisorUserIds.size()>0){
                Map<String,user> mapCustomerIDRecord = new Map<String,user>([select id,CSChatterGroup__c,name,contact.Account.name from User where id IN:portalUserIds]);
                //List<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> lstSharingActionInputList =
                    //new List<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>();
                List<User> advisorList = [select id,CSChatterGroup__c from User where id IN:advisorUserIds];
                for(user usr : advisorList){
                    if(usr.CSChatterGroup__c != NULL){
                        if(!mapUserIDChatterID.containsKey(usr.ID)){
                            mapUserIDChatterID.put(usr.ID, usr.CSChatterGroup__c);
                        }
                    }
                }
                system.debug('=======>'+mapUserIDChatterID);
                List<FeedItem> feedItemList = new List<FeedItem>();
                for(Secure_Messaging__c sm : Trigger.new){
                    FeedItem post = new FeedItem();
                    post.Title = 'Secure Message link';
                    post.Body = 'Client has sent a new message through the Client Portal.';
                    post.LinkUrl = '/'+sm.ID;
                    post.ParentId = mapUserIDChatterID.get(sm.Customer_User__c);
                    feedItemList.add(post);
                    
                }
                if(feedItemList.size()>0){
                    try{
                        insert feedItemList;
                     }catch(exception e){
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }

            }
            system.debug('FIRING EMAIL FROM CLIENT====>'+userinfo.getUserType());
            ComplianceArchivingHelper.JournalSecureMessageFROMClient (Trigger.NEW, UserInfo.getUserID ());
            
            if (objList.size() > 0) {
                ComplianceArchivingHelper.createJournalRec (objList);
            }
            
        }
        else {
        // Secure Message to Client
        system.debug('FIRING EMAIL TO CLIENT====>'+userinfo.getUserType());

            ComplianceArchivingHelper.JournalSecureMessageToClient (Trigger.NEW);
            for(Secure_Messaging__c sm : Trigger.new){
                    ComplianceArchivingHelper.IdListReturned obj = new ComplianceArchivingHelper.IdListReturned ();
                    obj.returnedObj = 'Secure Message';
                    obj.returnIds = sm.ID;
                    objList.add (obj);
            }
                
            if (objList.size() > 0) {
                ComplianceArchivingHelper.createJournalRec (objList);
            }
        }
    }
}