public without sharing class x7sPersonalPropertyController {
    Public class PropertyWrapper{
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String Type { get; set; }
    @AuraEnabled public String Owner { get; set; }
    @AuraEnabled public Date AsOfDate { get; set; }
    @AuraEnabled public Decimal Amount { get; set; }
}
@AuraEnabled (cacheable=true)
public static List<FinServ__AssetsAndLiabilities__c> getPersonalPropertyDetails(String accountId){
    List<PropertyWrapper> lstWrap = new List<PropertyWrapper>();
    List<FinServ__AssetsAndLiabilities__c> personalProList;
    List<Account> accList;
    PropertyWrapper propertyWrapper = new PropertyWrapper();
    if(accountId != null){
        accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                 From Account 
                                 WHERE Id =: accountId LIMIT 1];
    }
    if( accList != null && accList.size() > 0 && accList[0].WEGP1_Primary_Household__c != null){
        personalProList = [SELECT Id,Name,FinServ__Amount__c,FinServ__AssetsAndLiabilitiesType__c,WEGP1_AsOfDate__c,FinServ__Household__c,
                           FinServ__Household__r.WEGP1_Primary_Individual__c,FinServ__Household__r.WEGP1_Primary_Individual__r.Name,
                            FinServ__Household__r.WEGP1_Primary_Individual__r.AccountId, FinServ__Household__r.WEGP1_Secondary_Individual__r.AccountId,
                           FinServ__Household__r.WEGP1_Secondary_Individual__c,FinServ__Household__r.WEGP1_Secondary_Individual__r.Name,
                           WEGP1_Owner_Type__c, FinServ__PrimaryOwner__c, FinServ__JointOwner__c
                           FROM FinServ__AssetsAndLiabilities__c 
                           WHERE FinServ__Household__c = :accList[0].WEGP1_Primary_Household__c
                           AND RecordType.Name IN('Asset') 
                           AND Remove_or_Historic__c = ''
                           AND Status__c = 'Open'
                           AND WEGP1_ExcludeFromReview__c = FALSE
                           AND FinServ__AssetsAndLiabilitiesType__c IN ('Automobile','Jewelry','Real Estate - Personal')];
    }
    return personalProList;
}
@AuraEnabled(cacheable=true)
public static List<String> getPropertyType() {
    List<String> pickListValuesList= new List<String>();
    Schema.DescribeFieldResult fieldResult = FinServ__AssetsAndLiabilities__c.FinServ__AssetsAndLiabilitiesType__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
for(Schema.PicklistEntry pickListVal : ple){
        if((pickListVal.getValue() == 'Automobile') || (pickListVal.getValue() == 'Jewelry') || (pickListVal.getValue() == 'Real Estate - Personal')) {
            pickListValuesList.add(pickListVal.getValue());
        }
    }
return pickListValuesList;
}
@AuraEnabled
public static void editProperty(String propertyId,String accountId,String propertyInfo) {
    List<FinServ__AssetsAndLiabilities__c> propertyList;
    List<PropertyWrapper> lstWrap = new List<PropertyWrapper>();
    PropertyWrapper newProperty;
    List<Account> accList;
    List<RecordType> recType = new List<RecordType>();
    recType = [SELECT Id, Name FROM RecordType Where Name IN('Asset') LIMIT 1];
    System.debug('propertyInfo='+propertyInfo);

    if(propertyInfo != null){
        newProperty = (PropertyWrapper) JSON.deserialize(propertyInfo, PropertyWrapper.class);
    }
    if(accountId != null){
        accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
        From Account
        WHERE Id =: accountId LIMIT 1];
    }


    propertyList = [SELECT Id,Name,FinServ__Amount__c,FinServ__AssetsAndLiabilitiesType__c, FinServ__PrimaryOwner__c, WEGP1_AsOfDate__c, WEGP1_Owner_Type__c
                              FROM FinServ__AssetsAndLiabilities__c 
                         WHERE Id =:propertyId LIMIT 1];

    List<Account> origOwner;
    if(propertyList[0].WEGP1_Owner_Type__c != 'Joint'){
        origOwner = [SELECT Id, Name From Account 
                                WHERE Id =: propertyList[0].FinServ__PrimaryOwner__c LIMIT 1];
    }

    List<Account> newOwner;
    if( newProperty.Owner != 'Joint' ){
        newOwner = [SELECT Id, Name From Account 
                            WHERE Id =: newProperty.Owner LIMIT 1];
    }

    String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
    if((newProperty.Name  != null) && (newProperty.Name  != propertyList[0].Name)){chatterBody += 'Personal Property Name: ' + propertyList[0].Name + ' => ' + newProperty.Name +'\n';}
    if((newProperty.Type  != null) && (newProperty.Type  != propertyList[0].FinServ__AssetsAndLiabilitiesType__c)){chatterBody += 'Personal Property Type:' + propertyList[0].FinServ__AssetsAndLiabilitiesType__c + ' => ' + newProperty.Type +'\n';}
    
    //if((newProperty.Owner  != null) && newProperty.Owner != 'Joint' && (newProperty.Owner  != propertyList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + propertyList[0].FinServ__PrimaryOwner__c + '=>' + newProperty.Owner +'\n';}
    //if((newProperty.Owner  != null) && newProperty.Owner == 'Joint') {chatterBody += 'Owner: ' + newProperty.Owner + ' => Joint Ownership \n';}
    if((newProperty.Owner  != null) && newProperty.Owner != 'Joint') {
        if(propertyList[0].WEGP1_Owner_Type__c != 'Joint'){
            chatterBody += 'Owner: ' + origOwner[0].Name + ' => ' + newOwner[0].Name +'\n';
        }else{
            chatterBody += 'Owner: ' + 'Joint' + ' => ' + newOwner[0].Name +'\n';
        }
    }

    // if((newProperty.Owner  != null) && newProperty.Owner == 'Joint') {
    //     chatterBody += 'Owner: ' + origOwner[0].Name + ' =>  Joint  \n';
    // }

    if((newProperty.AsOfDate  != null) && (newProperty.AsOfDate  != propertyList[0].WEGP1_AsOfDate__c)){chatterBody += 'As Of Date: ' + propertyList[0].WEGP1_AsOfDate__c + ' => ' + newProperty.AsOfDate +'\n';}
    if((newProperty.Amount  != null) && (newProperty.Amount  != propertyList[0].FinServ__Amount__c)){chatterBody += 'Amount: ' + propertyList[0].FinServ__Amount__c + ' => ' + newProperty.Amount +'\n';}
    
    propertyList[0].Name = newProperty.Name;
    System.debug('newProperty.Type' + newProperty.Type);
    propertyList[0].FinServ__AssetsAndLiabilitiesType__c = newProperty.Type;
    if(newProperty.Owner == 'Joint') {
        String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
        String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
        propertyList[0].FinServ__PrimaryOwner__c = primary;
        propertyList[0].FinServ__JointOwner__c = secondary;
    } else {
        propertyList[0].FinServ__PrimaryOwner__c = newProperty.Owner;
        propertyList[0].FinServ__JointOwner__c = null;
    }
    propertyList[0].WEGP1_AsOfDate__c = newProperty.AsOfDate;
    propertyList[0].FinServ__Amount__c = newProperty.Amount;
    update propertyList; 
    x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
    input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
    input.userId = UserInfo.getUserId();
    /*String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
    if((newProperty.Name  != null) && (newProperty.Name  != propertyList[0].Name)){chatterBody += 'Personal Property Name: ' + newProperty.Name +'\n';}
    if((newProperty.Type  != null) && (newProperty.Type  != propertyList[0].FinServ__AssetsAndLiabilitiesType__c)){chatterBody += 'Personal Property Type:' + newProperty.Type +'\n';}
    if((newProperty.Owner  != null) && newProperty.Owner != 'Joint' && (newProperty.Owner  != propertyList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + propertyList[0].FinServ__PrimaryOwner__c + '=>' + newProperty.Owner +'\n';}
    if((newProperty.Owner  != null) && newProperty.Owner == 'Joint') {chatterBody += 'Owner: ' + newProperty.Owner + ' => Joint Ownership \n';}
    if((newProperty.AsOfDate  != null) && (newProperty.AsOfDate  != propertyList[0].WEGP1_AsOfDate__c)){chatterBody += 'As Of Date: ' + newProperty.AsOfDate +'\n';}
    if((newProperty.Amount  != null) && (newProperty.Amount  != propertyList[0].FinServ__Amount__c)){chatterBody += 'Amount: ' + newProperty.Amount +'\n';}
    */
    input.chatterBody = chatterBody;
    input.url = '/'+propertyList[0].Id;
    input.urlLabel = propertyList[0].Name;
    x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
}
@AuraEnabled
Public static void addProperty(String accountId,String propertyInfo) {
    List<FinServ__AssetsAndLiabilities__c> propertyList;
    List<PropertyWrapper> lstWrap = new List<PropertyWrapper>();
    List<RecordType> recType = new List<RecordType>();
    PropertyWrapper newProperty;
    if(propertyInfo != null){
        newProperty = (PropertyWrapper) JSON.deserialize(propertyInfo, PropertyWrapper.class);
    }
    recType = [SELECT Id, Name FROM RecordType Where Name IN('Asset') LIMIT 1];
    System.debug('J PROPERTY INFO====>' + newProperty);
    System.debug('recType' + recType);
    if(accountId != null){
        List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                        From Account
                        WHERE Id =: accountId LIMIT 1];

        String origOwnerName;
        List<Account> origOwner;
        if(newProperty.Owner !=null && newProperty.Owner != 'Joint'){
            origOwner = [SELECT Id, Name From Account 
                                    WHERE Id =: newProperty.Owner LIMIT 1];
            origOwnerName = origOwner[0].Name;
        }else{
            origOwnerName = 'Joint Ownership';
        }

        if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
            FinServ__AssetsAndLiabilities__c property = new FinServ__AssetsAndLiabilities__c();
            if(newProperty.Owner == 'Joint') {
                String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                property = new FinServ__AssetsAndLiabilities__c(Name = newProperty.Name ,
                        //FinServ__PrimaryOwner__c = accountId,
                        FinServ__PrimaryOwner__c = primary,
                        FinServ__JointOwner__c = secondary,
                        RecordTypeId =  recType[0].Id,
                        FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                        FinServ__AssetsAndLiabilitiesType__c = newProperty.Type,
                        WEGP1_AsOfDate__c = newProperty.AsOfDate,
                        FinServ__Amount__c = newProperty.Amount);
            } else {
                property = new FinServ__AssetsAndLiabilities__c(Name = newProperty.Name ,
                        //FinServ__PrimaryOwner__c = accountId,
                        FinServ__PrimaryOwner__c = newProperty.Owner,
                        RecordTypeId =  recType[0].Id,
                        FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                        FinServ__AssetsAndLiabilitiesType__c = newProperty.Type,
                        WEGP1_AsOfDate__c = newProperty.AsOfDate,
                        FinServ__Amount__c = newProperty.Amount);
            }
         insert property;
            x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
            input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
            input.userId = UserInfo.getUserId();
            String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
            if(newProperty.Name  != null){chatterBody += 'Personal Property Name: ' + newProperty.Name +'\n';}
            if(newProperty.Type  != null){chatterBody += 'Personal Property Type:' + newProperty.Type +'\n';}
            if((newProperty.Owner  != null) && newProperty.Owner != 'Joint') {chatterBody += 'Owner: ' + origOwnerName +'\n';}
            if((newProperty.Owner  != null) && newProperty.Owner == 'Joint') {chatterBody += 'Owner: Joint Ownership \n';}
            if(newProperty.AsOfDate  != null){chatterBody += 'As Of Date: ' + newProperty.AsOfDate +'\n';}
            if(newProperty.Amount  != null){chatterBody += 'Amount: ' + newProperty.Amount +'\n';}
            input.chatterBody = chatterBody;
            input.url = '/'+property.Id;
            input.urlLabel = property.Name;
            x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
        }
    }
}
}