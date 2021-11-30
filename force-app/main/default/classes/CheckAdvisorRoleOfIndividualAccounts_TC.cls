@isTest
public class CheckAdvisorRoleOfIndividualAccounts_TC {
    static testMethod void Check(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account acc = New Account ();
        acc.recordTypeId = accRecordTypeId;
        acc.Name = 'testAccount';
        insert acc;
        
        Test.startTest(); 
        Account_OwnerProfileRole_Scheduler sh1 = new Account_OwnerProfileRole_Scheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        
        CheckAdvisorRoleOfIndividualAccounts obj = new CheckAdvisorRoleOfIndividualAccounts();
        database.executebatch(obj);           
        Test.stopTest();   
    
    }    
    
}