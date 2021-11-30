@isTest
public class WEG_CloudFileTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        
        // set the custom setting to bypass validation (Wave6 Custom Hierarchy Custom Setting)
        Wave6_BoltCloudFileFieldLockdown__c settings = Wave6_BoltCloudFileFieldLockdown__c.getOrgDefaults();
        settings.Bypass_Validation_Rule__c = true;
        upsert settings Wave6_BoltCloudFileFieldLockdown__c.Id;
        
        // create the generic comp plan
        WEG_Compensation_Plan__c generalPlan = new WEG_Compensation_Plan__c(Name = 'WEG Matrix');
        insert generalPlan;
        
        // create a household
        Account hhAcc = new Account(Name = 'Tim and Paul Allen', Type = 'Prospect', FinServ__Status__c = 'Deceased'
                                    , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc;
        
        // create a business
        Account bizAcc = new Account(Name = 'Tim and Paul Business'
                                    , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert bizAcc;
        
        // create a cloud file
        TVA_CFB__Cloud_Files__c cf1 = new TVA_CFB__Cloud_Files__c(Name = 'Test 1', WEGP1_Household__c = hhAcc.Id);
        insert cf1;
        
        // update 1
        cf1.WEGP1_RIACompliant__c = 'Pending (Action Required)';
        cf1.WEGP1_Stage_Change_Note__c = 'Note 1';
        update cf1;
        
        // update 2
        cf1.WEG_Signed_Date__c = Date.newInstance(2019, 1, 1);
        cf1.WEGP1_Principal_Review_Final_Status__c = 'Approved (In Good Order)';
        cf1.WEGP1_Stage_Change_Note__c = 'Note 2';
        update cf1;
        
        // create a business cloud file
        TVA_CFB__Cloud_Files__c cf2 = new TVA_CFB__Cloud_Files__c(Name = 'Test 2', Business__c = bizAcc.Id, WEG_Signed_Date__c = Date.newInstance(2019, 1, 1)
                                                                  , WEGP1_Principal_Review_Final_Status__c = 'Approved (In Good Order)');
        insert cf2;
        
        // update it to household
        cf2.WEGP1_Household__c = hhAcc.Id;
        update cf2;
        
        // remove the household
        cf2.WEGP1_Household__c = null;
        update cf2;
        
        // finally, create an system admin user to test stoppage
        User apiUser = new User(
            LastName = 'Test',
            Email = 'cloudfiletestuser@test.com',
            Username = 'cloudfiletestuser@test.com',
            Alias = 'alias',
            CompanyName = 'Cloud File Test User',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert apiUser;
        
        // create a household and cloud file as api user to test stoppage
        System.runAs(apiUser) {
            // create a household
            Account apiHH = new Account(Name = 'Tim and Paul Jones', Type = 'Prospect'
                                        , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
            insert apiHH;
            
            // create a cloud file
            TVA_CFB__Cloud_Files__c apiCF = new TVA_CFB__Cloud_Files__c(Name = 'Test 3', WEGP1_Household__c = apiHH.Id);
            insert apiCF;
        }
        
        test.stopTest();
    }
}