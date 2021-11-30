@isTest
private class WEG_FulfillmentRequestTriggerTest {
    
    private static testMethod void testTrigger(){
        test.startTest();
        
        Fullfillment_Item__c fItem1 = new Fullfillment_Item__c (Name = 'Book');
        insert fItem1;
        Fullfillment_Item__c fItem2 = new Fullfillment_Item__c (Name = 'Magazine');
        insert fItem2;
        Fullfillment_Item__c fItem3 = new Fullfillment_Item__c (Name = 'Brochure');
        insert fItem3;
        Fullfillment_Item__c fItem4 = new Fullfillment_Item__c (Name = 'Digital Download');
        insert fItem4;
      
        Lead ld = new Lead(
            FirstName = 'Test WEG',
            LastName = 'Lead',
            Phone = '1122334455',
            Email = 'lead@weg.com',
            Company = 'Test WEG Lead',
            Status = 'New');
        insert ld;
      
        Fulfillment_Request__c leadRequest = new Fulfillment_Request__c(
            WEGP1_Status__c = 'Open',
            WEGP1_Lead__c = ld.Id,
            WEGP1_Fulfillment_Item_1__c = fItem1.Id,
            WEGP1_Fulfillment_Item_2__c = fItem2.Id,
            WEGP1_Fulfillment_Item_3__c = fItem3.Id,
            WEGP1_Fulfillment_Item_4__c = fItem4.Id);
        insert leadRequest;
        
        Contact ctc = new Contact(
            FirstName = 'Test WEG',
            LastName = 'Contact',
            Phone = '1122334455',
            Email = 'lead@weg.com');
        insert ctc;
        
        Contact tc1 = [SELECT Id, WEGP1_FulfillmentItems__c FROM Contact WHERE Id =: ctc.Id];
        System.assertEquals(null, tc1.WEGP1_FulfillmentItems__c);
        
        Fulfillment_Request__c contactRequest = new Fulfillment_Request__c(
            WEGP1_Status__c = 'Open',
            WEGP1_Contact__c = ctc.Id,
            WEGP1_Fulfillment_Item_1__c = fItem1.Id,
            WEGP1_Fulfillment_Item_2__c = fItem2.Id,
            WEGP1_Fulfillment_Item_3__c = fItem3.Id,
            WEGP1_Fulfillment_Item_4__c = fItem4.Id);
        insert contactRequest;
        
        Contact tc2 = [SELECT Id, WEGP1_FulfillmentItems__c FROM Contact WHERE Id =: ctc.Id];
        System.assertEquals('Book, Magazine, Brochure, Digital Download', tc2.WEGP1_FulfillmentItems__c);
        
        leadRequest.WEGP1_Status__c = 'Completed';
        update leadRequest;
        
        leadRequest.WEGP1_Status__c = 'Open';
        update leadRequest;
        
        ctc.WEGP1_LeadFulfillmentItems__c = 'Email';
        update ctc;
        
        contactRequest.WEGP1_Fulfillment_Item_4__c = null;
        contactRequest.WEGP1_Status__c = 'Completed';
        update contactRequest;
        
        Contact tc3 = [SELECT Id, WEGP1_FulfillmentItems__c FROM Contact WHERE Id =: ctc.Id];
        System.assertEquals('Email, Book, Magazine, Brochure', tc3.WEGP1_FulfillmentItems__c);
        
        delete leadRequest;
        delete contactRequest;
        
        test.stopTest();
    }
}