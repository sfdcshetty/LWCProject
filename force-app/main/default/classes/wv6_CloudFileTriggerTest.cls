/******************************************************************************************************************************
 * Class Name    : wv6_CloudFileTriggerTest 
 * Description   : Contains test methods for apex wv6_CloudFileTrigger class.
 * Test class    : 
 * Author        : Rohan Lokhande 
 *  
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            04/11/2018            Created
******************************************************************************************************************************/
@isTest
private class wv6_CloudFileTriggerTest {
    
    @testSetup static void setupData() {
        CollaborationGroup newGroup = new CollaborationGroup(Name='Test Group',CollaborationType='Public');
        insert newGroup;
    }
    private static testMethod void testChatterPostOnDocumentUpload(){
        
        CollaborationGroup newGroup = [Select id,Name from CollaborationGroup where name = 'Test Group'];
        
        
        UserRole role=new UserRole(Name= 'ABC'); 
        insert role;
	    List<Profile> userProfiles1 = [Select id from Profile where Name = 'Advisor' limit 1];
        User advisorUser = wv6_TestFactory.getUser('ganesh@weg.com', userProfiles1[0].Id,role.Id,NULL);
        advisorUser.CSChatterGroup__c = newGroup.id;
        insert advisorUser;
	    
	    
	    Account indAcc; 
        Contact con;
        Account hhAcc;
        Document__c document1;
        system.runAs(advisorUser) {
            hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
            insert hhAcc;
            
            indAcc= new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
            insert indAcc;
            
            document1 = new Document__c();
            document1.Account__c = hhAcc.Id;
            insert document1;
    
            con = [SELECT Id  FROM Contact WHERE AccountId =: indAcc.Id]; 
        }    
    
        List<Profile> userProfiles = [Select id from Profile where Name = 'WEG Customer Community Plus' limit 1];
        
        system.assertEquals(userProfiles.size(), 1);
        
        User portalUser = wv6_TestFactory.getUser('ganesh1010@weg.com', userProfiles[0].Id,NULL,con.ID);
        insert portalUser;
        
        System.runAs(portalUser){
            
            TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c();
            cloudFile.Portal_Document__c = document1.id;
            insert cloudFile;
        }    
    }
}