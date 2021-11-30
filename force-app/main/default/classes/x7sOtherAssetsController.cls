public without sharing class x7sOtherAssetsController {
    Public class OtherAssetWrapper{
          @AuraEnabled public String Id { get; set; }
          @AuraEnabled public String Type { get; set; }
          @AuraEnabled public String OwnerId { get; set; }
          @AuraEnabled public String OwnerName { get; set; }
          @AuraEnabled public String Account { get; set; }
          @AuraEnabled public Date AsOfDate { get; set; }
          @AuraEnabled public Decimal Amount { get; set; }
      }
      
      @AuraEnabled (cacheable=true)
      public static List<OtherAssetWrapper> getOtherAssetsDetails(String accountId){
          
          List<OtherAssetWrapper> lstWrap = new List<OtherAssetWrapper>();
          List<FinServ__AssetsAndLiabilities__c> otherAssetList;
          List<Account> accList;
          
          if(accountId != null){
              accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                       From Account 
                                       WHERE Id =: accountId LIMIT 1];
          }
          Id houseHoldId = accList[0].WEGP1_Primary_Household__c;
          system.debug('riddhi household id = '+houseHoldId);
          
      otherAssetList = [SELECT  Id, Name, FinServ__AssetsAndLiabilitiesType__c, FinServ__PrimaryOwner__c,FinServ__PrimaryOwner__r.Name,
                            WEGP1_AsOfDate__c, FinServ__Amount__c, FinServ__Household__c, FinServ__JointOwner__c, WEGP1_Owner_Type__c,
                            FinServ__FinancialAccount__c
                            FROM FinServ__AssetsAndLiabilities__c 
                            WHERE FinServ__Household__c = :houseHoldId 
                            AND RecordType.Name IN('Asset') 
                            AND Remove_or_Historic__c = ''
                           AND Status__c = 'Open'
                           AND WEGP1_ExcludeFromReview__c = FALSE
                            AND FinServ__AssetsAndLiabilitiesType__c IN ('Cash','Collection','Equipment','Gold','Other - Asset','Real Estate - Investment','Virtual Currency')];
          system.debug('riddhi otherAssetList = '+otherAssetList.size());
          for(FinServ__AssetsAndLiabilities__c oa : otherAssetList) {
              OtherAssetWrapper OtherAsset = new OtherAssetWrapper();
              OtherAsset.Id = oa.Id;
              OtherAsset.Type = oa.FinServ__AssetsAndLiabilitiesType__c;
              if(String.isNotBlank(oa.FinServ__JointOwner__c)) {
                  OtherAsset.OwnerId = 'Joint';
                  OtherAsset.OwnerName = 'Joint';
              } else {
                  OtherAsset.OwnerId = oa.FinServ__PrimaryOwner__c;
                  OtherAsset.OwnerName = oa.FinServ__PrimaryOwner__r.Name;
              }
              OtherAsset.Account = oa.Name;
              OtherAsset.AsOfDate = oa.WEGP1_AsOfDate__c;
              OtherAsset.Amount = oa.FinServ__Amount__c;
              lstWrap.add(OtherAsset);
          }     
          system.debug('lstWrap'+lstWrap);
          return lstWrap;
      }
      
      @AuraEnabled(cacheable=true)
      public static List<String> getAccountType() {
  
          List<String> pickListValuesList= new List<String>();
          
          Schema.DescribeFieldResult fieldResult = FinServ__AssetsAndLiabilities__c.FinServ__AssetsAndLiabilitiesType__c.getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          
      for(Schema.PicklistEntry pickListVal : ple){
              if((pickListVal.getValue() == 'Cash') && (pickListVal.getValue() == 'Collection') && (pickListVal.getValue() == 'Equipment') && (pickListVal.getValue() == 'Gold') && (pickListVal.getValue() == 'Other - Asset') && (pickListVal.getValue() == 'Real Estate - Investment') && (pickListVal.getValue() == 'Virtual Currency')) {
                  pickListValuesList.add(pickListVal.getValue());
              }
          }
      return pickListValuesList;
      }
          
      @AuraEnabled(cacheable=true)
      public static Map<String,String> getOtherAssetsOwnerList(String accountId) {
          Map<String,String> ownerList= new Map<String,String>();
          try {
              if(accountId != null) {
                  List<Account> acc  = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                       From Account 
                                       WHERE Id =: accountId LIMIT 1];
                  
                  List<Account> accList = new List<Account>();
                  
                  accList = [SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Primary_Individual__r.AccountId,
                                           WEGP1_Primary_Individual__r.Name, 
                                           WEGP1_Secondary_Individual__c, WEGP1_Secondary_Individual__r.AccountId,
                                           WEGP1_Secondary_Individual__r.Name 
                                           From Account 
                                           WHERE Id =: acc[0].WEGP1_Primary_Household__c LIMIT 1];
                  
                  if(accList.size() > 0 && accList != null){
                      if(accList[0].WEGP1_Primary_Individual__c != null && accList[0].WEGP1_Secondary_Individual__c != null) {
                          ownerList.put('Joint', 'Joint Ownership');
                      }
                      if(accList[0].WEGP1_Primary_Individual__c != null && accList[0].WEGP1_Secondary_Individual__c != null) {
                          ownerList.put('Joint', 'Joint Ownership');
                      }
                      if(accList[0].WEGP1_Primary_Individual__c != null) {
                          ownerList.put(accList[0].WEGP1_Primary_Individual__r.AccountId,accList[0].WEGP1_Primary_Individual__r.Name);
                      }
                      if(accList[0].WEGP1_Secondary_Individual__c != null) {
                          ownerList.put(accList[0].WEGP1_Secondary_Individual__r.AccountId,accList[0].WEGP1_Secondary_Individual__r.Name);
                      }
                  }
              }
              return ownerList;
              
          } catch (Exception e) {
              System.debug('error ::'+e);
              return ownerList;
          }
      }
      
      @AuraEnabled
      public static void addOtherAsset(String accountId,String otherAssetInfo) {
        System.debug('addOtherAsset accountId=======>'+accountId);
        System.debug('addOtherAsset otherAssetInfo=======>'+otherAssetInfo);
          try {
              List<FinServ__AssetsAndLiabilities__c> otherAssetList;
              List<OtherAssetWrapper> lstWrap = new List<OtherAssetWrapper>();
              List<RecordType> recType = new List<RecordType>();
              OtherAssetWrapper newOtherAsset;
              
              if(otherAssetInfo != null){
                  newOtherAsset = (OtherAssetWrapper) JSON.deserialize(otherAssetInfo, OtherAssetWrapper.class);
              }
              
              recType = [SELECT Id, Name FROM RecordType Where Name IN('Asset') LIMIT 1];
              
              if(accountId != null) {
                  
                  List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                          WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                          WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                  From Account
                  WHERE Id =: accountId LIMIT 1];
                  
                  if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
                      FinServ__AssetsAndLiabilities__c oa = new FinServ__AssetsAndLiabilities__c();
                      if(newOtherAsset.OwnerId == 'Joint') {
                          String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                          String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                          oa = new FinServ__AssetsAndLiabilities__c(Name = newOtherAsset.Account ,
                                  FinServ__PrimaryOwner__c = primary,
                                  FinServ__JointOwner__c = secondary,
                                  RecordTypeId =  recType[0].Id,
                                  FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                                  FinServ__AssetsAndLiabilitiesType__c = newOtherAsset.Type,
                                  WEGP1_AsOfDate__c = newOtherAsset.AsOfDate,
                                  FinServ__Amount__c = newOtherAsset.Amount);
                      } else {
                          oa = new FinServ__AssetsAndLiabilities__c(Name = newOtherAsset.Account ,
                                  FinServ__PrimaryOwner__c = newOtherAsset.OwnerId,
                                  RecordTypeId =  recType[0].Id,
                                  FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                                  FinServ__AssetsAndLiabilitiesType__c = newOtherAsset.Type,
                                  WEGP1_AsOfDate__c = newOtherAsset.AsOfDate,
                                  FinServ__Amount__c = newOtherAsset.Amount);
                      }
  
                      System.debug('other assets = '+oa);
                      insert oa;

                      String origOwnerName;
                        List<Account> origOwner;
                        if(newOtherAsset.OwnerId !=null && newOtherAsset.OwnerId != 'Joint'){
                            origOwner = [SELECT Id, Name From Account 
                                                    WHERE Id =: newOtherAsset.OwnerId LIMIT 1];
                            origOwnerName = origOwner[0].Name;
                        }else{
                            origOwnerName = 'Joint Ownership';
                        }
                      
                      x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                      input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                      input.userId = UserInfo.getUserId();
                      String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
                      
                      if(newOtherAsset.Type  != null){chatterBody += 'Other Asset Type: ' + newOtherAsset.Type +'\n';}
                      if(newOtherAsset.OwnerId == 'Joint'){
                          chatterBody += 'Owner:' + 'Joint Ownership' +'\n';
                      } else {
                          if(newOtherAsset.OwnerName  != null){chatterBody += 'Owner: ' + origOwnerName +'\n';}
                      }
                      if(newOtherAsset.Account  != null){chatterBody += 'Account: ' + newOtherAsset.Account +'\n';}
                      if(newOtherAsset.AsOfDate  != null){chatterBody += 'As Of Date: ' + newOtherAsset.AsOfDate +'\n';}
                      if(newOtherAsset.Amount  != null){chatterBody += 'Amount: ' + newOtherAsset.Amount +'\n';}
                      
                      input.chatterBody = chatterBody;
                      input.url = '/'+oa.Id;
                      input.urlLabel = oa.Name;
                      
                      x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
  
                  }
              }
              
          } catch (Exception e) {
              System.debug('error ::'+e);
          }
      }
      
       @AuraEnabled
      public static void editOtherAsset(String otherAssetId,String accountId,String otherAssetInfo) {
          System.debug('editOtherAsset otherAssetId=======>'+otherAssetId);
          System.debug('editOtherAsset accountId=======>'+accountId);
          System.debug('editOtherAsset otherAssetInfo=======>'+otherAssetInfo);
          try {
              List<FinServ__AssetsAndLiabilities__c> otherAssetList;
              List<OtherAssetWrapper> lstWrap = new List<OtherAssetWrapper>();
              OtherAssetWrapper newOtherAsset;
              List<Account> accList;  
              List<RecordType> recType = new List<RecordType>();

              recType = [SELECT Id, Name FROM RecordType Where Name IN('Asset') LIMIT 1];
              
              if(accountId != null){
                
                  accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                          WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                          WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                  From Account
                  WHERE Id =: accountId LIMIT 1];
            }
              
              if(otherAssetInfo != null){
                  newOtherAsset = (OtherAssetWrapper) JSON.deserialize(otherAssetInfo, OtherAssetWrapper.class);
                  otherAssetList = [SELECT Id,Name,FinServ__PrimaryOwner__c,FinServ__AssetsAndLiabilitiesType__c,
                                      WEGP1_AsOfDate__c,FinServ__Amount__c, FinServ__JointOwner__c, WEGP1_Owner_Type__c
                                      FROM FinServ__AssetsAndLiabilities__c 
                                    WHERE Id =:otherAssetId LIMIT 1];

            List<Account> origOwner;
            if(otherAssetList[0].WEGP1_Owner_Type__c != 'Joint'){
                origOwner = [SELECT Id, Name From Account 
                                        WHERE Id =: otherAssetList[0].FinServ__PrimaryOwner__c LIMIT 1];
            }

            List<Account> newOwner;
            if( newOtherAsset.OwnerId != 'Joint' ){
                newOwner = [SELECT Id, Name From Account 
                                    WHERE Id =: newOtherAsset.OwnerId LIMIT 1];
            }
                    
                  String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
                  if((newOtherAsset.Type  != null) && (newOtherAsset.Type  != otherAssetList[0].FinServ__AssetsAndLiabilitiesType__c)){chatterBody += 'Other Asset Type: ' + otherAssetList[0].FinServ__AssetsAndLiabilitiesType__c + ' => '  + newOtherAsset.Type +'\n';}
                  

                  if((newOtherAsset.OwnerId  != null) && newOtherAsset.OwnerId != 'Joint') {
                        if(otherAssetList[0].WEGP1_Owner_Type__c != 'Joint'){
                            chatterBody += 'Owner: ' + origOwner[0].Name + ' => ' + newOwner[0].Name +'\n';
                        }else{
                            chatterBody += 'Owner: ' + 'Joint Ownership' + ' => ' + newOwner[0].Name +'\n';
                        }
                  }
            
                  if((newOtherAsset.OwnerId  != null) && newOtherAsset.OwnerId == 'Joint') {
                   chatterBody += 'Owner: ' + origOwner[0].Name + ' =>  Joint Ownership  \n';
                  }
  
                  if((newOtherAsset.Account  != null) && (newOtherAsset.Account  != otherAssetList[0].Name)){chatterBody += 'Account: ' + otherAssetList[0].Name + ' => ' + newOtherAsset.Account +'\n';}
                  if((newOtherAsset.AsOfDate  != null) && (newOtherAsset.AsOfDate  != otherAssetList[0].WEGP1_AsOfDate__c)){chatterBody += 'As Of Date: ' + otherAssetList[0].WEGP1_AsOfDate__c + ' => ' + newOtherAsset.AsOfDate +'\n';}
                  if((newOtherAsset.Amount  != null) && (newOtherAsset.Amount  != otherAssetList[0].FinServ__Amount__c)){chatterBody += 'Amount: ' + otherAssetList[0].FinServ__Amount__c + ' => ' + newOtherAsset.Amount +'\n';}
                  otherAssetList[0].Name = newOtherAsset.Account;
                    if(newOtherAsset.OwnerId == 'Joint') {
                        String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                        String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                        otherAssetList[0].FinServ__PrimaryOwner__c = primary;
                        otherAssetList[0].FinServ__JointOwner__c = secondary;
                    } else {
                        otherAssetList[0].FinServ__PrimaryOwner__c = newOtherAsset.OwnerId;
                        otherAssetList[0].FinServ__JointOwner__c = null;
                    }
                  otherAssetList[0].FinServ__AssetsAndLiabilitiesType__c = newOtherAsset.Type;
                  otherAssetList[0].WEGP1_AsOfDate__c = newOtherAsset.AsOfDate;
                  otherAssetList[0].FinServ__Amount__c = newOtherAsset.Amount;

                  update otherAssetList; 
                  
                  x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                  input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                  input.userId = UserInfo.getUserId();

                  input.chatterBody = chatterBody;
                  input.url = '/'+otherAssetList[0].Id;
                  input.urlLabel = otherAssetList[0].Name;
                  
                  x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
              }
              
          } catch (Exception e) {
              System.debug('error ::'+e);
          }
      }
  }