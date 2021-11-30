/*
    Name : CheckOwnerShipOfAssetAndLiabilities
    TestClassName : CheckOwnerShipOfFinancialAccounts_TC
    ScheduleClassName : FinancialAccount_Scheduler
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : 1)Update Financial Account Owner values from FinServ__Household__c  field(Owner) if  hosuehold owner's profile = "Advisor".
                  2).If  FinServ__Household__c field owner's profile not equal to ""Advisor"" ,
                    get the owner value from Finserv__Primary_Owner__c field  if primary owner's profile = "Advisor""
*/

global class CheckOwnerShipOfAssetAndLiabilities implements Database.Batchable<SObject>, Database.Stateful{
  
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        String profileNames = System.label.Profile_name;
        String query = 'SELECT Name, ownerid, owner.profile.Name,FinServ__Household__r.Owner.Profile.Name,'
                        +' RecordType.Name,FinServ__PrimaryOwner__c,FinServ__PrimaryOwner__r.Owner.Profile.Name'
                        +' FROM FinServ__AssetsAndLiabilities__c';

       System.debug('query ::::: query'+query);
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<FinServ__AssetsAndLiabilities__c> scope){
        try{
            List<FinServ__AssetsAndLiabilities__c> finacclist = new List<FinServ__AssetsAndLiabilities__c>();
            for(FinServ__AssetsAndLiabilities__c finacc:scope){
                if(finacc.FinServ__Household__r.Owner.Profile.Name == System.label.Profile_name){
                    if (finacc.ownerid != finacc.FinServ__Household__r.owner.id) {
                        finacc.ownerid = finacc.FinServ__Household__r.owner.id;
                        finacclist.add(finacc);
                    }
                }
                else {
                    if(finacc.FinServ__PrimaryOwner__r.Owner.Profile.Name == System.Label.Profile_Name){
                        finacc.ownerid = finacc.FinServ__Household__r.owner.id;
                        finacclist.add(finacc);
                    }
                }
                                   
            } 
            if (finacclist.size () > 0)
                Database.Update (finacclist, false);
        }Catch(EXception e){}       
    }
    global void finish(Database.BatchableContext ctx){
    }
}