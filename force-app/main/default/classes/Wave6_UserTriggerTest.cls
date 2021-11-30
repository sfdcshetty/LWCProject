/******************************************************************************************************************************
* @class name    : Wave6_UserTriggerTest
* @description   : This class provides unit tests for Wave6_UserTrigger. 
* @author        : Ganesh Ekhande
* @date          : 08/02/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              08/02/2017             Created.
*
******************************************************************************************************************************/
@isTest
private class Wave6_UserTriggerTest {

	private static testMethod void test() {
            Group g1 = new Group(Name='Allee Team', type='Queue');
            insert g1;
            
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            
            User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
             LastName = 'last',
             Email = 'wegUser@weg.com',
             Username = 'wegUser@weg.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             Support_Team__c='Allee Team',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US');
             
             insert u;
	}
}