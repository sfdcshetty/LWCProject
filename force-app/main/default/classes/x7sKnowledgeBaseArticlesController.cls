public with sharing class x7sKnowledgeBaseArticlesController {
    
    @AuraEnabled (cacheable=true)
    public static List<Knowledge__kav> getKnowledgeBaseArticlesDetails(String searchTerm,Integer numberOfArticlesPerPage,Integer pageNumber){
        
        List<Knowledge__kav> knowledgeArticlesList = new List<Knowledge__kav>();

        //String Query = 'SELECT Id,Title, KnowledgeArticleId, PublishStatus, UrlName, ArticleNumber, RecordTypeId, AssignedToId, Answer__c, Question__c,FirstPublishedDate, LastPublishedDate FROM Knowledge__kav WHERE PublishStatus=\'Online\'';
        String Query = 'SELECT Id,Title, KnowledgeArticleId, PublishStatus, UrlName, ArticleNumber, RecordTypeId, AssignedToId, Answer__c, Question__c,FirstPublishedDate, LastPublishedDate FROM Knowledge__kav WHERE RecordType.Name=\'FAQ\' AND PublishStatus=\'Online\'';

        if(numberOfArticlesPerPage != null && numberOfArticlesPerPage > 0){
                Query += ' LIMIT' + ' '+ numberOfArticlesPerPage;
        }

        if(pageNumber != null && pageNumber > 0){
                Query += ' OFFSET' + ' ' +(numberOfArticlesPerPage * (pageNumber - 1));
        }
        System.debug('Test::::::' + Query);

        if (searchTerm != '' && searchTerm != null) {
            for(Knowledge__kav kav : Database.Query(Query)){
                if(kav.Title.containsIgnoreCase(searchTerm) || kav.Question__c.containsIgnoreCase(searchTerm))
                    knowledgeArticlesList.add(kav);
            }
        }
        else{
            knowledgeArticlesList = Database.Query(Query);
        }
        return knowledgeArticlesList;
    }
    
    @AuraEnabled(cacheable = true)  
   public static Integer getArticleCount() {  
        try{
            String query = 'select count() from Knowledge__kav WHERE RecordType.Name=\'FAQ\' AND PublishStatus=\'Online\''; 
            return Database.countQuery(query);  
        }
        catch (Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
}