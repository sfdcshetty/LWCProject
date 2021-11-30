@isTest
public class checkOwnershipofAccounts_TC{
    static testMethod Void TestAccounts(){
        RecordType__mdt recordType = new RecordType__mdt();
            recordtype = [Select Name__c,Profile__c from RecordType__mdt where profile__c =: System.Label.Profile_Name limit 1];
        
        String Profile = recordtype.profile__c;
            
        Map <String, RecordType__mdt> recordTypeMetadata = new Map<String, RecordType__mdt> ();
            recordTypeMetadata.put(recordtype.Name__c,recordtype);
    
            
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <200;i++)
        {
            Account acc = new Account();
            acc.Name ='Name';
            
            lstaccount.add(acc);
        }
        
        insert lstAccount;
        
        Test.startTest(); 
        
            checkOwnershipofAccounts obj = new checkOwnershipofAccounts();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();   
        
    }
}