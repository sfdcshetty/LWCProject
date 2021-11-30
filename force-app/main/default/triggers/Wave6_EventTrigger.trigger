/******************************************************************************************************************************
* @trigger name  : Wave6_EventTrigger
* @description   : This trigger is used to convert event start date time and end date time into local time based on the Time_Zone__c 
*                  and updateLocalStartTime__c and LocalEndTime__c fields with calculated local time.
*                  
* @test class    : Wave6_EventTriggerTest
* @author        : Ganesh Ekhande
* @date          : 09/26/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              09/26/2017             Created.
* Ganesh Ekhande              09/27/2017             Added logic to pevent event deletion when WEGP1_MeetingType__c == 'Needs Analysis'
*
******************************************************************************************************************************/
trigger Wave6_EventTrigger on Event (before insert, before update, before delete) {
    
    if(!trigger.isDelete){
        for(Event ev : trigger.new){
            if(ev.Time_Zone__c == null)
                ev.Time_Zone__c = 'America/Chicago';
            if(!ev.IsAllDayEvent){                
                if(ev.StartDateTime == null)            
                    ev.StartDateTime = ev.ActivityDateTime;
                if(ev.EndDateTime == null)
                    ev.EndDateTime = ev.ActivityDateTime.addMinutes(ev.DurationInMinutes);
                
                if(trigger.isInsert){
                    ev.WEGP1_Local_Start_Time__c = Wave6_EventTriggerHelper.getLocalTime(ev.StartDateTime, ev.Time_Zone__c);
                    ev.WEGP1_Local_End_Time__c = Wave6_EventTriggerHelper.getLocalTime(ev.EndDateTime, ev.Time_Zone__c);
                    
                }else if(trigger.isUpdate){
                    list<string> strArr = new list<string>();
                    if(ev.StartDateTime != trigger.oldMap.get(ev.Id).StartDateTime || ev.Time_Zone__c != trigger.oldMap.get(ev.Id).Time_Zone__c){
                        ev.WEGP1_Local_Start_Time__c = Wave6_EventTriggerHelper.getLocalTime(ev.StartDateTime, ev.Time_Zone__c);
                    }
                    if(ev.EndDateTime != trigger.oldMap.get(ev.Id).EndDateTime || ev.Time_Zone__c != trigger.oldMap.get(ev.Id).Time_Zone__c){
                        ev.WEGP1_Local_End_Time__c = Wave6_EventTriggerHelper.getLocalTime(ev.EndDateTime, ev.Time_Zone__c);
                    }
                }
            }else{
                ev.WEGP1_Local_Start_Time__c = null;
                ev.WEGP1_Local_End_Time__c = null;
            }            
        }
    }else{
        for(Event ev : trigger.old){
            if(ev.WEGP1_MeetingType__c == 'Needs Analysis'){
                ev.addError('You cannot delete this event since the Meeting Type equals Needs Analysis.');
            }   
        }    
    }
}