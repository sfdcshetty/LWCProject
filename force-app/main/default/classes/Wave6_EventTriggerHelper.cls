/******************************************************************************************************************************
* @class nPMe    : Wave6_EventTriggerHelper
* @description   : THis class is used as Helper class for Wave6_EventTrigger. This classcontains method to convert provided date time into local time based on the provided timezone. 
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
*
******************************************************************************************************************************/
public class Wave6_EventTriggerHelper {
    private static string localDateTimeString ;
    private static list<string> strArr;
    private static Time localTime;
    
    public static string getLocalTime(DateTime dt, string timezone){
        
        localDateTimeString = dt.format('HH:mm:ss',timezone);  
        
        string str = 'AM';
        string localTimeStr='';
        
        strArr = new list<string>();
        if(localDateTimeString.contains(':')){
            strArr = localDateTimeString.split(':');
        }
        system.debug('strArr:>>'+strArr);
        if(!strArr.isEmpty()){
            if(strArr[0] == '12'){
               str = 'PM';
            }else if(strArr[0] == '13'){
               strArr[0] = '1'; 
               str = 'PM';
            }else if(strArr[0] == '14'){
               strArr[0] = '2';
               str = 'PM';
            }else if(strArr[0] == '15'){
               strArr[0] = '3'; 
               str = 'PM';
            }else if(strArr[0] == '16'){
               strArr[0] = '4'; 
               str = 'PM';
            }else if(strArr[0] == '17'){
               strArr[0] = '5'; 
               str = 'PM';
            }else if(strArr[0] == '18'){
               strArr[0] = '6'; 
               str = 'PM';
            }else if(strArr[0] == '19'){
               strArr[0] = '7'; 
               str = 'PM';
            }else if(strArr[0] == '20'){
               strArr[0] = '8'; 
               str = 'PM';
            }else if(strArr[0] == '21'){
               strArr[0] = '9'; 
               str = 'PM';
            }else if(strArr[0] == '22'){
               strArr[0] = '10'; 
               str = 'PM';
            }else if(strArr[0] == '23'){
               strArr[0] = '11'; 
               str = 'PM';
            }else if(strArr[0] == '00'){
               strArr[0] = '12'; 
            }
        }
        strArr[0] = strArr[0].replaceFirst( '^0+', '');
        localTimeStr = strArr[0]+':'+strArr[1]+' '+str;
        
        return localTimeStr;
    }
    
}