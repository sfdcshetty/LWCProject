@IsTest
public class x7sKnowledgeBaseArticlesControllerTest {
	@IsTest
    public static void getKnowledgeBaseArticlesDetailsTest() {
        
        List<Knowledge__kav> listKnwArt = new List<Knowledge__kav>();    

        User portalAccountOwner1 = [SELECT Id FROM User WHERE User.Profile.Name = 'System Administrator' AND isActive = True AND UserPermissionsKnowledgeUser = True LIMIT 1];
        System.runAs(portalAccountOwner1) {
             Knowledge__kav knwArt1 = new Knowledge__kav(Title = 'Test Article1:', UrlName ='Test1',
                                                   Question__c = 'Is Test Article1 Article is usefull?',
                                                   Answer__c = 'Yes',
                                                   RecordTypeId =  Schema.sObjectType.Knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId());
        	insert knwArt1;
            listKnwArt.add(knwArt1);
        
        	Knowledge__kav Article = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knwArt1.Id];
        	KbManagement.PublishingService.publishArticle(Article.KnowledgeArticleId, true);   
        }
        
        Knowledge__kav knwArt2 = new Knowledge__kav(Title = 'Test Article2:', UrlName ='Test2',
                                                   Question__c = 'Is Test Article2 Article is usefull?',
                                                  Answer__c = 'No');
        insert knwArt2;
        
        
        listKnwArt.add(knwArt2);
        system.debug('knwArt2'+knwArt2);
        system.debug('knwArt2 id'+knwArt2.Id);
        List<Knowledge__kav> knowledgeArticlesList=[SELECT Id,Title, KnowledgeArticleId, PublishStatus, UrlName, ArticleNumber, RecordTypeId, AssignedToId, Answer__c, Question__c,FirstPublishedDate, LastPublishedDate FROM Knowledge__kav WHERE RecordType.Name='FAQ' LIMIT 10 OFFSET 0];
        system.debug('knowledgeArticlesList knwArt2 = '+knowledgeArticlesList);
        Test.startTest();

        List<Knowledge__kav> result1 = x7sKnowledgeBaseArticlesController.getKnowledgeBaseArticlesDetails('',10,1);
        system.assertNotEquals(null, result1.size());
        
        List<Knowledge__kav> result2 = x7sKnowledgeBaseArticlesController.getKnowledgeBaseArticlesDetails('Test',10,1);
        system.assertNotEquals(null, result2.size());
        
        Integer result3 = x7sKnowledgeBaseArticlesController.getArticleCount();
        system.assertNotEquals(null, result3);

        Test.stopTest();
        
    }
    
    @IsTest
    public static void shouldThrowExceptionWhenUserIsNotKnowledgeUser() {
        
        List<Knowledge__kav> listKnwArt = new List<Knowledge__kav>();    

        User portalAccountOwner1 = [SELECT Id FROM User WHERE User.Profile.Name = 'System Administrator' AND isActive = True AND UserPermissionsKnowledgeUser = False LIMIT 1];
        Boolean ExceptionThrown = false;
        Test.startTest();
        try{
            System.runAs(portalAccountOwner1) {
                 Knowledge__kav knwArt1 = new Knowledge__kav(Title = 'Test Article1:', UrlName ='Test1',
                                                       Question__c = 'Is Test Article1 Article is usefull?',
                                                       Answer__c = 'Yes',
                                                       RecordTypeId =  Schema.sObjectType.Knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId());
                insert knwArt1;
                listKnwArt.add(knwArt1);
            
                Knowledge__kav Article = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knwArt1.Id];
                KbManagement.PublishingService.publishArticle(Article.KnowledgeArticleId, true);   
            }         
        } Catch (Exception e){
                ExceptionThrown = True;
            }   
        Test.stopTest();
        System.assert(ExceptionThrown, 'Exception should be thrown');
    }
}