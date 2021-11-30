@isTest
private class QuikFormHandler_TEST {
    //This test method sending test data to QuikFormHandler, Quik_SignUrl, Quik_DocusignCallback
    @isTest
    private static void  test_for_QuikFormHandler_Sign() {
        TVA_CFB__CloudFiles_LookUp_Mapping__c cfb = new TVA_CFB__CloudFiles_LookUp_Mapping__c();
        cfb.Name = 'Account';
        cfb.TVA_CFB__Object_API__c = 'Account';
        cfb.TVA_CFB__Field_Name__c =  'TVA_CFB__Account__c';
        insert cfb;
        
        Id RecordTypeIdHouseHold = getRecordTpe('Household');
        Id RecordTypeIdCustodian = getRecordTpe('Custodian');
        Id individualRecordId = getRecordTpe('Individual');
        Account ParentAccount = createAccount(RecordTypeIdCustodian, null);
        Account ParentAccount1 = createAccount(individualRecordId, null);
        Contact contactToInsert = createContact(ParentAccount.Id);
        Custodian_Info__c custodian =createCustodianInfo();
        Account accountToInsert = createAccount(RecordTypeIdHouseHold, contactToInsert.Id);
        Account_Servicing__c asRecord = createAccSer(accountToInsert.Id, contactToInsert.Id);
        Financial_Account_Servicing__c fasRecord = createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity', custodian.Id);
        AS_Quik_Forms_Group__c asGroup = createQuikForm(fasRecord.Id);
        String allFasIdList = fasRecord.Id;
        AS_Quik_Forms__c asForms = createQuikForms(asRecord.Id, asGroup.Id, '12345Test', '', allFasIdList);
        List<Id> asFormId = new List<Id>();
        AS_Quik_Forms__c asForms1 = createQuikForms(asRecord.Id, asGroup.Id, '123456Test', 'testetse112', '');
        asFormId.add(asForms.Id);
        Recipients__c signer1 = createRecipients(asForms.Id, asGroup.Id);
        Quik_Mapping__c quikMapp = createQuikMapping('O.State', 'AS', 'WEGP1_Secondary_Individual__r.LastName', true, false);
        Quik_Mapping__c quikMapp1 = createQuikMapping('FullName', 'FAS', 'Joint_Owner__r.Name', true, true);
        Form_Bundle__c formBundle = creatFormBundle();
        Quik_Form__c quikForm = creatQuikForm();
        Bundled_Forms__c bundledForms = createBundledForms(quikForm.id, formBundle.Id);
        String receipients = '[{"AS_Quik_Forms_Group__c":"' + signer1.AS_Quik_Forms_Group__c + '","Id":"' + signer1.Id + 
            '","Name__c":"Emma R. Borris","Order__c":1,"Sign_Type__c":"Sign","Email__c":"test@gmail.com","Phone_Number__c":"8989898989"}]';
        QuikFormHandler obj = new QuikFormHandler();
        String jsonBody = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody += '"formDesc": "To be", ';
        jsonBody += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"},';
        jsonBody += '{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        AS_Quik_Forms_Group__c asQFG = createQuikFormGroup(fasRecord.Id, asRecord.Id);
        AS_Quik_Forms_Group__c asQFGAs = createQuikFormGroupAs(asRecord.Id);
        
        Test.startTest();
        Map<String, String> allFormsInfoMap = new Map<String, String>();
        allFormsInfoMap.put(asRecord.Id, '6369,52146');
        allFormsInfoMap.put(fasRecord.Id, '63694,2563');
        QuikFormHandler.generateHTML(jsonBody, asForms.UNID__C, asRecord.Id, JSON.serialize(allFormsInfoMap), 'Sign');
        String jsonBody1 = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody1 += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody1 += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody1 += '"formDesc": "To be", ';
        jsonBody1 += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody1 += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody1 += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        QuikFormHandler.generateHTML_Print(jsonBody1, asForms.UNID__C, asRecord.Id, 'Print');
        QuikFormHandler.generateHTML_Print(jsonBody1, asForms.UNID__C, asRecord.Id, 'Sign');
        
        List<SObject> getRecordlist = QuikFormHandler.getRecords(asRecord.Id);
        QuikFormHandler.getCategories();
        QuikFormHandler.getAccessToken();
        QuikFormHandler.getDealers();
        QuikFormHandler.getBundleGroupsSign();
        Map<String, String> asFasMap = new Map<String, String>();
        asFasMap.put(asRecord.Id, '1234');
        asFasMap.put(fasRecord.Id, '5498');
        QuikFormHandler.combineFormsBasedOnSigners(asRecord.Id + ',' + fasRecord.Id, JSON.serialize(asFasMap));
        QuikFormHandler.displayASQuikFormRecords(asRecord.Id, 'Print');
        QuikFormHandler.getASFormGroupRecords(asRecord.Id);
        String jsonStringifiedMap = '"[{"value":"1","key":"68920"},{"value":"1","key":"68919"}]"';
        QuikFormHandler.searchForms_Sign('Test', new List<String> { '1', '2' }, new List<String> { '1', '2' }, new List<String> { }, 
                                         'Sign', jsonStringifiedMap, 1, 10);
        QuikFormHandler.searchForms_Sign('Test', new List<String> { '1', '2' }, new List<String> { '1', '2' }, new List<String> {'1', '2'}, 
                                         'Print', jsonStringifiedMap,1,10);
        QuikFormHandler.searchForms_Sign('Test', new List<String> { '1', '2' }, new List<String> { '1', '2' }, new List<String> {'Test', '2'}, 
                                         'Sign', jsonStringifiedMap,1,10);
        QuikFormHandler.searchForms_Sign('Test', new List<String> {}, new List<String> {}, new List<String> {}, 'Sign', jsonStringifiedMap, 
                                         1, 10);
        List<Form_Bundle__c> bGroup = QuikFormHandler.getBundleGroups();
        Boolean checkBoolean = QuikFormHandler.getGroupId(asForms.Id);
        QuikFormHandler.getForms(formBundle.Id, 3, 6, 'Print');
        QuikFormHandler.getForms(formBundle.Id, 1, 6, 'Print');
        QuikFormHandler.getForms('All', 1, 6, 'Print');
        QuikFormHandler.getForms('All', 1, 6, 'Sign');
        QuikFormHandler.getForms(formBundle.Id, 1, 6, 'Sign');
        QuikFormHandler.callDocusign(receipients);
        Quik_DocusignCallback.docusignResponse();
        QuikFormHandler.deleteASQuikForm(asForms1.Id);
        Quik_SignUrl.doPost();
        QuikFormHandler.deleteReceipients(signer1);
        uploadFileAsCloudFile.createCloudFile('Test.pdf', 'application/pdf', 10000, ParentAccount.Id, Blob.ValueOf('Test'));
        updateAsQuikFormGroup(asQFG);
        updateAsQuikFormGroup(asQFGAs);
        Quik_SendChatterNotification.sendChatterFeed(asRecord.Id, '', 'efff4480-7ae5-4e11-aeca-9e17ee2d310f', accountToInsert.Id, asRecord.Id);
        Test.stopTest();
    }
    
    private static void updateAsQuikFormGroup(AS_Quik_Forms_Group__c asGroup) {
        AS_Quik_Forms_Group__c asQuikGroup = asGroup;
        asQuikGroup.DocuSign_Envelope_Status__c = 'Completed';
        update asQuikGroup;
    }
    
    //Testing of Quik_ResendMail controller
    @isTest
    private static void test_for_Quik_ResendMail() {
        AS_Quik_Forms_Group__c aqfg = new AS_Quik_Forms_Group__c();
        aqfg.Docusign_Envelope_Id__c = 'f797dc21-be85-4156-86a7-21b8a3e33af3';
        insert aqfg;
        Recipients__c recp = new Recipients__c();
        recp.Status__c = 'Sent';
        recp.Docusign_Recipient_Id__c = '1';
        recp.AS_Quik_Forms_Group__c = aqfg.Id;
        insert recp;
        Quik_ResendMail.resendEnvelope(recp.Id);
    }
    
    @isTest
    private static void  test_for_QuikFormHandler() {
        TVA_CFB__CloudFiles_LookUp_Mapping__c cfb = new TVA_CFB__CloudFiles_LookUp_Mapping__c();
        cfb.Name = 'Account';
        cfb.TVA_CFB__Object_API__c = 'Account';
        cfb.TVA_CFB__Field_Name__c =  'TVA_CFB__Account__c';
        insert cfb;
        
        Id RecordTypeIdHouseHold = getRecordTpe('Household');
        Id RecordTypeIdCustodian = getRecordTpe('Custodian');
        Id individualRecordId = getRecordTpe('Individual');
        Account ParentAccount = createAccount(RecordTypeIdCustodian, null);
        Account ParentAccount1 = createAccount(individualRecordId, null);
        Contact contactToInsert = createContact(ParentAccount.Id);
        Custodian_Info__c custodian =createCustodianInfo();
        Account accountToInsert = createAccount(RecordTypeIdHouseHold, contactToInsert.Id);
        Account_Servicing__c asRecord = createAccSer(accountToInsert.Id, contactToInsert.Id);
        Financial_Account_Servicing__c fasRecord = createFinAccSer(ParentAccount1.Id, asRecord.Id, 'TD Ameritrade', custodian.Id);
        AS_Quik_Forms_Group__c asGroup = createQuikForm(fasRecord.Id);
        String allFasIdList = fasRecord.Id;
        AS_Quik_Forms__c asForms = createQuikForms(asRecord.Id, asGroup.Id, '12345Test', '', allFasIdList);
        List<Id> asFormId = new List<Id>();
        AS_Quik_Forms__c asForms1 = createQuikForms(asRecord.Id, asGroup.Id, '123456Test', 'testetse112', '');
        asFormId.add(asForms.Id);
        Recipients__c signer1 = createRecipients(asForms.Id, asGroup.Id);
        Quik_Mapping__c quikMapp = createQuikMapping('O.State', 'AS', 'WEGP1_Secondary_Individual__r.LastName', true, false);
        Quik_Mapping__c quikMapp1 = createQuikMapping('FullName', 'FAS', 'Joint_Owner__r.Name', true, true);
        Form_Bundle__c formBundle = creatFormBundle();
        Quik_Form__c quikForm = creatQuikForm();
        Bundled_Forms__c bundledForms = createBundledForms(quikForm.id, formBundle.Id);
        String receipients = '[{"AS_Quik_Forms_Group__c":"' + signer1.AS_Quik_Forms_Group__c + '","Id":"' + signer1.Id 
            + '","Name__c":"Emma R. Borris","Order__c":1,"Sign_Type__c":"Sign","Email__c":"test@gmail.com","Phone_Number__c":"8989898989"}]';
        QuikFormHandler obj = new QuikFormHandler();
        String jsonBody = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody += '"formDesc": "To be", ';
        jsonBody += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"},';
        jsonBody += '{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        
        String jsonBody1 = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody1 += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody1 += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody1 += '"formDesc": "To be", ';
        jsonBody1 += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody1 += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody1 += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
        doc.TVA_CFB__file_type__c = 'jpg';
        doc.AS_Quik_Forms_Group__c = asGroup .id;
        doc.TVA_CFB__Parent_ID__c = asGroup.id;
        doc.Name = 'test.doc';
        doc.TVA_CFB__Bucket_Name__c = 'testBucket';
        doc.TVA_CFB__Folder__c = 'test';
        doc.TVA_CFB__Region__c = 'us-east-1';
        doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
        insert doc;
        
        Test.startTest();
        Map<String, String> allFormsInfoMap = new Map<String, String>();
        allFormsInfoMap.put(asRecord.Id, '6369,52146,6369');
        allFormsInfoMap.put(fasRecord.Id, '63694,2563');
        QuikFormHandler.generateHTML(jsonBody, '', asRecord.Id, JSON.serialize(allFormsInfoMap), 'Sign');
        QuikFormHandler.generateHTML_Print(jsonBody1, '', asRecord.Id, 'Print');
        QuikFormHandler.generateHTML_Print(jsonBody1, '', asRecord.Id, 'Sign');
        List<SObject> getRecordlist = QuikFormHandler.getRecords(asRecord.Id);
        QuikFormHandler.getCategories();
        QuikFormHandler.getAccessToken();
        QuikFormHandler.getDealers();
        QuikFormHandler.displayASQuikFormRecords(asRecord.Id,'Print');
        QuikFormHandler.searchForms('Test', new List<String> { '1', '2' }, new List<String> { '1', '2' }, 2, new List<String> { },'Print', 1, 10);
        List<Form_Bundle__c> bGroup = QuikFormHandler.getBundleGroups();
        Boolean checkBoolean = QuikFormHandler.getGroupId(asForms.Id);
        QuikFormHandler.getForms(formBundle.Id, 3, 6, 'Print');
        QuikFormHandler.callDocusign(receipients);
        Quik_DocusignCallback.docusignResponse();
        QuikFormHandler.deleteASQuikForm(asForms1.Id);
        Quik_SignUrl.doPost();
        Quik_SignUrl.prepareReceipientsReqBody('test', 'test', 1, custodian.id, 2);
        QuikFormHandler.deleteReceipients(signer1);
        uploadFileAsCloudFile.createCloudFile('Test.pdf', 'application/pdf', 10000, ParentAccount.Id, Blob.ValueOf('Test'));
        Test.stopTest();
    }
    
    //This test method sending test data to QuikGenerateHTML class
    @isTest
    private static void test_for_QuikGenerateHTML() {
        Id RecordTypeIdHouseHold = getRecordTpe('Household');
        Id RecordTypeIdCustodian = getRecordTpe('Custodian');
        Id individualRecordId = getRecordTpe('Individual');
        Account ParentAccount = createAccount(RecordTypeIdCustodian, null);
        Account ParentAccount1 = createAccount(individualRecordId, null);
        Contact contactToInsert = createContact(ParentAccount.Id);
        Account accountToInsert = createAccount(RecordTypeIdHouseHold, contactToInsert.Id);
        Account_Servicing__c asRecord = createAccSer(accountToInsert.Id, contactToInsert.Id);
        Custodian_Info__c custodian =createCustodianInfo();
        Financial_Account_Servicing__c fasRecord =createFinAccSer(ParentAccount1.Id, asRecord.Id, 'TD Ameritrade', custodian.Id);
        Financial_Account_Servicing__c fasRecord1 = createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity', custodian.Id);
        Financial_Account_Servicing__c fasRecord2 =createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity', custodian.Id);
        delete fasRecord1;
        String allFasIdList = fasRecord.Id + ',' + fasRecord2.Id;
        AS_Quik_Forms__c asForms = createQuikForms(asRecord.Id, null, '12345Test', 'a222', allFasIdList);
        AS_Quik_Forms__c asForms1 = createQuikFormsFAS(asRecord.Id, null, '123456Test', '', fasRecord2.Id, allFasIdList);
        AS_Quik_Forms_Group__c asGroup = createQuikForm(fasRecord.Id);
        Recipients__c signer = createRecipients(asForms.Id, asGroup.Id);
        Recipients__c signer1 = createRecipients(asForms1.Id, asGroup.Id);
        Quik_Mapping__c quikMapp = createQuikMapping('O.State', 'AS', 'WEGP1_Secondary_Individual__r.LastName', true, false); 
        Quik_Form__c quikForm = creatQuikForm();
        Quik_Mapping__c quikMapp1 = createQuikMapping('O.State', 'AS', 'WEG_Items_to_Complete__c', true, true);
        Quik_Mapping__c quikMapp2 = createQuikMapping('FullName', 'FAS', 'Joint_Owner__r.Name', true, false);
        QuikFormHandler obj = new QuikFormHandler();
        String jsonBody = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody += '"formDesc": "To be", ';
        jsonBody += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"},';
        jsonBody += '{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        
        String jsonBody1 = '{"results": [{"key": "Household / Business","id": "' + asRecord.Id + '","records": [{ ';
        jsonBody1 += '"formId": "918","formShortName": "SEP-IRA Adoption Agreement","formDesc": "Used", ';
        jsonBody1 += '"dealerName": "Charles","fileCount":"2" },{"formId": "919","formShortName": "SEP", ';
        jsonBody1 += '"formDesc": "To be", ';
        jsonBody1 += '"dealerName": "Charles.","fileCount":"2"}]},{"key": "new Brokerage","id": "' + fasRecord.Id + '", ';
        jsonBody1 += '"records": [{"formId": "918","formShortName": "SEP","formDesc": "Used","dealerName": "Charles." ';
        jsonBody1 += ',"fileCount":"2"},{"formId": "919","formShortName": "SEP","formDesc": "To","dealerName": "Charles.","fileCount":"2"}]}]}';
        QuikFormHandler.getForms('All', 2, 1,'Print');
        As_quik_forms__c newForm = createAs_quik_forms(asRecord.Id, fasRecord.Id, allFasIdList);
        String attBody = 'Test';
        Attachment att = createAttchment('HTML_QuikForm_123', asRecord.Id);
        Attachment att1 = createAttchment('QuikForm_123', asForms.Id);
        QuikGenerateFormRequest.getHTMLFromQuik(newForm.UNID__c, 0);
        QuikGenerateHTML obj3 = new QuikGenerateHTML();
        apexpages.currentpage().getparameters().put('id', asForms.Id);
        ApexPages.currentpage().getparameters().put('type', 'eSign');
        ApexPages.currentpage().getparameters().put('showAttach', 'false');
        obj3.savedFormData = '\'' + 'QFVUNID=QFVUNID&1own.FullName=&1own.H.Email=&1own.H.Phone=&2own.FullName=&2own.H.Email=&2own.H.Phone=' 
            + '&1rep.FullName=&1rep.P.Email=&1rep.P.Phone=&1own.FullName-1=&1own.H.Email-1=&1own.H.Phone-1=&2own.FullName-1=&2own.H.Email-1' 
            + '=&2own.H.Phone-1=&1rep.FullName-1=&1rep.P.Email-1=&1rep.P.Phone=-1\'';
        QuikGenerateHTML.upsertQuikGroupForm(asForms.Id, 'Sign', '', 'no', 3);
        QuikGenerateHTML.upsertQuikGroupForm(asForms.Id, 'Sign', '', 'yes', 3);
        obj3.updateData();
        obj3.loadHTML();
        obj3.reloadForm();
        apexpages.currentpage().getparameters().put('id', asRecord.Id);
        obj3.attachmentBody = attBody;
        
        QuikGenerateHTML_Print obj31 = new QuikGenerateHTML_Print();
        ApexPages.currentpage().getparameters().put('id', asForms.Id);
        obj31.savedFormData = 'QFVUNID=QFVUNID&1own.FullName=&1own.H.Email=&1own.H.Phone=&2own.FullName=&2own.H.Email=&2own.H.Phone=' 
            + '&1rep.FullName=&1rep.P.Email=&1rep.P.Phone=\'';
        obj31.updateData();
        obj31.loadHTML();
        obj31.reloadForm();
        ApexPages.currentpage().getparameters().put('id', asRecord.Id);
        obj31.attachmentBody = attBody;
    }
    
    @isTest
    private static void test_for_QuikGenerateHTML_UpdateData() {
        Id RecordTypeIdHouseHold = getRecordTpe('Household');
        Id RecordTypeIdCustodian = getRecordTpe('Custodian');
        Id individualRecordId = getRecordTpe('Individual');
        Account ParentAccount = createAccount(RecordTypeIdCustodian, null);
        Account ParentAccount1 = createAccount(individualRecordId, null);
        Contact contactToInsert = createContact(ParentAccount.Id);
        Account accountToInsert = createAccount(RecordTypeIdHouseHold, contactToInsert.Id);
        Account_Servicing__c asRecord = createAccSer(accountToInsert.Id, contactToInsert.Id);
        Custodian_Info__c custodian =createCustodianInfo();
        Financial_Account_Servicing__c fasRecord =createFinAccSer(ParentAccount1.Id, asRecord.Id, 'TD Ameritrade', custodian.Id);
        Financial_Account_Servicing__c fasRecord1 = createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity', custodian.Id);
        Financial_Account_Servicing__c fasRecord2 =createFinAccSer(ParentAccount1.Id, asRecord.Id, 'Fidelity', custodian.Id);
        delete fasRecord1;
        String allFasIdList = fasRecord.Id + ',' + fasRecord2.Id;
        AS_Quik_Forms__c asForms = createQuikForms(asRecord.Id, null, '12345Test', 'a222', allFasIdList);
        AS_Quik_Forms__c asForms1 = createQuikFormsFAS(asRecord.Id, null, '123456Test', '', fasRecord2.Id, allFasIdList);
        AS_Quik_Forms_Group__c asGroup = createQuikForm(fasRecord.Id);
        Recipients__c signer = createRecipients(asForms.Id, asGroup.Id);
        Recipients__c signer1 = createRecipients(asForms1.Id, asGroup.Id);
        Quik_Mapping__c quikMapp = createQuikMapping('O.State', 'AS', 'WEGP1_Secondary_Individual__r.LastName', true, false);
        QuikGenerateHTML obj3 = new QuikGenerateHTML();
        obj3.savedFormData = 'QuikRadio.';
        obj3.updateData();
        
        QuikGenerateHTML_Print obj31 = new QuikGenerateHTML_Print();
        obj31.savedFormData = 'QuikRadio.';
        obj31.updateData();
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
    
    public static Contact createContact(Id accountId) {
        Contact contactToInsert = new Contact();
        contactToInsert.LastName = 'TestLastName';
        contactToInsert.AccountId = accountId;
        insert contactToInsert;
        return contactToInsert;
    }
    
    public static Account_Servicing__c createAccSer(Id accountId, Id ContactId) {
        Account_Servicing__c asRecord = new Account_Servicing__c();
        asRecord.WEG_Items_to_Complete__c = 'Test';
        asRecord.Related_Account__c = accountId;
        asRecord.WEGP1_Secondary_Individual__c = ContactId;
        insert asRecord; 
        return asRecord;
    }
    
    public static Financial_Account_Servicing__c createFinAccSer(Id parentaccountId, Id asRecordId, String custodian, Id custInfoId) {
        Financial_Account_Servicing__c fasRecord = new Financial_Account_Servicing__c();
        fasRecord.Account_Servicing__c = asRecordId;
        fasRecord.Primary_Owner__c = parentaccountId;
        fasRecord.Joint_Owner__c = parentaccountId;
        fasRecord.WEG_Custodian__c = custodian;
        fasRecord.WEG_Custodian_Info__c = custInfoId;
        insert fasRecord;
        return fasRecord;
    }
    
    public static AS_Quik_Forms_Group__c createQuikForm(Id fasRecord) {
        AS_Quik_Forms_Group__c asGroup = new AS_Quik_Forms_Group__c();
        asGroup.Financial_Account_Servicing__c=fasRecord;
        asGroup.Recipients_Size__c = 2;
        asGroup.UniqueId__c= '005R0000004zy6zIAA1588084474404';
        asGroup.Docusign_Envelope_Id__c = 'efff4480-7ae5-4e11-aeca-9e17ee2d310f';
        asGroup.DocuSign_Envelope_Status__c = 'Sent';
        insert asGroup;
        return asGroup;
    }
    
    public static AS_Quik_Forms_Group__c createQuikFormGroup(Id fasRecord, Id asRecord) {
        AS_Quik_Forms_Group__c asGroup = new AS_Quik_Forms_Group__c();
        asGroup.Financial_Account_Servicing__c=fasRecord;
        asGroup.Account_Servicing__c = asRecord;
        asGroup.Recipients_Size__c = 2;
        asGroup.UniqueId__c= '005R0000004zy6zIAA1588084474477';
        asGroup.Docusign_Envelope_Id__c = 'efff4480-7ae5-4e11-aeca-9e17ee2d220f';
        asGroup.DocuSign_Envelope_Status__c = 'Sent';
        insert asGroup;
        return asGroup;
    }
    
    public static AS_Quik_Forms_Group__c createQuikFormGroupAs(Id asRecord) {
        AS_Quik_Forms_Group__c asGroup = new AS_Quik_Forms_Group__c();
        asGroup.Account_Servicing__c = asRecord;
        asGroup.Recipients_Size__c = 2;
        asGroup.UniqueId__c= '005R0000004zy6zIAA1588084474493';
        asGroup.Docusign_Envelope_Id__c = 'efff4480-7ae5-4e11-aeca-9e17ee2d330f';
        asGroup.DocuSign_Envelope_Status__c = 'Sent';
        insert asGroup;
        return asGroup;
    }
    
    public static  AS_Quik_Forms__c createQuikForms(Id asRecord, Id asGroup, String UNID, String UniqueId, String allFasIdList) {
        AS_Quik_Forms__c asForms = new AS_Quik_Forms__c();
        asForms.Account_Servicing__c = asRecord;
        asForms.UNID__c = UNID;
        asForms.Form_Numbers__c = '123,456,789';
        asForms.FAS_Id_List__c = allFasIdList;
        asForms.AS_Quik_Forms_Group__c = asGroup;
        asForms.Form_HTML_URL__c = 'https://www.google.com';
        asForms.UniqueId__c = UniqueId;
        asForms.Form_No_with_Ids__c = '123:456-789:100';
        insert asForms;
        return asForms;
    }
    
    public static  AS_Quik_Forms__c createQuikFormsFAS(Id asRecord, Id asGroup, String UNID, String UniqueId, Id fasRec, String allFasIdList) {
        AS_Quik_Forms__c asForms = new AS_Quik_Forms__c();
        asForms.Account_Servicing__c = asRecord;
        asForms.Financial_Account_Servicing__c = fasRec;
        asForms.UNID__c = UNID;
        asForms.Form_Numbers__c = '123,456,789';
        asForms.FAS_Id_List__c = allFasIdList;
        asForms.AS_Quik_Forms_Group__c = asGroup;
        asForms.Form_HTML_URL__c = 'https://www.google.com';
        asForms.UniqueId__c = UniqueId;
        asForms.Form_No_with_Ids__c = '123:456-789:100';
        insert asForms;
        return asForms;
    }
    
    public static  Recipients__c createRecipients(Id asForms, Id asGroup) {
        Recipients__c signer1 = new Recipients__c();
        signer1.Name__c = 'Test';
        signer1.Email__c = 'Test@gmail.com';
        signer1.Phone_Number__c = '9876543210';
        signer1.Order__c = 1;
        signer1.Docusign_Recipient_Id__c = '1';
        signer1.Sign_Type__c = 'Sign';
        signer1.AS_Quik_Forms_Group__c = asGroup;
        signer1.AS_Quik_Form__c = asForms;
        insert signer1;
        return signer1;
    }
    
    public static  Quik_Mapping__c createQuikMapping(String WEG_Field ,String WEG_Origin,String WEG_SF_Reference, Boolean WEG_Editable, 
                                                     Boolean Required) 
    {
        Quik_Mapping__c quikMapp1 = new Quik_Mapping__c();
        quikMapp1.WEG_Field_Name__c = WEG_Field;
        quikMapp1.WEG_Origin__c = WEG_Origin;
        quikMapp1.WEG_Role_Name__c = '2own';
        quikMapp1.WEG_SF_Reference__c = WEG_SF_Reference;
        quikMapp1.WEG_Editable__c = WEG_Editable;
        quikMapp1.Required__c = Required;
        insert quikMapp1;
        return quikMapp1;
    }
    
    public static  Form_Bundle__c creatFormBundle() {
        Form_Bundle__c formBundle = new Form_Bundle__c();
        formBundle.Active__c = true;
        insert formBundle;
        return formBundle;
    }
    
    public static  Quik_Form__c creatQuikForm() {
        Quik_Form__c quikForm = new Quik_Form__c();
        quikForm.Custodian__c = 'test';
        quikForm.Form_Name__c = 'test';
        quikForm.Name = 'Test';
        quikForm.Description__c = 'Testing';
        insert quikForm;
        return quikForm;
    }
    
    public static  Bundled_Forms__c createBundledForms(Id quikForm, Id formBundle) {
        Bundled_Forms__c bundledForms = new Bundled_Forms__c();
        bundledForms.Form_Bundle__c = formBundle;
        bundledForms.Form_Name__c = 'test';
        bundledForms.Quik_Form__c = quikForm;
        bundledForms.WEG_Sort__c = 10;
        insert bundledForms;
        return bundledForms;
    }
    
    public static  Custodian_Info__c createCustodianInfo() {
        Custodian_Info__c custodian = new Custodian_Info__c();
        Custodian.Custodian_Name__c = 'TD Ameritrade';
        Custodian.Custodian_Email_1__c = 'vinathi97@gmail.com';
        Custodian.Custodian_Email_2__c = 'vinathi.v@bigworks.co';
        Custodian.Custodian_Phone__c = '7386333586';
        Custodian.WEG_eSign_Authorization_Type__c = 'SMS';
        Custodian.WEG_eSign_Enabled__c = true;
        insert custodian;
        return custodian;
    }
    
    public static  As_quik_forms__c createAs_quik_forms(Id asRecord, Id fasRec, String allFasIdList) {
        As_quik_forms__c newForm = new As_Quik_Forms__c();
        newForm.Account_Servicing__c = asRecord;
        newForm.Financial_Account_Servicing__c = fasRec;
        newForm.Form_Numbers__c = '123,456,789';
        newForm.Form_HTML_URL__c = 'https://www.google.com';
        newForm.UNID__c = 'UNIDik';
        newForm.Form_No_with_Ids__c = '1234:1345-1452:4562';
        newForm.Custodian__c = 'Fidelity';
        newForm.FAS_Id_List__c = allFasIdList;
        insert newForm;
        return newForm;
    }
    
    public static  Attachment createAttchment(String Name, Id asRecord) {
        String attBody = 'Test';
        Attachment att = new Attachment();
        att.Name = Name;
        att.ParentId = asRecord;
        att.Body = blob.valueOf(attBody);
        insert att;
        return att;
    }
    
    public static  Id getRecordTpe(String typeName) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(typeName).getRecordTypeId();
        return recordTypeId;
    }
}