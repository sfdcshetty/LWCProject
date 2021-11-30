/******************************************************************************************************************************
 * Class Name    : wv6_NewAndReplyToSMCtrlTest 
 * Description   : Contains test methods for apex wv6_NewAndReplyToSM class.
 * Test class    : 
 * Author        : Rohan Lokhande
 *  
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            04/11/2018            Created
******************************************************************************************************************************/
@IsTest
private class wv6_NewAndReplyToSMCtrlTest {

    @IsTest
    private static void testRepliesFromCustomerAndAdvisor() {
	    
	    UserRole role=new UserRole(Name= 'ABC'); 
        insert role;
	    List<Profile> userProfiles1 = [SELECT Id FROM Profile WHERE Name = 'Advisor' LIMIT 1];
        User advisorUser = wv6_TestFactory.getUser('ganesh@weg.com', userProfiles1[0].Id,role.Id,null);
        insert advisorUser;
	    
	    
	    Account indAcc; 
        Contact con;
        System.runAs(advisorUser) {
            Account hhAcc = new Account(Name='HH Account1', RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
            insert hhAcc;
            
            indAcc= new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
            insert indAcc;

            con = [SELECT Id  FROM Contact WHERE AccountId =: indAcc.Id];
        }
        
        List<Profile> userProfiles = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' LIMIT 1];
        System.assertEquals(userProfiles.size(), 1);
        User portalUser = wv6_TestFactory.getUser('ganesh1010@weg.com', userProfiles[0].Id,null,con.Id);
        insert portalUser;

        Secure_Messaging__c SM;
        Secure_Messaging__c clonedSM;
        System.runAs(portalUser){
            //Customer Sends Message to Advisor
            SM = wv6_TestFactory.getSecureMessage(null);
            insert SM;
            
            //Customer replies to his own Message -- message goes to advisor
            clonedSM = wv6_NewAndReplyToSMCtrl.getClonedRecord(SM.Id);
            wv6_NewAndReplyToSMCtrl.saveSMRecord(JSON.serialize(clonedSM));
        }
        
        //Advisor replies to Customer's Message
        System.runAs(advisorUser) {
            SM = wv6_TestFactory.getSecureMessage(con.Id);
            insert SM;
            
            clonedSM = wv6_NewAndReplyToSMCtrl.getClonedRecord(SM.Id);
            insert clonedSM;
        }
        
        System.runAs(portalUser){
            // Reply to Advisor's Message fron customer
            Secure_Messaging__c custReply = wv6_NewAndReplyToSMCtrl.getClonedRecord(clonedSM.Id);
            wv6_NewAndReplyToSMCtrl.saveSMRecord(JSON.serialize(custReply));
        }
	}
}