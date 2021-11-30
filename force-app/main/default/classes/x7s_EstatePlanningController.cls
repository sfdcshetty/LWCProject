/**
 * Created by 7Summits on 6/29/21.
 */

public without sharing class x7s_EstatePlanningController {

    public class EstateWrapper{
        @AuraEnabled
        public String primaryName;
        @AuraEnabled
        public String secondaryName;
        @AuraEnabled
        public Boolean primaryWillExists;
        @AuraEnabled
        public Boolean secondaryWillExists;

        @AuraEnabled
        public Boolean primaryRevocableTrustExists;
        @AuraEnabled
        public Boolean primaryIrrevocableTrustExists;
        @AuraEnabled
        public Boolean secondaryRevocableTrustExists;
        @AuraEnabled
        public Boolean secondaryIrrevocableTrustExists;

        @AuraEnabled
        public Boolean primaryPowerOfAttorney;
        @AuraEnabled
        public Boolean secondaryPowerOfAttorney;
        @AuraEnabled
        public Boolean primaryLivingWillExists;
        @AuraEnabled
        public Boolean secondaryLivingWillExists;

        public EstateWrapper(){}

        public EstateWrapper(Account acc){
            primaryName = acc.WEGP1_Primary_Individual__r.FirstName;
            secondaryName = acc.WEGP1_Secondary_Individual__r.FirstName;

            primaryWillExists = acc.WEGP1_Primary_Individual__r.WEGP1_WillExists__c;
            secondaryWillExists = acc.WEGP1_Secondary_Individual__r.WEGP1_WillExists__c;

            primaryRevocableTrustExists = acc.WEGP1_Primary_Individual__r.WEGP1_RevocableTrustExists__c;
            primaryIrrevocableTrustExists = acc.WEGP1_Primary_Individual__r.WEGP1_IrrevocableTrustExists__c;

            secondaryRevocableTrustExists = acc.WEGP1_Secondary_Individual__r.WEGP1_RevocableTrustExists__c;
            secondaryIrrevocableTrustExists = acc.WEGP1_Secondary_Individual__r.WEGP1_IrrevocableTrustExists__c;

            primaryPowerOfAttorney = acc.WEGP1_Primary_Individual__r.WEGP1_PoAExists__c;
            secondaryPowerOfAttorney = acc.WEGP1_Secondary_Individual__r.WEGP1_PoAExists__c;
            primaryLivingWillExists = acc.WEGP1_Primary_Individual__r.WEGP1_HCDExists__c;
            secondaryLivingWillExists = acc.WEGP1_Secondary_Individual__r.WEGP1_HCDExists__c;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static EstateWrapper getHouseholdWithEstateInformation() {
        return getHouseholdWithEstateInformationForUser(UserInfo.getUserId());
    }

    @AuraEnabled(Cacheable=true)
    public static EstateWrapper getHouseholdWithEstateInformationForUser(String userId) {
        List<User> currentUserQuery = [
                SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c
                FROM User
                WHERE Id = :userId
                LIMIT 1
        ];

        if(currentUserQuery.size() > 0) {
            User currentUser = currentUserQuery[0];
            List<Account> householdQuery = [
                    SELECT Id,
                            WEGP1_Primary_Individual__r.WEGP1_WillExists__c, WEGP1_Primary_Individual__r.WEGP1_HCDExists__c,
                            WEGP1_Primary_Individual__r.WEGP1_RevocableTrustExists__c, WEGP1_Primary_Individual__r.WEGP1_IrrevocableTrustExists__c,
                            WEGP1_Primary_Individual__r.WEGP1_PoAExists__c, WEGP1_Primary_Individual__r.FirstName,
                            WEGP1_Secondary_Individual__r.WEGP1_WillExists__c, WEGP1_Secondary_Individual__r.WEGP1_HCDExists__c, 
                            WEGP1_Secondary_Individual__r.WEGP1_RevocableTrustExists__c, WEGP1_Secondary_Individual__r.WEGP1_IrrevocableTrustExists__c,
                            WEGP1_Secondary_Individual__r.WEGP1_PoAExists__c, WEGP1_Secondary_Individual__r.FirstName
                    FROM Account
                    WHERE Id = :currentUser.Contact.Account.WEGP1_Primary_Household__c
                    LIMIT 1
            ];

            if(householdQuery.size() > 0){
                return new EstateWrapper(householdQuery[0]);
            }
        }
        return null;
    }

    @AuraEnabled
    public static Boolean saveEstateInformation(String stringifiedWrapper) {
        EstateWrapper wrapper = (EstateWrapper)JSON.deserialize(stringifiedWrapper, EstateWrapper.class);
        System.debug('saveEstateInformation '+wrapper);
        
        List<User> currentUserQuery = [
                    SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1
            ];
        try {
            if (currentUserQuery.size() > 0) {
                User currentUser = currentUserQuery[0];
                List<Account> householdQuery = [
                        SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c,
                                WEGP1_Primary_Individual__r.Name, WEGP1_Secondary_Individual__r.Name,
                                WEGP1_Primary_Individual__r.WEGP1_WillExists__c, WEGP1_Primary_Individual__r.WEGP1_HCDExists__c,
                                WEGP1_Primary_Individual__r.WEGP1_RevocableTrustExists__c, WEGP1_Primary_Individual__r.WEGP1_IrrevocableTrustExists__c,
                                WEGP1_Primary_Individual__r.AccountId,
                                WEGP1_Primary_Individual__r.WEGP1_PoAExists__c, WEGP1_Primary_Individual__r.FirstName,
                                WEGP1_Secondary_Individual__r.WEGP1_WillExists__c, WEGP1_Secondary_Individual__r.WEGP1_HCDExists__c, 
                                WEGP1_Secondary_Individual__r.WEGP1_RevocableTrustExists__c, WEGP1_Secondary_Individual__r.WEGP1_IrrevocableTrustExists__c,
                                WEGP1_Secondary_Individual__r.AccountId,
                                WEGP1_Secondary_Individual__r.WEGP1_PoAExists__c, WEGP1_Secondary_Individual__r.FirstName,
                                OwnerId, Owner.CSChatterGroup__c
                        FROM Account
                        WHERE Id = :currentUser.Contact.Account.WEGP1_Primary_Household__c
                        LIMIT 1 FOR UPDATE
                ];
				System.debug('householdQuery' + currentUserQuery.size());

                if (householdQuery.size() > 0) {
                    Account household = householdQuery[0];
                    Contact primaryIndividual = household.WEGP1_Primary_Individual__r;
                    Contact secondaryIndividual = household.WEGP1_Secondary_Individual__r;

                    List<Contact> contactsToUpdate = new List<Contact>();
                    if(household.WEGP1_Primary_Individual__c != null) {
                        Contact primaryContact = new Contact(Id = household.WEGP1_Primary_Individual__c,
                                WEGP1_WillExists__c = wrapper.primaryWillExists,
                                WEGP1_HCDExists__c = wrapper.primaryLivingWillExists,

                                WEGP1_PoAExists__c = wrapper.primaryPowerOfAttorney);
                                primaryContact.WEGP1_IrrevocableTrustExists__c = wrapper.primaryIrrevocableTrustExists;
                                primaryContact.WEGP1_RevocableTrustExists__c = wrapper.primaryRevocableTrustExists;
                        
                        contactsToUpdate.add(primaryContact);

                        System.debug('householdQuery-contact' + primaryContact);
                        System.debug('householdQuery-secondary' + household.WEGP1_Secondary_Individual__c);
                    }

                    if(household.WEGP1_Secondary_Individual__c != null) {
                        Contact secondaryContact = new Contact(Id = household.WEGP1_Secondary_Individual__c,
                                WEGP1_WillExists__c = wrapper.secondaryWillExists,
                                WEGP1_HCDExists__c = wrapper.secondaryLivingWillExists,

                                WEGP1_PoAExists__c = wrapper.secondaryPowerOfAttorney);
                                secondaryContact.WEGP1_IrrevocableTrustExists__c = wrapper.secondaryIrrevocableTrustExists;
                                secondaryContact.WEGP1_RevocableTrustExists__c = wrapper.secondaryRevocableTrustExists;
                        contactsToUpdate.add(secondaryContact);
                    }
                    String chatterPostBody = 'Portal - Estate Planning Updates' + '\n';

                    String primaryChatterPostBody = '';
                    if(wrapper.primaryWillExists != primaryIndividual.WEGP1_WillExists__c){
                        primaryChatterPostBody += 'Will Exists: ' + primaryIndividual.WEGP1_WillExists__c + ' => ' + wrapper.primaryWillExists + '\n';
                    }
                
                    if((wrapper.primaryRevocableTrustExists==true && !primaryIndividual.WEGP1_RevocableTrustExists__c) ||
                        (wrapper.primaryRevocableTrustExists==false && primaryIndividual.WEGP1_RevocableTrustExists__c) ||
                            (wrapper.primaryIrrevocableTrustExists==true && !primaryIndividual.WEGP1_IrrevocableTrustExists__c)||
                            (wrapper.primaryIrrevocableTrustExists==false && primaryIndividual.WEGP1_IrrevocableTrustExists__c) ||
                            ((wrapper.primaryIrrevocableTrustExists==false && wrapper.primaryRevocableTrustExists==false) && (primaryIndividual.WEGP1_IrrevocableTrustExists__c || primaryIndividual.WEGP1_RevocableTrustExists__c))){                            
                            
                            if( (wrapper.primaryRevocableTrustExists==true && !primaryIndividual.WEGP1_RevocableTrustExists__c) ||  (wrapper.primaryRevocableTrustExists==false && primaryIndividual.WEGP1_RevocableTrustExists__c) ) primaryChatterPostBody += 'Primary Revocable Trust Exists  => ' + wrapper.primaryRevocableTrustExists + '\n';
                            if( (wrapper.primaryIrrevocableTrustExists==true && !primaryIndividual.WEGP1_IrrevocableTrustExists__c) || (wrapper.primaryIrrevocableTrustExists==false && primaryIndividual.WEGP1_IrrevocableTrustExists__c) ) primaryChatterPostBody += 'Primary Irrevocable Trust Exists  => ' + wrapper.primaryIrrevocableTrustExists + '\n';
                    }

                    if(wrapper.primaryPowerOfAttorney != primaryIndividual.WEGP1_PoAExists__c){
                        primaryChatterPostBody += 'Power Of Attorney Exists: ' + primaryIndividual.WEGP1_PoAExists__c + ' => ' + wrapper.primaryPowerOfAttorney + '\n';
                    }
                    if(wrapper.primaryLivingWillExists != primaryIndividual.WEGP1_HCDExists__c){
                        primaryChatterPostBody += 'Living Will Exists: ' + primaryIndividual.WEGP1_HCDExists__c + ' => ' + wrapper.primaryLivingWillExists + '\n';
                    }
                    if(primaryChatterPostBody != ''){
                        primaryChatterPostBody = 'Updates for ' + primaryIndividual.Name + ': \n' + primaryChatterPostBody;
                        chatterPostBody += primaryChatterPostBody + '\n';
                    }

                    if(wrapper.secondaryName != null){ //test to make sure we have a secondary user before assembling the chatter for them
                        String secondaryChatterPostBody = '';
                        if(wrapper.secondaryWillExists && wrapper.secondaryWillExists != secondaryIndividual.WEGP1_WillExists__c){
                            secondaryChatterPostBody += 'Will Exists: ' + secondaryIndividual.WEGP1_WillExists__c + ' => ' + wrapper.secondaryWillExists + '\n';
                        }

                        if((wrapper.secondaryRevocableTrustExists==true && secondaryIndividual.WEGP1_RevocableTrustExists__c==false) ||
                            (wrapper.secondaryIrrevocableTrustExists==true && !secondaryIndividual.WEGP1_IrrevocableTrustExists__c)||
                            (wrapper.secondaryIrrevocableTrustExists==false && secondaryIndividual.WEGP1_IrrevocableTrustExists__c) ||
                            ((wrapper.secondaryIrrevocableTrustExists==false && wrapper.secondaryRevocableTrustExists==false) && (secondaryIndividual.WEGP1_IrrevocableTrustExists__c || secondaryIndividual.WEGP1_RevocableTrustExists__c))){
                            
                            if( (wrapper.secondaryRevocableTrustExists==true && !secondaryIndividual.WEGP1_RevocableTrustExists__c) ||  (wrapper.secondaryRevocableTrustExists==false && secondaryIndividual.WEGP1_RevocableTrustExists__c) ) secondaryChatterPostBody += 'Secondary Revocable Trust Exists  => ' + wrapper.secondaryRevocableTrustExists + '\n';
                            if( (wrapper.secondaryIrrevocableTrustExists==true && !secondaryIndividual.WEGP1_IrrevocableTrustExists__c) || (wrapper.secondaryIrrevocableTrustExists==false && secondaryIndividual.WEGP1_IrrevocableTrustExists__c) ) secondaryChatterPostBody += 'Secondary Irrevocable Trust Exists  => ' + wrapper.secondaryIrrevocableTrustExists + '\n';
                    }

                        if(wrapper.secondaryPowerOfAttorney && wrapper.secondaryPowerOfAttorney != secondaryIndividual.WEGP1_PoAExists__c){
                            secondaryChatterPostBody += 'Power Of Attorney Exists: ' + secondaryIndividual.WEGP1_PoAExists__c + ' => ' + wrapper.secondaryPowerOfAttorney + '\n';
                        }
                        if(wrapper.secondaryLivingWillExists && wrapper.secondaryLivingWillExists != secondaryIndividual.WEGP1_HCDExists__c){
                            secondaryChatterPostBody += 'Living Will Exists: ' + secondaryIndividual.WEGP1_HCDExists__c + ' => ' + wrapper.secondaryLivingWillExists + '\n';
                        }

                        if(secondaryChatterPostBody != ''){
                            secondaryChatterPostBody = 'Updates for ' + secondaryIndividual.Name + ': \n' + secondaryChatterPostBody;
                            chatterPostBody += secondaryChatterPostBody + '\n\n';
                        }
                    }

                    if(!Test.isRunningTest()) {
                        update contactsToUpdate;
                        
                        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                        input.parentId = household.Owner.CSChatterGroup__c;
                        input.userId = UserInfo.getUserId();
                        input.chatterBody = chatterPostBody;
                        input.url = '/'+household.Id;
                        input.urlLabel = household.Name;
                        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
                        
                    }
                    return true;
                }
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage() + ' ' + ex.getLineNumber());
        }
        return false;
    }
}