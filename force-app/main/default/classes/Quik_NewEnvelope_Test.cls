@isTest
private class Quik_NewEnvelope_Test {
    
    @isTest
    private static void  test_for_NewEnvelope() {
        Id RecordTypeIdHouseHold = getRecordTpe('Household');
        Id RecordTypeIdCustodian = getRecordTpe('Custodian');
        Id individualRecordId = getRecordTpe('Individual');
        Account ParentAccount = createAccount(RecordTypeIdCustodian, null);
        Account ParentAccount1 = createAccount(individualRecordId, null);
        Contact contactToInsert = createContact(ParentAccount.Id);
        Account accountToInsert = createAccount(RecordTypeIdHouseHold, contactToInsert.Id);
        Account_Servicing__c asRecord = createAccSer(accountToInsert.Id, contactToInsert.Id);
        Financial_Account_Servicing__c fasRecord = createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity');
        AS_Quik_Forms_Group__c asQFGAs = createQuikFormGroupAs(asRecord.Id);
        Recipients__c signer1 = createRecipients(asQFGAs.Id, 'Primary');
        Recipients__c signer2 = createRecipients(asQFGAs.Id, 'Secondary');
        Recipients__c signer3 = createRecipients(asQFGAs.Id, 'Advisor');
        AS_Quik_Forms__c asForms1 = createQuikFormsFAS(asRecord.Id, asQFGAs.Id, '123456Test', asQFGAs.UniqueId__c);
        Attachment attch1 = addAttachmentToQuikForm(asForms1.Id);
        Test.startTest();
        Quik_NewEnvelopeController.getSignerDetails(asRecord.Id);
        List<Quik_NewEnvelopeController.DocOrderClass> docOrders = Quik_NewEnvelopeController.getDocumentOrder(asRecord.Id);
        List<Id> newQuikIds = New List<Id>();
        for(Quik_NewEnvelopeController.DocOrderClass eachStr : docOrders){
            newQuikIds.add(eachStr.nameWrap.Id);
        }
        List<Recipients__c> reciIds = new List<Recipients__c>();
        reciIds.add(signer1);
        reciIds.add(signer2);
        reciIds.add(signer3);
        String signerDetailWithOrder = JSON.serialize(docOrders);
        Quik_NewEnvelopeController.sendMailToSigners(detailsInOrder(asQFGAs.Id), reciIds);
        Quik_NewEnvelopeController.callDS(new List<String> {asQFGAs.Id});
        Quik_NewEnvelopeController.checkEnvelopeStatus(asForms1.Id);
        Quik_NewEnvelopeController.checkDocusignId(asForms1.Id);
        Test.stopTest();
    }
    
    public static Account createAccount(Id recordTypeId , Id contactId) {
        Group grp = new Group();
        grp.Name = 'Test group';
        grp.Type = 'Regular';
        insert grp;
        
        User owner = [Select Id, CSChatterGroup__c  FROM User Where CSChatterGroup__c != null AND Profile.Name = 'Advisor' LIMIT 1];
        owner.CSChatterGroup__c  = grp.Id;
        update owner;
        
        Account accountToInsert = new Account();
        accountToInsert.Name = 'TestAccount';
        accountToInsert.OwnerId = owner.Id;
        accountToInsert.WEGP1_Primary_Individual__c = contactId;
        accountToInsert.FI_Annual_Income__c = 23;
        accountToInsert.FI_Liquid_Net_Worth__c = 12;
        accountToInsert.FinServ__NetWorth__c = 14;
        accountToInsert.FI_Special_Liquidity_Needs__c = 'Y';
        accountToInsert.FI_Tax_Bracket__c = 2;
        accountToInsert.FI_Year_Began_Investing__c = 2012;
        accountToInsert.WEG_Alternate_Billing__c = 'Y';
        accountToInsert.FinServ__TimeHorizon__c = '1-3 years';
        accountToInsert.FI_Special_Liquidity_Needs_Detail__c = 'SLN Details';
        accountToInsert.WEGP1_Secondary_Individual__c = contactId;
        accountToInsert.RecordTypeId = recordTypeId;
        accountToInsert.WEG_IM_Special_Instructions__c = 'Y';
        accountToInsert.WEG_IM_Special_Instructions_Detail__c = 'SIR Dtails';
        accountToInsert.WEG_Investment_Objective__c = 'Long Term Growth';
        accountToInsert.WEG_Investment_Variances__c = 'Y';
        accountToInsert.WEG_Investment_Variances_Detail__c = 'IV Details';
        insert accountToInsert;
        return accountToInsert;
    }
    
    public static Account_Servicing__c createAccSer(Id accountId, Id ContactId) {
        Account_Servicing__c asRecord = new Account_Servicing__c();
        asRecord.WEG_Items_to_Complete__c = 'Test';
        asRecord.Related_Account__c = accountId;
        asRecord.WEGP1_Secondary_Individual__c = ContactId;
        insert asRecord; 
        return asRecord;
    }
    
    public static Financial_Account_Servicing__c createFinAccSer(Id parentaccountId, Id asRecordId, String custodian) {
        Financial_Account_Servicing__c fasRecord = new Financial_Account_Servicing__c();
        fasRecord.Account_Servicing__c = asRecordId;
        fasRecord.Primary_Owner__c = parentaccountId;
        fasRecord.Joint_Owner__c = parentaccountId;
        fasRecord.WEG_Custodian__c = custodian;
        insert fasRecord;
        return fasRecord;
    }
    
    public static  Id getRecordTpe(String typeName){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(typeName).getRecordTypeId();
        return recordTypeId;
    }
    
    public static Contact createContact(Id accountId) {
        Contact contactToInsert = new Contact();
        contactToInsert.LastName = 'TestLastName';
        contactToInsert.AccountId = accountId;
        insert contactToInsert;
        return contactToInsert;
    }
    
    public static AS_Quik_Forms_Group__c createQuikFormGroupAs(Id asRecord) {
        AS_Quik_Forms_Group__c asGroup = new AS_Quik_Forms_Group__c();
        asGroup.Account_Servicing__c = asRecord;
        asGroup.Recipients_Size__c = 2;
        asGroup.UniqueId__c= '005R0000004zy6zIAA1588084474493';
        asGroup.Docusign_Envelope_Id__c = 'efff4480-7ae5-4e11-aeca-9e17ee2d330f';
        asGroup.DocuSign_Envelope_Status__c = 'Sent';
        asGroup.Type__c ='Sign';
        asGroup.DocuSign_Envelope_Status__c = 'Draft';
        asGroup.Callout_Status__c = 'Completed';
        insert asGroup;
        return asGroup;
    }
    
    public static  Recipients__c createRecipients(Id asGroup, String signerType) {
        Recipients__c signer1 = new Recipients__c();
        signer1.Name__c = 'Test';
        signer1.Email__c = 'Test@gmail.com';
        signer1.Phone_Number__c = '9876543210';
        signer1.Order__c = 1;
        signer1.Docusign_Recipient_Id__c = '1';
        signer1.Sign_Type__c = 'Sign';
        signer1.Signer_Type__c = signerType;
        signer1.AS_Quik_Forms_Group__c = asGroup;
        signer1.Related_To__c = 'SEI IRA';
        insert signer1;
        return signer1;
    }
    
    public static AS_Quik_Forms__c createQuikFormsFAS(Id asRecord, Id asGroup, String UNID, String UniqueId) {
        AS_Quik_Forms__c asForms = new AS_Quik_Forms__c();
        asForms.Account_Servicing__c = asRecord;
        asForms.UNID__c = UNID;
        asForms.Form_Numbers__c = 'Household / Business(14317,52070,69237)-SEI IRA(1100,52068,69237)';
        asForms.AS_Quik_Forms_Group__c = asGroup;
        asForms.Form_HTML_URL__c = 'https://www.google.com';
        asForms.UniqueId__c = UniqueId;
        insert asForms;
        return asForms;
    }
    
    public static Attachment addAttachmentToQuikForm(Id parentId) {
        String attachBodyString = '{"QuikFormID": "68920,68919,69237", ';
        attachBodyString += '"FillableFields": [{"FieldName":"1own.ClientID","Required":true}],';
        attachBodyString += '"Recipients": {"Signers": [{"Order": 1, "Role": "1own", "SendType": "EmailToSign", "AuthTypes": "SMS"}],';
        attachBodyString += '"ExtraRecipients":[{"Order": 1,"Email": "bharath.t@bigworks.co","Name": "Schwab","RecipientNumber": 1}]},';
        attachBodyString += '"FormFields": [{"FieldName" : "QFECompany", "FieldValue" : "Efficient Technology, Inc."}]}';
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'QuikForm_17122020';
        attachment.Body = Blob.valueOf(attachBodyString);
        insert attachment;
        return attachment;
    }
    
    public static String detailsInOrder(String asQFGId) {
        String detailsString = '[{"orderWrap":1,';
        detailsString += '"custodianValue":"",';
        detailsString += '"nameWrap":{"Name":"0000720",';
        detailsString += '"FormName__c":"Household/Business",';
        detailsString += '"Account_Servicing__c":"a0z3B0000048KzrQAE",';
        detailsString += '"UniqueId__c":"0053B000003NLJ1QAO1609250230955",';
        detailsString += '"Id":"'  + asQFGId + '"},';
        detailsString += '"formId":"a133B000000xZVeQAM",';
        detailsString += '"formNumber":"69339,68920,68919,69237",';
        detailsString += '"recipients":[{"Name__c":"Brandon Joseph Abramson",';
        detailsString += '"AS_Quik_Form__c":"a133B000000xZVeQAM",';
        detailsString += '"AS_Quik_Forms_Group__c":"' + asQFGId + '",';
        detailsString += '"Email__c":"bharath.t@bigworks.co",';
        detailsString += '"WEG_eSign_Authorization_Type__c":"SMS",';
        detailsString += '"Order__c":1,';
        detailsString += '"Phone_Number__c":"7154290488",';
        detailsString += '"Related_To__c":"AS-0018586",';
        detailsString += '"Signer_Type__c":"Primary",';
        detailsString += '"Sign_Type__c":"Sign",';
        detailsString += '"Id":"a1I3B000005HMSnUAO",';
        detailsString += '"AS_Quik_Forms_Group__r":{"Name":"0000720",';
        detailsString += '"Id":"' + asQFGId + '"}}],';
        detailsString += '"deliverTo":"WEAS "}]';
        return detailsString;
    }
}