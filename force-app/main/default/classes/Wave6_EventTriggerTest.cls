/******************************************************************************************************************************
* @class name    : Wave6_EventTriggerTest
* @description   : This class provides unit test for Wave6_EventTrigger & Wave6_EventTriggerHelper. 
*                  
* @author        : Ganesh Ekhande
* @date          : 09/26/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              09/26/2017             Created.
* Ganesh Ekhande              09/27/2017             Added testEventDelete
******************************************************************************************************************************/
@isTest
private class Wave6_EventTriggerTest {

    private static testMethod void testEventInsertUpdate() { 
        
        Event ev = new Event();
        ev.Subject = 'Product Launch';
        ev.Time_Zone__c = 'America/New_York';
        ev.StartDateTime = System.now();
        ev.EndDateTime = System.now().addDays(2);
        insert ev;
        
        Event ev1 = [Select Id, WEGP1_Local_Start_Time__c, WEGP1_Local_End_Time__c From Event Where Id =:ev.Id]; 
        system.assertNotEquals(null, ev1.WEGP1_Local_Start_Time__c);
        system.assertNotEquals(null, ev1.WEGP1_Local_End_Time__c);
        
        ev.Time_Zone__c = 'America/Los_Angeles';
        update ev;
        
        Event ev2 = [Select Id, WEGP1_Local_Start_Time__c, WEGP1_Local_End_Time__c From Event Where Id =:ev.Id];
        system.assertNotEquals(ev1.WEGP1_Local_End_Time__c, ev2.WEGP1_Local_End_Time__c);
    }
    
    private static testMethod void testEventDelete() {
        Event ev = new Event();
        ev.Subject = 'Product Launch';
        ev.Time_Zone__c = 'America/New_York';
        ev.StartDateTime = System.now();
        ev.EndDateTime = System.now().addDays(2);
        ev.WEGP1_MeetingType__c = 'Needs Analysis';
        insert ev;    
        
        try{
            delete ev;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot delete this event since the Meeting Type equals Needs Analysis.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);    
        }
    }
    
    
    private static testMethod void testGetLocalTime(){
        string timezone = 'America/Chicago';
        DateTime dt = System.now();
        
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
        Wave6_EventTriggerHelper.getLocalTime(dt,timeZone);
        dt = dt.addHours(1);
       
    }
}