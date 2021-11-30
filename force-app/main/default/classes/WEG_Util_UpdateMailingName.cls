public class WEG_Util_UpdateMailingName {
    
    private boolean hasActivePrimary;
    private string primarySalutation;
    private string primaryFirstName;
    private string primaryLastName;
    private string primarySuffix;
    private string primaryFullName;
    
    private boolean hasActiveSecondary;
    private string secondarySalutation;
    private string secondaryFirstName;
    private string secondaryLastName;
    private string secondarySuffix;
    private string secondaryFullName;
    
    // get the household accounts
    private List<Account> queryHouseholds(Set<Id> householdIds) {
        return new List<Account>([SELECT Id, WEG_Informal_Household_Mailing_Name__c
                                  , WEGP1_Primary_Individual__c
                                  , WEGP1_Primary_Individual__r.WEGP1_ContactStatus__c, WEGP1_Primary_Individual__r.Salutation
                                  , WEGP1_Primary_Individual__r.WEGP1_InformalFirstName__c, WEGP1_Primary_Individual__r.LastName, WEGP1_Primary_Individual__r.Suffix
                                  , WEGP1_Secondary_Individual__c
                                  , WEGP1_Secondary_Individual__r.WEGP1_ContactStatus__c, WEGP1_Secondary_Individual__r.Salutation
                                  , WEGP1_Secondary_Individual__r.WEGP1_InformalFirstName__c, WEGP1_Secondary_Individual__r.LastName, WEGP1_Secondary_Individual__r.Suffix
                                  FROM Account
                                  WHERE Id IN :householdIds]);
    }

    private void buildHousehold(Account household) {
        
        if (household.WEGP1_Primary_Individual__c != null && household.WEGP1_Primary_Individual__r.WEGP1_ContactStatus__c == 'Active') {
            hasActivePrimary = true;
            primarySalutation = household.WEGP1_Primary_Individual__r.Salutation;
            primaryFirstName = household.WEGP1_Primary_Individual__r.WEGP1_InformalFirstName__c;
            primaryLastName = household.WEGP1_Primary_Individual__r.LastName;
            primarySuffix = household.WEGP1_Primary_Individual__r.Suffix;
            primaryFullName = primaryFirstName + ' ' + primaryLastName;
            if (String.isNotEmpty(primarySuffix))
                primaryFullName += ' ' + primarySuffix;
        }
        else
            hasActivePrimary = false;
        
        if (household.WEGP1_Secondary_Individual__c != null && household.WEGP1_Secondary_Individual__r.WEGP1_ContactStatus__c == 'Active') {
            hasActiveSecondary = true;
            secondarySalutation = household.WEGP1_Secondary_Individual__r.Salutation;
            secondaryFirstName = household.WEGP1_Secondary_Individual__r.WEGP1_InformalFirstName__c;
            secondaryLastName = household.WEGP1_Secondary_Individual__r.LastName;
            secondarySuffix = household.WEGP1_Secondary_Individual__r.Suffix;
            secondaryFullName = secondaryFirstName + ' ' + secondaryLastName;
            if (String.isNotEmpty(secondarySuffix))
                secondaryFullName += ' ' + secondarySuffix;
        }
        else
            hasActiveSecondary = false;
    }
    
    public void updateHouseholds(Set<Id> householdIds) {
        System.debug('>>>>>>>> WEG_Util_UpdateMailingName.updateHouseholds');
        
        // get the household accounts
        List<Account> householdAccounts = queryHouseholds(householdIds);
        string pluralSalutation;
        
        List<Account> householdsToUpdate = new List<Account>();
        for (Account hh : householdAccounts) {
            System.debug('>>>>>>>> Household Account Id: ' + hh.Id);
            
            // populate the private helper variables
            buildHousehold(hh);
            
            // HOUSEHOLD HAS TWO ACTIVE INDIVIDUALS
            if (hasActivePrimary && hasActiveSecondary) {
                System.debug('>>>>>>>> Household has Two Active Individuals.');
                
                // 1. Both individuals have identical salutations AND they are ‘Dr’ or ‘Prof’.
                if (primarySalutation == secondarySalutation && (primarySalutation == 'Dr.' || primarySalutation == 'Prof.')) {
                    // set the plural salutation
                    if (primarySalutation == 'Dr.')
                        pluralSalutation = 'Drs.';
                    else
                        pluralSalutation = 'Profs.';
                    
                    // a. Both individuals have identical last names AND no suffixes are present.
                    if (primaryLastName == secondaryLastName && String.isEmpty(primarySuffix) && String.isEmpty(secondarySuffix))
                        hh.WEG_Informal_Household_Mailing_Name__c = pluralSalutation + ' ' + primaryFirstName + ' & ' + secondaryFirstName + ' ' + primaryLastName;
                    // b. Both individuals have different last names OR a suffix is present.
                    else
                        hh.WEG_Informal_Household_Mailing_Name__c = pluralSalutation + ' ' + primaryFullName + ' & ' + secondaryFullName;
                }
                
                // 2. Both individuals have salutations AND they are identical and not ‘Dr’ or ‘Prof’ OR they are different.
                else if (String.isNotEmpty(primarySalutation) && String.isNotEmpty(secondarySalutation)) {
                    // a. Both individuals have identical last names AND identical salutations AND no suffixes are present.
                    if (primaryLastName == secondaryLastName && primarySalutation == secondarySalutation && String.isEmpty(primarySuffix) && String.isEmpty(secondarySuffix))
                        hh.WEG_Informal_Household_Mailing_Name__c = primarySalutation + ' ' + primaryFirstName + ' & ' + secondarySalutation + ' ' + secondaryFirstName + ' ' + primaryLastName;
                    // b. Both individuals have identical last names AND different salutations AND no suffixes are present.
                    else if (primaryLastName == secondaryLastName && String.isEmpty(primarySuffix) && String.isEmpty(secondarySuffix))
                        hh.WEG_Informal_Household_Mailing_Name__c = primarySalutation + ' & ' + secondarySalutation + ' ' + primaryFirstName + ' and ' + secondaryFirstName + ' ' + primaryLastName;
                    // c. Both individuals have different last names OR a suffix is present.
                    else
                        hh.WEG_Informal_Household_Mailing_Name__c = primarySalutation + ' ' + primaryFullName + ' & ' + secondarySalutation + ' ' + secondaryFullName;
                }
                
                // 3. At least one individual doesn’t have a salutation.
                else {
                    // a. Both individuals have identical last names AND no suffixes are present.
                    if (primaryLastName == secondaryLastName && String.isEmpty(primarySuffix) && String.isEmpty(secondarySuffix))
                        hh.WEG_Informal_Household_Mailing_Name__c = primaryFirstName + ' & ' + secondaryFirstName + ' ' + primaryLastName;
                    // b. Both individuals have different last names OR a suffix is present.
                    else
                        hh.WEG_Informal_Household_Mailing_Name__c = primaryFullName + ' & ' + secondaryFullName;
                }
            }
            
            // HOUSEHOLD HAS ONE ACTIVE INDIVIDUAL
            else if (hasActivePrimary || hasActiveSecondary) {
                System.debug('>>>>>>>> Household has One Active Individual.');
                
                // 4. Display salutation and suffix if present.
                if (hasActivePrimary && String.isNotEmpty(primarySalutation))
                    hh.WEG_Informal_Household_Mailing_Name__c = primarySalutation + ' ' + primaryFullName;
                else if (hasActivePrimary)
                    hh.WEG_Informal_Household_Mailing_Name__c = primaryFullName;
                else if (hasActiveSecondary && String.isNotEmpty(secondarySalutation))
                    hh.WEG_Informal_Household_Mailing_Name__c = secondarySalutation + ' ' + secondaryFullName;
                else
                    hh.WEG_Informal_Household_Mailing_Name__c = secondaryFullName;
            }
            
            // HOUSEHOLD HAS NO ACTIVE INDIVIDUALS
            else {
                System.debug('>>>>>>>> Household has No Active Individuals.');
                
                hh.WEG_Informal_Household_Mailing_Name__c = '';
            }
            
            // add the household to list to be updated
            householdsToUpdate.add(hh);
        }
        
        // update the households
        update householdsToUpdate;
    }
}