/**
 * Created by 7Summits on 5/18/21.
 */

public without sharing class x7s_FinancialProfileController {
    @AuraEnabled
    public static Financial_Profile__c startNewFinancialProfileForCurrentUser() {
        return insertNewFinancialProfileForUser(UserInfo.getUserId());
    }

    public static Financial_Profile__c insertNewFinancialProfileForUser(String userId){
        Financial_Profile__c newFinancialProfile = new Financial_Profile__c();

        List<User> userQuery = [
                SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c,
                        Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_Individual__c,
                        Contact.Account.WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__c
                FROM User
                WHERE Id = :userId
        ];
        if(userQuery.size() > 0 ) {
            User u = userQuery[0];
            newFinancialProfile.ContactId__c = u.ContactId;
            newFinancialProfile.Individual_Account__c = u.Contact.AccountId;
            newFinancialProfile.Household_Account__c = u.Contact.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = u.Contact.FirstName + ' ' + u.Contact.LastName + ' Financial Profile';
            if(u.ContactId == u.Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_Individual__c) {
                newFinancialProfile.Co_Client_Contact__c = u.Contact.Account.WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__c;
            } else {
                newFinancialProfile.Co_Client_Contact__c = u.Contact.Account.WEGP1_Primary_Household__r.WEGP1_Primary_Individual__c;
            }

        }
        insert newFinancialProfile;

        return newFinancialProfile;
    }

    /* PERSONAL INFO SECTION - Start */
    /**
     * @description - returns the current user's UNIFI Personal info. If none exist, we'll create one and return that.
     * @return
     */
    @AuraEnabled
    public static Financial_Profile__c getFinancialProfilePersonalInfoForCurrentUser(){
        List<Financial_Profile__c> financialProfilePersonalInfoQuery = [
                SELECT
                        Business_Email__c,
                        City__c,
                        Co_Client_Expected_Retirement_Age__c,
                        Co_Client_Is_Retired__c,
                        Co_Client_Total_Annual_Income__c,
                        Completed_Date__c,
                        ContactId__c,
                        ContactId__r.FirstName, ContactId__r.LastName, ContactId__r.Birthdate, ContactId__r.Email, ContactId__r.MiddleName, ContactId__r.Suffix,
                        ContactId__r.MailingStreet, ContactId__r.MailingCity, ContactId__r.MailingState, ContactId__r.MailingPostalCode,
                        ContactId__r.WEGP1_PersonalEmail__c, ContactId__r.WEG_Business_Email__c, ContactId__r.WEGP1_OtherEmail__c, ContactId__r.MobilePhone, ContactId__r.Phone, ContactId__r.HomePhone, ContactId__r.AssistantPhone,
                        Co_Client_Contact__c,
                        Co_Client_Contact__r.FirstName, Co_Client_Contact__r.LastName, Co_Client_Contact__r.Birthdate, Co_Client_Contact__r.Email, Co_Client_Contact__r.MiddleName, Co_Client_Contact__r.Suffix,
                        Co_Client_Contact__r.MailingStreet, Co_Client_Contact__r.MailingCity, Co_Client_Contact__r.MailingState, Co_Client_Contact__r.MailingPostalCode,
                        Co_Client_Contact__r.WEGP1_PersonalEmail__c, Co_Client_Contact__r.WEG_Business_Email__c, Co_Client_Contact__r.WEGP1_OtherEmail__c, Co_Client_Contact__r.MobilePhone, Co_Client_Contact__r.Phone, Co_Client_Contact__r.HomePhone, Co_Client_Contact__r.AssistantPhone,
                        Combined_Annual_Income__c,
                        Combined_Years_of_Investing__c,
                        Created_Date__c,
                        CreatedById,
                        CreatedDate,
                        Date_of_Birth__c,
                        Email__c,
                        Email_Type__c,
                        Expected_Retirement_Age__c,
                        Filing_Status__c,
                        First_Name__c,
                        Future_Life_Event__c,
                        Future_Life_Event_Explanation__c,
                        General_Investment_Time_Horizon__c,
                        Has_Liquidity_Needs__c,
                        Home_Phone__c,
                        Household_Account__c,
                        Household_Account__r.OwnerId,
                        Id,
                        Is_Completed__c,
                        Is_Primary__c,
                        Is_Retired__c,
                        IsDeleted,
                        Last_Name__c,
                        LastModifiedById,
                        LastModifiedDate,
                        Liquidity_Needs_Details__c,
                        Middle_Initial__c,
                        Estimated_Monthly_Spending__c,
                        Name,
                        Other_Email__c,
                        OwnerId,
                        Parent_Account__c,
                        Personal_Email__c,
                        Phone__c,
                        Phone_Type__c,
                        Plan_Asset_Protection__c,
                        Plan_Charitable_Giving__c,
                        Plan_Evaluate_Investment_Mix__c,
                        Plan_Family_Income_Upon_Death_Disability__c,
                        Plan_Goal_Achievability__c,
                        Plan_Target_Retirement_Date__c,
                        Plan_Tax_Reduction_Strategy__c,
                        Plan_Preserve_Wealth_For_Future__c,
                        PostalCode__c,
                        Primary_Address__c,
                        Primary_Email__c,
                        Primary_has_alimony__c,
                        Primary_has_child_support__c,
                        Primary_has_disability_benefits__c,
                        Primary_has_gifts__c,
                        Primary_Has_Health_Care_Directive__c,
                        Primary_has_other_income__c,
                        Primary_has_pension__c,
                        Primary_Has_Power_of_Attorney__c,
                        Primary_has_rental_property__c,
                        Primary_has_Social_Security__c,
                        Primary_Has_Trust__c,
                        Primary_Has_Will__c,
                        Primary_Source_of_Wealth__c,
                        Primary_Trust_Name__c,
                        Primary_Trust_Type__c,
                        Primary_Trust_Value__c,
                        Primary_has_disability_insurance__c,
                        Primary_has_health_insurance__c,
                        Primary_has_life_insurance__c,
                        Primary_has_long_term_care_insurance__c,
                        Primary_has_other_insurance__c,
                        Primary_has_property_casualty_insurance__c,
                        Secondary_has_alimony__c,
                        Secondary_has_child_support__c,
                        Secondary_has_disability_benefits__c,
                        Secondary_has_gifts__c,
                        Secondary_Has_Health_Care_Directive__c,
                        Secondary_has_other_income__c,
                        Secondary_has_pension__c,
                        Secondary_Has_Power_of_Attorney__c,
                        Secondary_has_rental_property__c,
                        Secondary_has_Social_Security__c,
                        Secondary_Has_Trust__c,
                        Secondary_Has_Will__c,
                        Secondary_Trust_Name__c,
                        Secondary_Trust_Type__c,
                        Secondary_Trust_Value__c,
                        Secondary_has_disability_insurance__c,
                        Secondary_has_health_insurance__c,
                        Secondary_has_life_insurance__c,
                        Secondary_has_long_term_care_insurance__c,
                        Secondary_has_other_insurance__c,
                        Secondary_has_property_casualty_ins__c,
                        State__c,
                        Street__c,
                        Suffix__c,
                        SystemModstamp,
                        Tax_Bracket_Rate__c,
                        Total_Annual_Income__c,
                        Trusted_Contact_Email__c,
                        Trusted_Contact_First_Name__c,
                        Trusted_Contact_Last_Name__c,
                        Trusted_Contact_Phone__c,
                        Work_Phone__c
                FROM Financial_Profile__c
                WHERE OwnerId = :UserInfo.getUserId()
                LIMIT 1
        ];

        if(financialProfilePersonalInfoQuery.size() > 0){
            Financial_Profile__c returnFinancialProfile = financialProfilePersonalInfoQuery[0];
            List<User> primaryContactQuery = [
                    SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Birthdate, Contact.Email, Contact.MiddleName, Contact.Suffix,
                            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode,
                            Contact.WEGP1_PersonalEmail__c, Contact.WEG_Business_Email__c, Contact.WEGP1_OtherEmail__c, Contact.MobilePhone, Contact.HomePhone, Contact.AssistantPhone
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];
            if(primaryContactQuery.size() > 0){
                User primaryContactUser = primaryContactQuery[0];

                returnFinancialProfile.First_Name__c = primaryContactUser.Contact.FirstName;
                returnFinancialProfile.Last_Name__c = primaryContactUser.Contact.LastName;
                returnFinancialProfile.Date_of_Birth__c = primaryContactUser.Contact.Birthdate;
//                returnFinancialProfile.Middle_Initial__c = primaryContactUser.Contact.MiddleName;
                returnFinancialProfile.Suffix__c = primaryContactUser.Contact.Suffix;
                returnFinancialProfile.Street__c = primaryContactUser.Contact.MailingStreet;
                returnFinancialProfile.City__c = primaryContactUser.Contact.MailingCity;
                returnFinancialProfile.State__c = primaryContactUser.Contact.MailingState;
                returnFinancialProfile.PostalCode__c = primaryContactUser.Contact.MailingPostalCode;

//                returnFinancialProfile.Email__c = primaryContactUser.Contact.Email;
                returnFinancialProfile.Business_Email__c = primaryContactUser.Contact.WEG_Business_Email__c;
                returnFinancialProfile.Personal_Email__c = primaryContactUser.Contact.WEGP1_PersonalEmail__c;
                returnFinancialProfile.Other_Email__c = primaryContactUser.Contact.WEGP1_OtherEmail__c;

                returnFinancialProfile.Phone__c = primaryContactUser.Contact.MobilePhone;
                returnFinancialProfile.Home_Phone__c = primaryContactUser.Contact.HomePhone;
                returnFinancialProfile.Work_Phone__c = primaryContactUser.Contact.AssistantPhone;
            }

            return returnFinancialProfile;
        }
        return startNewFinancialProfileForCurrentUser();
    }

    @AuraEnabled
    public static Financial_Profile__c saveFinancialProfile(SObject questionnaire){
        System.debug(questionnaire);
        Financial_Profile__c wrappedFinancialProfile = (Financial_Profile__c)questionnaire;
        System.debug(wrappedFinancialProfile);

        try{
            List<User> userQuery = [
                    SELECT Id, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Account.WEGP1_Primary_Household__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];
            if(userQuery.size() > 0 && userQuery[0].ContactId != null) {
                User u = userQuery[0];
                wrappedFinancialProfile.ContactId__c = u.ContactId;
                wrappedFinancialProfile.Individual_Account__c = u.Contact.AccountId;
                wrappedFinancialProfile.Household_Account__c = u.Contact.Account.WEGP1_Primary_Household__c;
                wrappedFinancialProfile.Name = u.Contact.FirstName + ' ' + u.Contact.LastName + ' Financial Profile';

                shareHouseholdWithCurrentUser(u.Contact.Account.WEGP1_Primary_Household__c);
            }

            update wrappedFinancialProfile;

            Contact contactUpdate = new Contact(Id=wrappedFinancialProfile.ContactId__c);
            contactUpdate.FirstName = wrappedFinancialProfile.First_Name__c;
            contactUpdate.LastName = wrappedFinancialProfile.Last_Name__c;
            contactUpdate.Birthdate = wrappedFinancialProfile.Date_of_Birth__c;
//            contactUpdate.Email = wrappedFinancialProfile.Email__c;
            contactUpdate.WEG_Business_Email__c = wrappedFinancialProfile.Business_Email__c;
//            contactUpdate.MiddleName = wrappedFinancialProfile.Middle_Initial__c;
            contactUpdate.Suffix = wrappedFinancialProfile.Suffix__c;
            contactUpdate.MailingStreet = wrappedFinancialProfile.Street__c;
            contactUpdate.MailingCity = wrappedFinancialProfile.City__c;
            contactUpdate.MailingState = wrappedFinancialProfile.State__c;
            contactUpdate.MailingPostalCode = wrappedFinancialProfile.PostalCode__c;
            contactUpdate.WEGP1_PersonalEmail__c = wrappedFinancialProfile.Personal_Email__c;
            contactUpdate.WEGP1_OtherEmail__c = wrappedFinancialProfile.Other_Email__c;
            contactUpdate.MobilePhone = wrappedFinancialProfile.Phone__c;
            contactUpdate.HomePhone = wrappedFinancialProfile.Home_Phone__c;
            contactUpdate.AssistantPhone = wrappedFinancialProfile.Work_Phone__c;

            update contactUpdate;

        }catch(Exception ex){
            System.debug('riddhi'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        return wrappedFinancialProfile;
    }


    @AuraEnabled
    public static Contact saveFinancialProfileCoClient(Contact coClient){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                shareHouseholdWithCurrentUser(financialProfile.Household_Account__c);

                if(coClient.AccountId == null){
                    Account acc = new Account();
                    acc.Name = coClient.FirstName + ' ' + coClient.LastName;
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
                    acc.WEGP1_Primary_Household__c = financialProfile.Household_Account__c;
                    acc.OwnerId = financialProfile.Household_Account__r.OwnerId;
                    insert acc;

                    coClient.AccountId = acc.Id;
                }

                upsert coClient;

                financialProfile.Co_Client_Contact__c = coClient.Id;
                update financialProfile;

                List<Account> householdAccountQuery = [
                        SELECT Id, WEGP1_Secondary_Individual__c
                        FROM Account
                        WHERE Id = :financialProfile.Household_Account__c
                ];
                if(householdAccountQuery.size() > 0){
                    Account household = householdAccountQuery[0];
                    if(household.WEGP1_Secondary_Individual__c == null) {
                        household.WEGP1_Secondary_Individual__c = coClient.Id;
                        update household;
                    }
                }

                return coClient;
            }catch(Exception ex){
                System.debug('x7s_Controller.saveFinancialProfileCoClient - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }

    /* get the custom metadata for the Financial Goals buttons - martin.blase */
    @AuraEnabled(Cacheable=true)
    public static List<X7s_Financial_Goals_Button__mdt> getFinancialProfileFinancialGoals() {
        List<X7s_Financial_Goals_Button__mdt> financialGoals = [
                SELECT Label, Icon_Name__c, Term__c, Order__c
                FROM X7s_Financial_Goals_Button__mdt
                ORDER BY Order__c
            ];
        return financialGoals;
    }


    /* PERSONAL INFO SECTION - end */

    /* DEPENDENT SECTION - start */
    @AuraEnabled
    public static List<Financial_Profile_Dependent__c> getFinancialProfileDependentsForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Dependent__c> dependentsQuery = [
                    SELECT Id,
                            CreatedById,
                            CreatedDate,
                            Date_of_Birth__c,
                            First_Name__c,
                            Last_Name__c,
                            LastModifiedDate,
                            LastModifiedById,
                            Middle_Initial__c,
                            Parent_Account__c,
                            Relationship__c,
                            State__c,
                            Suffix__c,
                            Name,
                            Financial_Profile__c
                    FROM Financial_Profile_Dependent__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return dependentsQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Dependent__c> saveFinancialProfileDependents(String dependents){
        System.debug(dependents);

        List<Financial_Profile_Dependent__c> wrappedDependents = (List<Financial_Profile_Dependent__c>)JSON.deserialize(dependents, List<Financial_Profile_Dependent__c>.class);
        System.debug(wrappedDependents);

        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                upsert wrappedDependents;

                List<Financial_Profile_Dependent__c> existingDependentsNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Dependent__c
                        WHERE Id NOT IN:wrappedDependents AND Financial_Profile__c = :financialProfile.Id
                ];

                delete existingDependentsNotIncluded;
                return wrappedDependents;
            }catch(Exception ex){
                System.debug('x7s_Controller.saveFinancialProfileDependents - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }

    /* DEPENDENT INFO SECTION - end */

    /* EMPLOYMENT SECTION - start */
    @AuraEnabled
    public static List<Financial_Profile_Employment__c> getFinancialProfileEmploymentsForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Employment__c> employmentsQuery = [
                    SELECT Id, Name, Annual_Income__c,
                            CreatedById,
                            CreatedDate,
                            Employer_Name__c,
                            Is_Self_Employed__c,
                            LastModifiedById,
                            LastModifiedDate,
                            Occupation__c,
                            Financial_Profile__c
                    FROM Financial_Profile_Employment__c
                    WHERE Financial_Profile__c = :financialProfile.Id AND Owner__c = :financialProfile.ContactId__c
            ];

            return employmentsQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Employment__c> getFinancialProfileEmploymentsForCoClient(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Employment__c> employmentsQuery = [
                    SELECT Id, Name, Annual_Income__c,
                            CreatedById,
                            CreatedDate,
                            Employer_Name__c,
                            Is_Self_Employed__c,
                            LastModifiedById,
                            LastModifiedDate,
                            Occupation__c,
                            Financial_Profile__c
                    FROM Financial_Profile_Employment__c
                    WHERE Financial_Profile__c = :financialProfile.Id AND Owner__c = :financialProfile.Co_Client_Contact__c
            ];

            return employmentsQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Employment__c> saveFinancialProfileEmployments(String employments){
        System.debug(employments);

        List<Financial_Profile_Employment__c> wrappedEmployments = (List<Financial_Profile_Employment__c>)JSON.deserialize(employments, List<Financial_Profile_Employment__c>.class);
        System.debug(wrappedEmployments);


        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                String ownerId = '';
                for(Financial_Profile_Employment__c employment : wrappedEmployments){
                    if(employment.Owner__c == null){
                        employment.Owner__c = financialProfile.ContactId__c;
                    }
                    ownerId = employment.Owner__c;
                }

                upsert wrappedEmployments;

                List<Financial_Profile_Employment__c> existingEmploymentsNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Employment__c
                        WHERE Id NOT IN:wrappedEmployments AND Financial_Profile__c = :financialProfile.Id AND Owner__c = :ownerId
                ];

                delete existingEmploymentsNotIncluded;
                return wrappedEmployments;
            }catch(Exception ex){
                System.debug('x7s_Controller.saveFinancialProfileEmployments - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }
    /* EMPLOYMENT SECTION - end */

    /* PLANNING OBJECTIVES SECTION - start */
    /**
     * added 5/13/21 by martin.blase
     * Get the ordered list of fields associated with the Planning Objectives subcomponent from a Field Set on the FinancialProfile FinancialProfile object.
     */
    public static List<Schema.FieldSetMember> getPlanningObjectivesFields() {
        return SObjectType.Financial_Profile__c.FieldSets.Planning_Objectives.getFields();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPlanningObjectivesList() {
        List<Map<String,String>> fieldsList = new List<Map<String,String>>();
        for(Schema.FieldSetMember f : x7s_FinancialProfileController.getPlanningObjectivesFields()) {
            Map<String,String> fieldData = new Map<String,String>();
            fieldData.put('fieldPath',f.getFieldPath());
            fieldData.put('label', f.getLabel());
            fieldData.put('inlineHelpText',f.getSObjectField().getDescribe().getInlineHelpText());
            fieldsList.add(fieldData);
        }
        return fieldsList;
    }

    /* PLANNING OBJECTIVES SECTION - end */

    /* GOALS SECTION - start */
    @AuraEnabled
    public static List<Financial_Profile_Goal__c> getFinancialProfileGoalsForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Goal__c> goalsQuery = [
                    SELECT Id, Name, Estimated_Amount__c,
                            Goal_Name__c,
                            Is_Default__c,
                            Is_Selected__c,
                            Term__c,
                            Description__c,
                            Financial_Profile__c
                    FROM Financial_Profile_Goal__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return goalsQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Goal__c> saveFinancialProfileGoals(String goals){
        System.debug(goals);
        List<Financial_Profile_Goal__c> wrappedGoals = (List<Financial_Profile_Goal__c>)JSON.deserialize(goals, List<Financial_Profile_Goal__c>.class);
        System.debug(wrappedGoals);

        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                upsert wrappedGoals;

                List<Financial_Profile_Goal__c> existingGoalsNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Goal__c
                        WHERE Id NOT IN:wrappedGoals AND Financial_Profile__c = :financialProfile.Id
                ];

                delete existingGoalsNotIncluded;
                return wrappedGoals;
            }catch(Exception ex){
                System.debug('x7s_FinancialProfileController.saveFinancialProfileGoals - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }
    /* end */

    /* INCOME SECTION - start */

    /**
     * added 5/17/21 by martin.blase
     * Get the ordered list of fields associated with the Other Tax Factors subcomponent from a Field Set on the Unifi Questionnaire object.
     */
    public static List<Schema.FieldSetMember> getOtherTaxFactorsFields() {
        return SObjectType.Financial_Profile__c.FieldSets.Other_Tax_Factors.getFields();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getOtherTaxFactorsList() {
        List<Map<String,String>> fieldsList = new List<Map<String,String>>();
        for(Schema.FieldSetMember f : x7s_FinancialProfileController.getOtherTaxFactorsFields()) {
            Map<String,String> fieldData = new Map<String,String>();
            fieldData.put('fieldPath',f.getFieldPath());
            fieldData.put('label', f.getLabel());
            fieldData.put('inlineHelpText',f.getSObjectField().getDescribe().getInlineHelpText());
            fieldsList.add(fieldData);
        }
        return fieldsList;
    }

    @AuraEnabled
    public static List<Financial_Profile_Income_Expense__c> getFinancialProfileIncomeExpensesForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Income_Expense__c> incomeExpenseQuery = [
                    SELECT Id,
                            Name,
                            CreatedDate,
                            CreatedById,
                            LastModifiedDate,
                            LastModifiedById,
                            Description__c,
                            Amount__c,
                            Type__c,
                            Owner__c
                    FROM Financial_Profile_Income_Expense__c
                    WHERE Financial_Profile__c = :financialProfile.Id AND Owner__c = :financialProfile.ContactId__c
            ];

            return incomeExpenseQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Income_Expense__c> getFinancialProfileIncomeExpensesForCoClient(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Income_Expense__c> incomeExpenseQuery = [
                    SELECT Id,
                            Name,
                            CreatedDate,
                            CreatedById,
                            LastModifiedDate,
                            LastModifiedById,
                            Description__c,
                            Amount__c,
                            Type__c,
                            Owner__c
                    FROM Financial_Profile_Income_Expense__c
                    WHERE Financial_Profile__c = :financialProfile.Id AND Owner__c = :financialProfile.Co_Client_Contact__c
            ];

            return incomeExpenseQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Income_Expense__c> getFinancialProfileIncomeExpensesForBoth(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Income_Expense__c> incomeExpenseQuery = [
                    SELECT Id,
                            Name,
                            CreatedDate,
                            CreatedById,
                            LastModifiedDate,
                            LastModifiedById,
                            Description__c,
                            Amount__c,
                            Type__c,
                            Owner__c, Owner__r.Name
                    FROM Financial_Profile_Income_Expense__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return incomeExpenseQuery;
        }

        return null;
    }

    /**
     * @param incomeExpenses list of records to sync with the database
     * @param type is used to ensure we only clean up extraneous records for the specified type to prevent over-deletion
     *
     * @return
     */
    @AuraEnabled
    public static List<Financial_Profile_Income_Expense__c> saveFinancialProfileIncomeExpenses(String incomeExpenses, String type){
        System.debug(incomeExpenses);
        List<Financial_Profile_Income_Expense__c> wrappedIncomeExpenses = (List<Financial_Profile_Income_Expense__c>)JSON.deserialize(incomeExpenses, List<Financial_Profile_Income_Expense__c>.class);
        System.debug(wrappedIncomeExpenses);

        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                for(Financial_Profile_Income_Expense__c incomeExpense : wrappedIncomeExpenses){
                    if(incomeExpense.Owner__c == null){
                        incomeExpense.Owner__c = financialProfile.ContactId__c;
                    }
                }

                upsert wrappedIncomeExpenses;

                List<Financial_Profile_Income_Expense__c> existingExpensesNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Income_Expense__c
                        WHERE Id NOT IN:wrappedIncomeExpenses AND Financial_Profile__c = :financialProfile.Id AND Type__c = :type
                ];

                delete existingExpensesNotIncluded;
                return wrappedIncomeExpenses;
            }catch(Exception ex){
                System.debug('x7s_FinancialProfileController.saveFinancialProfileIncomeExpenses - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }

    /* INCOME SECTION - end */

    /* ASSETS SECTION - start */
    /**
     * @Description - handles Checking/Savings accounts, Investment Accounts, Retirement Accounts, and Other Accounts
     * @return
     */
    @AuraEnabled
    public static List<Financial_Profile_Financial_Account__c> getFinancialProfileFinancialAccountsForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Financial_Account__c> insurancesQuery = [
                    SELECT Id,
                            IsDeleted,
                            Name,
                            CreatedDate,
                            CreatedById,
                            LastModifiedDate,
                            LastModifiedById,
                            SystemModstamp,
                            Financial_Profile__c,
                            Owner__c,
                            Account_Type__c,
                            Financial_Institution__c,
                            Current_Value__c,
                            Type__c
                    FROM Financial_Profile_Financial_Account__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return insurancesQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Financial_Account__c> saveFinancialProfileFinancialAccounts(String financialAccounts, String type){
        System.debug(financialAccounts);
        List<Financial_Profile_Financial_Account__c> wrappedFinancialAccounts = (List<Financial_Profile_Financial_Account__c>)JSON.deserialize(financialAccounts, List<Financial_Profile_Financial_Account__c>.class);
        System.debug(wrappedFinancialAccounts);


        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                upsert wrappedFinancialAccounts;

                List<Financial_Profile_Financial_Account__c> existingFinancialAccountsNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Financial_Account__c
                        WHERE Id NOT IN:wrappedFinancialAccounts AND Financial_Profile__c = :financialProfile.Id AND Type__c = :type
                ];

                delete existingFinancialAccountsNotIncluded;
                return wrappedFinancialAccounts;
            }catch(Exception ex){
                System.debug('x7s_FinancialProfileController.saveFinancialProfileFinancialAccounts - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Assets_Liabilities__c> getFinancialProfileAssetsLiabilitiesForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Assets_Liabilities__c> assetsQuery = [
                    SELECT Id,
                            Asset_Type__c,
                            CreatedById,
                            Financial_Profile__c,
                            Name,
                            Has_Home_Equity_Line_Of_Credit__c,
                            Has_Loan_For_Asset__c,
                            Interest_Rate__c,
                            LastModifiedById,
                            Owner__c,
                            Term__c	,
                            Type__c,
                            Value__c
                    FROM Financial_Profile_Assets_Liabilities__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return assetsQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Assets_Liabilities__c> saveFinancialProfileAssets(String assets, String type){
        System.debug(assets);
        List<Financial_Profile_Assets_Liabilities__c> wrappedAssets = (List<Financial_Profile_Assets_Liabilities__c>)JSON.deserialize(assets, List<Financial_Profile_Assets_Liabilities__c>.class);
        System.debug(wrappedAssets);

        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                upsert wrappedAssets;

                List<Financial_Profile_Assets_Liabilities__c> existingAssetsNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Assets_Liabilities__c
                        WHERE Id NOT IN:wrappedAssets AND Financial_Profile__c = :financialProfile.Id AND Type__c = :type
                ];

                delete existingAssetsNotIncluded;
                return wrappedAssets;
            }catch(Exception ex){
                System.debug('x7s_FinancialProfileController.saveFinancialProfileAssets - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }
    /* ASSETS SECTION - end */


    /* INSURANCE SECTION - start */
    /**
     * added 6/1/21 by martin.blase
     * Get the ordered list of fields associated with the Insurance Categories subcomponent from a Field Set on the Unifi Questionnaire object.
     */
    public static List<Schema.FieldSetMember> getInsuranceCategoriesFields() {
        return SObjectType.Financial_Profile__c.FieldSets.Insurance.getFields();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getInsuranceCategoriesList() {
        List<Map<String,String>> fieldsList = new List<Map<String,String>>();
        for(Schema.FieldSetMember f : x7s_FinancialProfileController.getInsuranceCategoriesFields()) {
            Map<String,String> fieldData = new Map<String,String>();
            fieldData.put('fieldPath',f.getFieldPath());
            fieldData.put('label', f.getLabel());
            fieldData.put('inlineHelpText',f.getSObjectField().getDescribe().getInlineHelpText());
            fieldsList.add(fieldData);
        }
        return fieldsList;
    }

    @AuraEnabled
    public static List<Financial_Profile_Insurance_Policy__c> getFinancialProfileInsurancePoliciesForCurrentUser(){
        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            List<Financial_Profile_Insurance_Policy__c> insurancesQuery = [
                    SELECT Id,
                            IsDeleted,
                            Name,
                            CreatedDate,
                            CreatedById,
                            LastModifiedDate,
                            LastModifiedById,
                            SystemModstamp,
                            As_Of_Date__c,
                            Benefit_Amount__c,
                            Cash_Value__c,
                            Coverage_Amount__c,
                            Death_Benefit__c,
                            Financial_Profile__c,
                            Insurance_Company__c,
                            Insurance_Type__c,
                            Insured__c,
                            Owner__c,
                            Policy_Number__c,
                            Premium__c,
                            Term__c,
                            Type__c
                    FROM Financial_Profile_Insurance_Policy__c
                    WHERE Financial_Profile__c = :financialProfile.Id
            ];

            return insurancesQuery;
        }

        return null;
    }

    @AuraEnabled
    public static List<Financial_Profile_Insurance_Policy__c> saveFinancialProfileInsurancePolicies(String insurances, String type){
        System.debug(insurances);
        List<Financial_Profile_Insurance_Policy__c> wrappedInsurances = (List<Financial_Profile_Insurance_Policy__c>)JSON.deserialize(insurances, List<Financial_Profile_Insurance_Policy__c>.class);
        System.debug(wrappedInsurances);

        Financial_Profile__c financialProfile = getFinancialProfilePersonalInfoForCurrentUser();
        if(financialProfile != null){
            System.Savepoint save = Database.setSavepoint();
            try {
                upsert wrappedInsurances;

                List<Financial_Profile_Insurance_Policy__c> existingPoliciesNotIncluded = [
                        SELECT Id
                        FROM Financial_Profile_Insurance_Policy__c
                        WHERE Id NOT IN:wrappedInsurances AND Financial_Profile__c = :financialProfile.Id AND Type__c = :type
                ];

                delete existingPoliciesNotIncluded;
                return wrappedInsurances;
            }catch(Exception ex){
                System.debug('x7s_FinancialProfileController.saveFinancialProfileInsurancePolicies - Exception: ' + ex.getMessage());
                Database.rollback(save);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return null;
    }

    /* INSURANCE SECTION - end */

    /* ESTATE PLANNING SECTION - start */

    /**
     * added 5/27/21 by martin.blase
     * Get the ordered list of fields associated with the Estate Planning subcomponent from a Field Set on the Financial Profile object.
     */
    public static List<Schema.FieldSetMember> getEstatePlanningFields() {
        return SObjectType.Financial_Profile__c.FieldSets.Estate_Planning.getFields();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getEstatePlanningList() {
        List<Map<String,String>> fieldsList = new List<Map<String,String>>();
        for(Schema.FieldSetMember f : x7s_FinancialProfileController.getEstatePlanningFields()) {
            Map<String,String> fieldData = new Map<String,String>();
            fieldData.put('fieldPath',f.getFieldPath());
            fieldData.put('label', f.getLabel());
            fieldData.put('inlineHelpText',f.getSObjectField().getDescribe().getInlineHelpText());
            fieldsList.add(fieldData);
        }
        return fieldsList;
    }

    /* ESTATE PLANNING SECTION - end */

    private static void shareHouseholdWithCurrentUser(String householdId){
        List<AccountShare> accountShares = [
                SELECT Id, AccountAccessLevel
                FROM AccountShare
                WHERE AccountId = :householdId AND UserOrGroupId = :UserInfo.getUserId() AND AccountAccessLevel = 'Edit'
        ];

        if(accountShares.size() <= 0){
            AccountShare householdShare = new AccountShare(
                    AccountId=householdId,
                    UserOrGroupId=UserInfo.getUserId(),
                    AccountAccessLevel='Edit',
                    OpportunityAccessLevel='None',
                    CaseAccessLevel='None'
            );
            insert householdShare;
        }
    }
}