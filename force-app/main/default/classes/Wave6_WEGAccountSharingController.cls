/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingController
* @description   : This class is used for ON DEMAND sharing recalculation. This class serves as controller for WEGAccountSharing lightning component.
*                  Lightning component is being used as quick action and will be added to Account Layouts so that user can re-calculate sharing by clicking on the button whenever required.
*
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/04/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/04/2017             Created.
* Ganesh Ekhande              09/19/2017             Updated code so that controller can be shared by actions for Trade_Request__c &  Plan_Review_Request__c.
* Santosh Rahane              10/11/2018             Updated the code to have the apex managed sharing for Secure Messaging object.
******************************************************************************************************************************/
public class Wave6_WEGAccountSharingController {

    /*
* @author       : Ganesh Ekhande
* @description  : Re-calculate sharing for child objects based on the current account team and their Account access level.
* @created      : 07/04/2017
* @param        : string recordId
* @return       : string
*/
    @AuraEnabled
    public static string recalculateSharing(Id recordId){

        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        system.debug('recordId:>>'+recordId);
        system.debug('sobjectName:>>'+sobjectName);

        string result;
        try{
            set<string> accIds =  new set<string>();
            if(sobjectName == 'Account'){
                accIds.add(recordId);
            }else if(sobjectName == 'Trade_Request__c') {
                list<Trade_Request__c> trList = [Select Id, WEGP1_Household__c, WEGP1_Individual__c From Trade_Request__c Where Id=: recordId Limit 1];

                if(!trList.isEmpty()){
                    if(trList[0].WEGP1_Household__c != null){
                        accIds.add(trList[0].WEGP1_Household__c);
                    }
                    if(trList[0].WEGP1_Individual__c != null){
                        accIds.add(trList[0].WEGP1_Individual__c);
                    }
                }
            }else if(sobjectName == 'Plan_Review_Request__c'){
                list<Plan_Review_Request__c> prrList = [Select Id, WEGP1_Household__c, WEGP1_Individual__c From Plan_Review_Request__c Where Id=: recordId Limit 1];

                if(!prrList.isEmpty()){
                    if(prrList[0].WEGP1_Household__c != null){
                        accIds.add(prrList[0].WEGP1_Household__c);
                    }
                    if(prrList[0].WEGP1_Individual__c != null){
                        accIds.add(prrList[0].WEGP1_Individual__c);
                    }
                }
            } else if(sobjectName.equalsignorecase('Secure_Messaging__c')){
                list<Secure_Messaging__c> smList = [Select Id, Household_Account__c From Secure_Messaging__c Where Id=: recordId Limit 1];
                if(!smList.isEmpty()){
                    if(smList[0].Household_Account__c != null){
                        accIds.add(smList[0].Household_Account__c);
                    }

                }
            }
            system.debug('accIds:>>'+accIds);

            list<Account> accList = new list<Account>();
            for(string accId : accIds){
                map<string,string> accTeamMemberIdToAccAccessMap = new map<string,string>();
                accTeamMemberIdToAccAccessMap = Wave6_WEGAccountSharingUtility.getAccountTeamMemberMap(accId);
                result = Wave6_WEGAccountSharingUtility.recalculateSharing(accId,accTeamMemberIdToAccAccessMap);
                if(result == 'SUCCESS'){
                    // Update WEGP1_AccountTeamIds__c field with current Account Team data
                    string accountTeamIds = '';
                    for(String userId : accTeamMemberIdToAccAccessMap.keySet()){
                        accountTeamIds += userId+':'+accTeamMemberIdToAccAccessMap.get(userId)+';';
                    }

                    Account acc = new Account(Id=accId,WEGP1_AccountTeamIds__c = accountTeamIds);
                    system.debug('acc:>>'+acc);
                    accList.add(acc);
                }
            }
            if(!accList.isEmpty()){
                database.update (accList,false);
            }
        }catch(exception ex){
            system.debug('Error:'+ex.getMessage());
        }
        return result;
    }
}