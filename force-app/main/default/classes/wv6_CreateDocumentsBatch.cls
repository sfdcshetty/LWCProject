/******************************************************************************************************************************
* @class name    : wv6_CreateDocumentsBatch
* @description   : This Class Implements Database.Batchable interface to create Document record for each Household & Business acccount.
* @steps to run batch : 1) Open Developer Console
*                       2) Press Ctrl+E
*                       3) Enter following apex code
*                            wv6_CreateDocumentsBatch batchCls =new wv6_CreateDocumentsBatch();
*                            database.executeBatch(batchCls);
*                       4) Click Execute
*                       5) We can track batch processing job at Setup-->Jobs -->Apex Jobs
*
* @test class    : 
* @author        : Ganesh Ekhande
* @date          : 03/21/2018
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              03/21/2018             Created.
******************************************************************************************************************************/
public class wv6_CreateDocumentsBatch implements Database.Batchable<sObject> {
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Start method of Database.Batchable interfcae which fetches all Business & Household Accounts.
    * @created      : 03/21/2018
    * @param        : Database.BatchableContext BC
    * @return       : Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        // Fetch Household Account Record Type Id
        set<string> recTypeIds = new set<string>();
        recTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        recTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        
        // Form a query to fetch Household Accounts Which Needs review this Month.
        String qry ='SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c ' +
                    ' FROM Account ' +
                    ' WHERE RecordTypeId IN:recTypeIds AND Id NOT IN (SELECT Account__c FROM Document__c)';
        system.debug('qry:>>'+qry);
        return Database.getQueryLocator(qry);    
        
    }
    
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Execute method of Database.Batchable interfcae which create Document record for each  Household & Business acccount.
    * @created      : 03/21/2018
    * @param        : Database.BatchableContext BC,List<Account> accList
    * @return       : void
    */
    public void execute(Database.BatchableContext BC, List<Account> accList){
        list<Document__c> documents = new list<Document__c>();
        
        for(Account acc: accList){
            Document__c doc = new Document__c();
            string accName = '';
            if(acc.Name.length()>60){
               accName =  acc.Name.left(60);
            }else{
                accName =  acc.Name;
            }
            doc.Name = accName + ' Portal Documents';
            doc.Account__c = acc.Id;
            doc.Primary_Portal_Contact__c = acc.WEGP1_Primary_Individual__c;
            doc.Secondary_Portal_Contact__c = acc.WEGP1_Secondary_Individual__c;
            documents.add(doc);
        }
        
        if(!documents.isEmpty()){
            insert documents;
        }
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Finish method of Database.Batchable interfcae.
    * @created      : 03/21/2018
    * @param        : Database.BatchableContext BC
    * @return       : void
    */
    public void finish(Database.BatchableContext BC){
    }
}