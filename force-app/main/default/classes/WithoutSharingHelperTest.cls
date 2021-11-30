@isTest
public with sharing class WithoutSharingHelperTest {
    @istest
    public static void updateTest1() {
        interaction__c i = new interaction__c();
        i.name = 'test';
        insert i;

        i.name = 'test2';
        WithoutSharingHelper.updateRecords(new List<Interaction__c>{ i });
    }
}