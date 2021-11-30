public without sharing class PortalToDoClass {

  @AuraEnabled
  public static List<ToDo__c> getTodos() {
    Id userId = UserInfo.getUserId();
    List<User> lstUser = [
            SELECT u.ContactId,u.AccountId, u.Contact.AccountId, u.Contact.Account.WEGP1_Primary_Household__c
            FROM User u
            WHERE u.Id = :userId
    ];
    System.debug('lstUser='+lstUser[0]);
    if(lstUser.size() > 0){
      User u = lstUser[0];
      Id contactId = u.ContactId;
      //Added By Janavi
      Id householdId = u?.Contact?.Account?.WEGP1_Primary_Household__c;
      
      if(householdId != null){
        List<Account> lstAccountIndividuals = [SELECT Id,WEGP1_Primary_Individual__c,WEGP1_Primary_Individual__r.Name,WEGP1_Secondary_Individual__c,WEGP1_Secondary_Individual__r.Name From Account Where Id = :householdId];
        String query = 'SELECT Id, Name, ToDo_Description__c, Is_Document_Request__c,Is_Completed__c, Due_Date__c,Completed_Date__c FROM ToDo__c';

        if(lstAccountIndividuals.size() > 0){
          String hhMember1 = lstAccountIndividuals[0].WEGP1_Primary_Individual__c;
          String hhMember2 = lstAccountIndividuals[0].WEGP1_Secondary_Individual__c;
          if(hhMember1 != null){
            query += ' WHERE Assigned_To_Individual__c =:hhMember1';
          }
          if(hhMember2 != null){
            query += ' OR Assigned_To_Individual__c =:hhMember2';
          }
        }
        System.debug('UAT-TO-DO--FINAL-QUERY===>'+query);
        System.debug('UAT-TO-DO---QUERY===>'+Database.query(query));
        return Database.query(query);
      }
    }

    return new List<ToDo__c>();
  }

  @AuraEnabled
  public static void updateTodo(String Id, Boolean Status) {
    Id toDoId = Id;
    ToDo__c toDo = [SELECT Id, Is_Completed__c, Completed_Date__c FROM ToDo__c WHERE Id = :toDoId LIMIT 1];
    try {
      toDo.Is_Completed__c = Status;

      if (Status == true) {
        toDo.Completed_Date__c = System.today();
      } else {
        toDo.Completed_Date__c = null;
      }

      update toDo;
    } catch (Exception e) {
      System.debug('An unexpected error has occurred: ' + e.getMessage());
    }
  }

}