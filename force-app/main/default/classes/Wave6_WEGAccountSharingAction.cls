/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingAction
* @description   : This is class contains invokable method which is used to share child object record with Househodl/Individual account teams.
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/07/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/07/2017             Created.
* Ganesh Ekhande              11/13/2017             Added code to enable Account Team Sharing for Blot object.
* Santosh Rahane              10/11/2018             Added code to enable Account team sharing for Secure Messaging object.
******************************************************************************************************************************/
public without sharing class Wave6_WEGAccountSharingAction {
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method which is used to share child object record with Househodl/Individual account teams.
    * @created      : 07/07/2017
    * @param        : list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList
    * @return       : void
    */
    @InvocableMethod(label='Wave6_WEGAccountSharingAction')
    public static void Wave6_WEGAccountSharingAction(list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList){
        system.debug('sharingActionInputList:>>'+sharingActionInputList);

        try{
            // Seperate out records based on the object type
            map<string,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>> sharingActioninputMap = new map<string,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>>();
            map<string,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>> sharingActioninputDeleteMap = new map<string,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>>();

            for(Wave6_WEGAccountSharingAction.SharingActionInputWrapper input : sharingActionInputList){

                if(!input.isAccRemoved){
                    if(sharingActioninputMap.containsKey(input.objectType)){
                        sharingActioninputMap.get(input.objectType).add(input);
                    }else{
                        sharingActioninputMap.put(input.objectType, new list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>{input});
                    }
                }else{
                    if(sharingActioninputDeleteMap.containsKey(input.objectType)){
                        sharingActioninputDeleteMap.get(input.objectType).add(input);
                    }else{
                        sharingActioninputDeleteMap.put(input.objectType, new list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper>{input});
                    }
                }
            }
            system.debug('sharingActioninputMap:>>'+sharingActioninputMap);
            system.debug('sharingActioninputDeleteMap:>>'+sharingActioninputDeleteMap);

            // Create sharing records
            if(sharingActioninputMap.size()>0){
                for(string objectType : sharingActioninputMap.keySet()){
                    string shareObject = identifyShareObject(objectType);
                    Wave6_WEGAccountSharingUtility.CreateSharingRecords(shareObject, sharingActioninputMap.get(objectType));
                }
            }

            // Delete sharing records
            if(sharingActioninputDeleteMap.size()>0){
                for(string objectType : sharingActioninputDeleteMap.keySet()){
                    string shareObject = identifyShareObject(objectType);
                    Wave6_WEGAccountSharingUtility.DeleteSharingRecords(shareObject, sharingActioninputDeleteMap.get(objectType));
                }
            }

        }catch(exception ex){
            system.debug('Error:'+ex.getMessage());
        }
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : set ShareObject name based on the object type.
    * @created      : 07/07/2017
    * @param        : string objectType
    * @return       : string
    */
    public static string identifyShareObject(string objectType){
        string shareObject;
        if(objectType == 'Financial Account'){
            shareObject = 'FinServ__FinancialAccount__Share';
        }else if(objectType == 'Assets and Liabilities'){
            shareObject = 'FinServ__AssetsAndLiabilities__Share';
        }else if(objectType == 'Trade Request'){
            shareObject = 'Trade_Request__Share';
        }else if(objectType == 'Plan & Review Request'){
            shareObject = 'Plan_Review_Request__Share';
        }else if(objectType == 'Cloud Files'){
            shareObject = 'TVA_CFB__Cloud_Files__Share';
        }else if(objectType == 'Financial Goal'){
            shareObject = 'FinServ__FinancialGoal__Share';
        }else if(objectType == 'Individual Account'){
            shareObject = 'AccountShare';
        }else if(objectType == 'Blot'){
            shareObject = 'Blot__Share';
        }else if(objectType.equalsIgnoreCase('Secure Message')){
            shareObject = 'Secure_Messaging__Share';
        }
        return shareObject;
    }


    /*
    * @author       : Ganesh Ekhande
    * @description  : Inner wrapper class which wraps different inputs required for Wave6_WEGAccountSharingAction
    * @created      : 07/07/2017
    */
    public class SharingActionInputWrapper {
        @InvocableVariable(label='Record Id' description='Required. The Id of the record.' required=true)
        public string recordId;

        @InvocableVariable(label='Object Type' description='Required. Object Type' required=true)
        public String objectType;

        @InvocableVariable(label='Account Id' description='Required. Parent Account Id' required=true)
        public String accountId;

        @InvocableVariable(label='Sharing Reason' description='Required. Sharing Reason' required=true)
        public String sharingReason;

        @InvocableVariable(label='Is Account Removed' description='Required. Is Account Removed' required=true)
        public boolean isAccRemoved;
    }
}