/**
 * Created by 7Summits on 5/12/21.
 */

public without sharing class x7s_MyTeamController {

    public class TeamMember{
        @AuraEnabled
        public String Title;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String photoUrl;
        @AuraEnabled
        public User User;

        public TeamMember(){
            photoUrl = '/clientportal/profilephoto/005/M';
        }

        public TeamMember(Team_Member__c member){
            User = member.Team_Member__r;
            Title = member.Team_Member__r.Title;
            type = member.Type__c;
            photoUrl = '/clientportal/profilephoto/005/M';
            if(member.Team_Member__c != null && member.Team_Member__r.Photo_URL__c != null){
                photoUrl = member.Team_Member__r.Photo_URL__c;
            }
        }

    }

    @AuraEnabled
    public static List<TeamMember> getTeamOwnerPhone(String userId){
        try{
            List<User> userQuery = [
                    SELECT Id, Title,
                            ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c, Contact.Account.WEGP1_Primary_Household__r.OwnerId,
                            EmployeeNumber, Photo_URL__c, Phone, WEG_Public_Display_Name__c
                    FROM User
                    WHERE Id = :userId
            ];
            if(userQuery.size() > 0){

                System.debug('userQuery='+userQuery[0]);

                User u = userQuery[0];

                String AdvisorId = u.Contact?.Account?.WEGP1_Primary_Household__r?.OwnerId;
                if(AdvisorId != null){

                    List<TeamMember> returnWrapperList = new List<TeamMember>();

                    List<User> advisorQuery = [
                            SELECT Id, Name, FirstName, LastName,
                                    Team_Phone__c, Photo_URL__c, Phone
                            FROM User
                            WHERE Id = :AdvisorId
                    ];

                    if(advisorQuery.size() > 0){
                        User advisorUser = advisorQuery[0];
                        TeamMember advisor = new TeamMember();
                        advisor.User = advisorUser;
                        advisor.Title = 'Primary Advisor';
                        if(advisorUser.Photo_URL__c != null) {
                            advisor.photoUrl = advisorUser.Photo_URL__c;
                        }

                        returnWrapperList.add(advisor);
                    }

                    return returnWrapperList;
                }
            }

        }catch(Exception ex){
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage() + ' ' + ex.getLineNumber());
        }
        return null;
    }

    @AuraEnabled
    public static List<TeamMember> getTeamMembersForCurrentUsersAdvisor(){
        return getTeamMembersForUser(UserInfo.getUserId());

    }

    @AuraEnabled
    public static List<TeamMember> getTeamMembersForUser(String userId){
        try{
            List<User> userQuery = [
                    SELECT Id, Title,
                            ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c, Contact.Account.WEGP1_Primary_Household__r.OwnerId, 
							Contact.Account.WEGP1_Primary_Individual__r.Account.WEGP1_Primary_Household__r.Owner.Client_Team__c, 
							Contact.Account.WEGP1_Secondary_Individual__r.Account.Owner.Client_Team__c,
                            EmployeeNumber, Photo_URL__c, Contact.Account.WEGP1_Primary_Household__r.WEGP1_Tax_Preparer__c, 
							Contact.Account.WEGP1_Primary_Household__r.WEGP1_Secondary_Advisor__c,
                            Contact.Account.WEGP1_Primary_Household__r.WEG_Investment_Officer__c, Phone, WEG_Public_Display_Name__c,
							Contact.Account.WEGP1_Primary_Household__r.WEG_Trust_Officer__c, Client_Team__c,Contact.Account.Owner.Client_Team__c 
                    FROM User
                    WHERE Id = :userId
            ];
            if(userQuery.size() > 0){

                System.debug('userQuery='+userQuery[0]);

                User u = userQuery[0];

                Id AdvisorId = u.Contact?.Account?.WEGP1_Primary_Household__r?.OwnerId;
                
                List<User> advisorUserClientTeamIDQuery = [SELECT Id, user.Client_Team__c FROM User WHERE Id = :AdvisorId];
                User advisorClientTeam = advisorUserClientTeamIDQuery[0];
                String ClientTeamID = advisorClientTeam.Client_Team__c;
                
                if(AdvisorId != null){

                    List<TeamMember> returnWrapperList = new List<TeamMember>();
                    Set<String> duplicateCheck = new Set<String>();

                    List<User> advisorQuery = [
                            SELECT Name, FirstName, LastName,
                                    Photo_URL__c, FullPhotoUrl, MediumPhotoUrl, SmallPhotoUrl,
                                    AboutMe, Team_Bio__c, Title, EmployeeNumber, Phone, WEG_Public_Display_Name__c,
                                    Email, Team_Phone__c, LinkedIn_URL__c, Client_Team__c
                            FROM User
                            WHERE Id = :AdvisorId
                    ];
                    if(advisorQuery.size() > 0){
                        User advisorUser = advisorQuery[0];
                        TeamMember advisor = new TeamMember();
                        advisor.User = advisorUser;
                        if(String.isBlank(advisorUser.Title)) {
                            advisor.Title = 'Primary Advisor';
                        } else {
                            advisor.Title = advisorUser.Title;
                        }

                        if(advisorUser.Photo_URL__c != null) {
                            advisor.photoUrl = advisorUser.Photo_URL__c;
                        }
                        if(!duplicateCheck.contains(advisor.User.Email)){
                           	returnWrapperList.add(advisor); 
                            duplicateCheck.add(advisor.User.Email);
                        }
                    }

                    String secondaryAdvisorId = u.Contact?.Account?.WEGP1_Primary_Household__r?.WEGP1_Secondary_Advisor__c;

                    List<User> secondaryAdvisorQuery = [
                            SELECT Id, Name, FirstName, LastName,
                                    Photo_URL__c, FullPhotoUrl, MediumPhotoUrl, SmallPhotoUrl,
                                    AboutMe, Team_Bio__c, Title, EmployeeNumber,
                                    Email, Team_Phone__c, LinkedIn_URL__c, Phone, WEG_Public_Display_Name__c
                            FROM User
                            WHERE Id = :secondaryAdvisorId
                    ];
                    if(secondaryAdvisorQuery.size() > 0){
                        User secondaryAdvisorUser = secondaryAdvisorQuery[0];
                        TeamMember secondaryAdvisor = new TeamMember();
                        secondaryAdvisor.type = 'Secondary Advisor';
                        secondaryAdvisor.User = secondaryAdvisorUser;
                        if(String.isBlank(secondaryAdvisorUser.Title)) {
                            secondaryAdvisor.Title = 'Secondary Advisor';
                        } else {
                            secondaryAdvisor.Title = secondaryAdvisorUser.Title;
                        }
                        
                        if(secondaryAdvisorUser.Photo_URL__c != null) {
                            secondaryAdvisor.photoUrl = secondaryAdvisorUser.Photo_URL__c;
                        }
                        if(!duplicateCheck.contains(secondaryAdvisor.User.Email)){
                            returnWrapperList.add(secondaryAdvisor);
                            duplicateCheck.add(secondaryAdvisor.User.Email);          
                        }
                    }

                    //Add additional related users on the household
                    List<Id> relatedUserIds = new List<Id>();
                    relatedUserIds.add(u.Contact?.Account?.WEGP1_Primary_Household__r?.WEGP1_Tax_Preparer__c);
                    relatedUserIds.add(u.Contact?.Account?.WEGP1_Primary_Household__r?.WEG_Investment_Officer__c);
                    relatedUserIds.add(u.Contact?.Account?.WEGP1_Primary_Household__r?.WEG_Trust_Officer__c);
                    List<User> relatedUsers = [SELECT Id, Name, FirstName, LastName,
                            Photo_URL__c, FullPhotoUrl, MediumPhotoUrl, SmallPhotoUrl,
                            AboutMe, Team_Bio__c, Title, EmployeeNumber,
                            Email, Team_Phone__c, LinkedIn_URL__c, Phone, WEG_Public_Display_Name__c FROM User WHERE Id IN: relatedUserIds];
                    for(User relatedUser : relatedUsers) {
                        TeamMember extraMember = new TeamMember();
                        extraMember.type = 'Specialist';
                        extraMember.User = relatedUser;
                        extraMember.Title = relatedUser.Title;
                        if(String.isNotBlank(relatedUser.Photo_URL__c)){
                            extraMember.photoUrl = relatedUser.Photo_URL__c;
                        }
                        if(!duplicateCheck.contains(extraMember.User.Email)){
                            returnWrapperList.add(extraMember);
                            duplicateCheck.add(extraMember.User.Email);          
                        }
                        
                    }

                    for(Team_Member__c member : [
                            SELECT Id,  Team_Member__c, Type__c,
                                    Team_Member__r.Name, Team_Member__r.FirstName, Team_Member__r.LastName, Team_Member__r.Phone, Team_Member__r.WEG_Public_Display_Name__c,
                                    Team_Member__r.Photo_URL__c, Team_Member__r.FullPhotoUrl, Team_Member__r.MediumPhotoUrl, Team_Member__r.SmallPhotoUrl,
                                    Team_Member__r.AboutMe, Team_Member__r.Team_Bio__c, Team_Member__r.Title, Team_Member__r.EmployeeNumber, Portal_Client_Team__c,
                                    Team_Member__r.Email, Team_Member__r.Team_Phone__c, Team_Member__r.LinkedIn_URL__c, Portal_Client_Team__r.OwnerId, Display_On_Portal__c
                            FROM Team_Member__c
                        	WHERE Portal_Client_Team__c = :ClientTeamID AND Display_On_Portal__c = TRUE
                            ORDER BY Team_Member__r.LastName, Display_On_Portal__c ASC
                    ]) {

                        TeamMember newMember = new TeamMember(member);
                        if(!duplicateCheck.contains(newMember.User.Email)){
                            returnWrapperList.add(newMember);
                            duplicateCheck.add(newMember.User.Email);
                            
                        }
                    }

                    return returnWrapperList;
                }
            }

        }catch(Exception ex){
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage() + ' ' + ex.getLineNumber());
        }
        return null;
    }

    @AuraEnabled
    public static User getTeamMemberDetailsByUserId(String userId){
        try{
            List<User> userQuery = [
                    SELECT Id, Name, FirstName, LastName,
                            Photo_URL__c, FullPhotoUrl, MediumPhotoUrl, SmallPhotoUrl,
                            AboutMe, Team_Bio__c, Title, EmployeeNumber,
                            Email, Team_Phone__c, LinkedIn_URL__c, Phone, WEG_Public_Display_Name__c
                    FROM User
                    WHERE Id = :userId
            ];

            if(userQuery.size() > 0){
                return userQuery[0];
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' ' + ex.getLineNumber());
        }

        return null;
    }
}