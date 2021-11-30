/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

/**
 * The SuppressWarnings here is used to suppress warnings from PMD for Unused local variables.
 * They are used in the String version of a SOQL query statement.
 */

@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class x7sOnboardingController {

    private static final String ACTIVITY_ACTION_FOLLOW = 'Follow';
    private static final String ACTIVITY_ACTION_UNFOLLOW = 'Unfollow';
    // private static final String ACTIVITY_ACTION_JOIN = 'Join';
    // private static final String ACTIVITY_ACTION_LEAVE = 'Leave';

    //private static final String ACTIVITY_TYPE_GROUP = 'Group';
    private static final String ACTIVITY_TYPE_TOPIC = 'Topic';

    private static final String ACTIVITY_PROCESS_DEFAULT = 'Default';

    public class OnBoardingException extends Exception {}

    @TestVisible
    private class activityEntry {
        String id, name;

        public activityEntry(String entryId, String entryName) {
            this.id = entryId;
            this.name = entryName;
        }
    }

    @TestVisible
    private class ActivityTracking {
        public Boolean followTopic, unFollowTopic, joinGroup, leaveGroup;
    }

    @TestVisible
    private static ActivityTracking TrackActivities {
        get {
            if (TrackActivities == null) {
                String communityIdString = Network.getNetworkId();
                String communityQuery = 'SELECT Track_Join_Group__c, Track_Leave_Group__c, Track_Follow_Topic__c, Track_Unfollow_Topic__c FROM X7S_Onboarding_Setting__mdt WHERE Community_ID__c = :communityIdString LIMIT 1';

                if (Test.isRunningTest()) {
                    communityQuery = 'SELECT Track_Join_Group__c, Track_Leave_Group__c, Track_Follow_Topic__c, Track_Unfollow_Topic__c FROM X7S_Onboarding_Setting__mdt WHERE DeveloperName = \'Default\' LIMIT 1';
                }

                List<X7S_Onboarding_Setting__mdt> settings = (List<X7S_Onboarding_Setting__mdt>) Database.query(communityQuery);

                if (!settings.isEmpty()) {
                    ActivityTracking tracking = new ActivityTracking();

                    tracking.joinGroup = settings[0].Track_Join_Group__c;
                    tracking.leaveGroup = settings[0].Track_Leave_Group__c;
                    tracking.followTopic = settings[0].Track_Follow_Topic__c;
                    tracking.unFollowTopic = settings[0].Track_Unfollow_Topic__c;

                    TrackActivities = tracking;
                }
            }
            return TrackActivities;
        }

        set {
            TrackActivities = value;
        }
    }

    @TestVisible
    private static void DumpTracking() {
        System.debug('Tracking:');
        ActivityTracking myTracking = TrackActivities;

        System.debug('    join      : ' + myTracking.joinGroup);
        System.debug('    leave     : ' + myTracking.leaveGroup);
        System.debug('    follow    : ' + myTracking.followTopic);
        System.debug('    unFollow  : ' + myTracking.unFollowTopic);
    }

    @AuraEnabled
    public static User getUserRecord() {
        User currentUser = [
                SELECT X7S_Completed_Groups_Slide__c,
                        X7S_Last_Topic_Slide_Completed__c,
                        X7S_Completed_Notification_Slide__c,
                        X7S_Completed_Profile_Slide__c,
                        X7S_Completed_Topics_Slide__c,
                        X7S_Completed_Additional_User_Data__c,
                        X7S_Completed_Tours_Slide__c,
                        X7S_Completed_Welcome_Slide__c,
                        X7S_Agreed_to_Terms_and_Conditions__c,
                        FirstName,
                        LastName,
                        X7S_Onboarding_Complete__c,
                        Title,
                        CompanyName,
                        Email,
                        MobilePhone,
                        AboutMe,
                        X7S_Onboarding_Modal_Display_Count__c,
                        Profile.Name,
                        X7S_Hide_Modal_Onboarding__c,
                        X7S_Notification_Confirmation__c,
                        CommunityNickname
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];

        System.debug('currentUser returned => ' + currentUser);
        return currentUser;
    }

    @AuraEnabled
    public static Boolean getIsModalViewEnabled() {
        List<X7S_Onboarding_Setting__mdt> onboardingSetting = [
                SELECT Enable_Onboarding_via_Modal__c
                FROM X7S_Onboarding_Setting__mdt
                WHERE Community_ID__c = :Network.getNetworkId()
                LIMIT 1
        ];
        if (!onboardingSetting.isEmpty()) {
            System.debug('IsModalViewEnabled returned TRUE');
            return onboardingSetting[0].Enable_Onboarding_via_Modal__c;
        }
        System.debug('IsModalViewEnabled returned FALSE');
        return false;
    }

    @AuraEnabled
    public static X7S_Onboarding_Setting__mdt getDisplayLimit() {
        X7S_Onboarding_Setting__mdt onboardingDisplayLimit;

        try {
            onboardingDisplayLimit = [
                SELECT Modal_Display_Limit__c,Modal_Display_Limit_Exception__c
                FROM X7S_Onboarding_Setting__mdt
                WHERE Community_ID__c = :Network.getNetworkId()
            ];
        }
        catch (Exception ex) { System.debug('getDisplaySettings error: ' + ex.getMessage()); }

        System.debug('IsModalViewEnabled returned =>' + onboardingDisplayLimit);

        return onboardingDisplayLimit;
    }

    @AuraEnabled
    public static void updateUserNames(User currentUser) {
        if (!User.SObjectType.getDescribe().isUpdateable()) {
            System.debug('updateUserNames() - unable to update User object.');
            return;
        }

        update currentUser;
    }

    @AuraEnabled
    public static NetworkMember getMemberEmailPreference() {
        NetworkMember member;
        try {
            member = [
                SELECT PreferencesDisableAllFeedsEmail
                FROM NetworkMember
                WHERE MemberId = :UserInfo.getUserId() AND NetworkId = :Network.getNetworkId()
            ];
        }
        catch (Exception ex) { System.debug('getMemberEmailPreference error: ' + ex.getMessage()); }

        System.debug('getMemberEmailPreference returned =>' + member);
        return member;
    }

    @AuraEnabled
    public static String getCommunityTermsAndConditions() {
        String communityIdString = Network.getNetworkId();
        String communityQuery = 'SELECT Terms_and_Conditions__c FROM X7S_Onboarding_Setting__mdt WHERE Community_ID__c = :communityIdString LIMIT 1';
        if (Test.isRunningTest()) {
            communityQuery = 'SELECT Terms_and_Conditions__c FROM X7S_Onboarding_Setting__mdt WHERE DeveloperName = \'Default\' LIMIT 1';
        }

        X7S_Onboarding_Setting__mdt settings = (X7S_Onboarding_Setting__mdt) Database.query(communityQuery);
        String onboardingTermsAndComditions = settings.Terms_and_Conditions__c;
        System.debug('getCommunityTermsAndConditions returned =>' + onboardingTermsAndComditions);
        return onboardingTermsAndComditions;
    }

    @AuraEnabled
    public static void setAgreedTermsAndConditions(Boolean agreed) {
        if (!User.SObjectType.getDescribe().isUpdateable()) { System.debug('setAgreedTermsAndConditions()- Unable to update User');return; }

        update new User(Id = UserInfo.getUserId(), X7S_Agreed_to_Terms_and_Conditions__c = agreed);
    }

    @AuraEnabled
    public static void updatePreferences(Boolean decision) {
        try{
            List<NetworkMember> member = [
                    SELECT PreferencesDisableAllFeedsEmail
                    FROM NetworkMember
                    WHERE MemberId = :UserInfo.getUserId() AND NetworkId = :Network.getNetworkId()
                    WITH SECURITY_ENFORCED
            ];

            if (member.size() > 0) {
                if (decision) { member[0].PreferencesDisableAllFeedsEmail = false; }
                if (!decision) { member[0].PreferencesDisableAllFeedsEmail = true; }
            }

            if (!NetworkMember.SObjectType.getDescribe().isUpdateable()) { System.debug('Unable to update Network Member.');return; }

            update member;
        }
        catch (System.QueryException ex) { System.debug('updatePreferences()-- EXCEPTION:  ' + ex); throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied); }
    }

    @AuraEnabled
    public static String joinGroup(String groupId) {
        CollaborationGroupMember groupMember = new CollaborationGroupMember(
                CollaborationRole = 'Standard',
                MemberId = UserInfo.getUserId(),
                CollaborationGroupId = String.escapeSingleQuotes(groupId));

        if (!CollaborationGroupMember.SObjectType.getDescribe().isCreateable() ||
            !CollaborationGroupMember.SObjectType.getDescribe().isUpdateable()) {
            System.debug(' joinGroup() : cannot create/update CollaborationGroupMember object');
            throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied);
        }

        upsert groupMember;

        return groupMember.Id;
    }

    @AuraEnabled
    public static void updateFrequenv(String groupId, String notification) {
        List<CollaborationGroupMember> members = [
                SELECT Id, CollaborationGroupId, NotificationFrequency,CollaborationGroup.Name
                FROM CollaborationGroupMember
                WHERE MemberId = :UserInfo.getUserId() AND
                CollaborationGroupId = :groupId
        ];

        for (CollaborationGroupMember member : members) {
            member.NotificationFrequency = String.escapeSingleQuotes(notification);
        }
        
        System.debug('Member Janavi:' + members);

        update members;
    }
    @AuraEnabled
    public static void leaveGroup(String groupId) {
        if (!CollaborationGroupMember.SObjectType.getDescribe().isDeletable()) { System.debug('leaveGroup(): Unable to delete group ');return; }

        String userId = UserInfo.getUserId();
        CollaborationGroupMember membership = [
            SELECT Id FROM CollaborationGroupMember
            WHERE CollaborationGroupId = :groupId AND MemberId = :userId];

        if (membership != null) {
            delete membership;
        }
    }

    @AuraEnabled
    public static void completeSlide(String slide) {
        System.debug('---------------- slide received => ' + slide);
        if (!String.isBlank(slide)) {
            String queryString;
            Map <String, String> slideMap = new Map <String, String>{
                    'Welcome' => 'X7S_Completed_Welcome_Slide__c',
                    'Additional' => 'X7S_Completed_Additional_User_Data__c',
                    'Profile' => 'X7S_Completed_Profile_Slide__c',
                    'Notification' => 'X7S_Completed_Notification_Slide__c',
                    'Topic' => 'X7S_Completed_Topics_Slide__c',
                    'Group' => 'X7S_Completed_Groups_Slide__c',
                    'Tours' => 'X7S_Completed_Tours_Slide__c'
            };
            String slideName = slideMap.get(String.escapeSingleQuotes(slide));
            System.debug('------------slidename from map = ' + slideName);

            String userId = UserInfo.getUserId();

            if (slide != 'Done') {
                queryString = 'Select ' + slideName + ', X7S_Onboarding_Complete__c FROM User WHERE Id = :userId';
            }
            if (slide == 'hideModalByUser' || slide == 'showModalByUser') { queryString = 'Select X7S_Hide_Modal_Onboarding__c FROM User WHERE Id = :userId'; }
            if (slide == 'showNotification' || slide == 'hideNotification') { queryString = 'Select X7S_Notification_Confirmation__c FROM User WHERE Id = :userId'; }
            if (slide == 'displayLimit' || slide == 'setDisplay') { queryString = 'Select X7S_Onboarding_Modal_Display_Count__c FROM User WHERE Id = :userId';
            } else {
                queryString = 'Select X7S_Onboarding_Complete__c FROM User WHERE Id = :userId';
            }

            System.debug('-----------queryString == ' + queryString);
            User userRecord = Database.query(queryString);

            // complete slide checkbox as 'Save & Next' is hit.  These checkboxes keep track of the user's progress, and also
            // direct the user to the last uncompleted slide when this component is next initalized
            if (slide == 'setDisplay') { userRecord.X7S_Onboarding_Modal_Display_Count__c = 0;
            } else if (slide == 'hideModalByUser') { userRecord.X7S_Hide_Modal_Onboarding__c = true;
            } else if (slide == 'showNotification') { userRecord.X7S_Notification_Confirmation__c = true;
            } else if (slide == 'hideNotification') { userRecord.X7S_Notification_Confirmation__c = false;
            } else if (slide == 'showModalByUser') { userRecord.X7S_Hide_Modal_Onboarding__c = false;
            } else if (slide == 'displayLimit') { userRecord.X7S_Onboarding_Modal_Display_Count__c += 1;
            } else if (slide == 'Welcome') { userRecord.X7S_Completed_Welcome_Slide__c = true;
            } else if (slide == 'Profile') { userRecord.X7S_Completed_Profile_Slide__c = true;
            } else if (slide == 'Notification') { userRecord.X7S_Completed_Notification_Slide__c = true;
            } else if (slide == 'Topic') { userRecord.X7S_Completed_Topics_Slide__c = true;
            } else if (slide == 'Additional') { userRecord.X7S_Completed_Additional_User_Data__c = true;
            } else if (slide == 'Group') { userRecord.X7S_Completed_Groups_Slide__c = true;
            } else if (slide == 'Tours') { userRecord.X7S_Completed_Tours_Slide__c = true;
            } else if (slide == 'Done') { userRecord.X7S_Onboarding_Complete__c = true;
            }
            System.debug('userrecord: ' + userRecord);

            System.debug('userRecord in updated as =>' + userRecord);
            update userRecord;
        }
    }

    @AuraEnabled
    public static List <OnboardingWrapperForTopicOrCollabGroup> getGroups(List <Id> groupIds) {
        List<OnboardingWrapperForTopicOrCollabGroup> groupWrappers = new List<OnboardingWrapperForTopicOrCollabGroup>();
        Map <Id, String> groupsAlreadyJoined = new Map <Id, String>();
        for (CollaborationGroupMember grp : [
                SELECT CollaborationGroupId, NotificationFrequency,MemberId
                FROM CollaborationGroupMember
                WHERE MemberId = :UserInfo.getUserId()
        ]) {
            groupsAlreadyJoined.put(grp.CollaborationGroupId, grp.NotificationFrequency);
        }

        for (CollaborationGroup grp : [
                SELECT Id, Name, Description,OwnerId
                FROM CollaborationGroup
                WHERE Id IN :groupIds
        ]) {
            OnboardingWrapperForTopicOrCollabGroup wrapper = new OnboardingWrapperForTopicOrCollabGroup(grp.Name, grp.Id, false, grp.Description, 'W', grp.OwnerId);
            if (groupsAlreadyJoined.containsKey(grp.Id)) {
                wrapper.following = true;
                wrapper.notificationFrequency = groupsAlreadyJoined.get(grp.Id);
            }
            System.debug('Adding group: ' + wrapper);

            groupWrappers.add(wrapper);
        }
        System.debug('GetGroups: ' + groupWrappers);
        return groupWrappers;
    }

    @AuraEnabled
    public static ConnectApi.Photo uploadUserPhoto(Id documentId, String filename) {
        try {
            Id userId = UserInfo.getUserId();
            String communityId = Network.getNetworkId();

            // Take the first photo
            ContentVersion content = [
                    SELECT ContentModifiedById,ContentDocumentId,FileExtension,FileType,ContentSize,ContentUrl,VersionData,VersionNumber
                    FROM ContentVersion
                    WHERE ContentDocumentId = :documentId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
            ];

            if(Test.isRunningTest()){
                return null;
            }
            // Set photo
            ConnectApi.BinaryInput bi = new ConnectApi.BinaryInput(content.VersionData, 'image/' + content.FileType.toLowerCase(), filename);
            ConnectApi.UserProfiles.setPhoto(communityId, userId, bi);
            return ConnectApi.UserProfiles.getPhoto(communityId, userId);
        }
        catch (System.QueryException ex) { System.debug('uploadUserPhoto() -- EXCEPTION:  ' + ex); throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied); }
    }

    @AuraEnabled
    public static OnboardingWrapperForTopicOrCollabGroup getGroup(Id groupId) {
        try {
            Boolean following = false;
            String notification = 'W';

            Map <Id, String> groupsAlreadyJoined = new Map <Id, String>();
            for (CollaborationGroupMember grp : [
                    SELECT CollaborationGroupId, NotificationFrequency
                    FROM CollaborationGroupMember
                    WHERE MemberId = :UserInfo.getUserId() AND
                    CollaborationGroupId = :groupId
            ]) {
                groupsAlreadyJoined.put(grp.CollaborationGroupId, grp.NotificationFrequency);
            }

            CollaborationGroup grp = [
                    SELECT Id, Name, Description,OwnerId
                    FROM CollaborationGroup
                    WHERE Id = :groupId
                    WITH SECURITY_ENFORCED
            ];

            if (groupsAlreadyJoined.containsKey(grp.Id)) {
                following = true;
                notification = groupsAlreadyJoined.get(grp.Id);
            }

            OnboardingWrapperForTopicOrCollabGroup wrapper = new OnboardingWrapperForTopicOrCollabGroup(grp.Name, grp.Id, following, grp.Description, notification, grp.OwnerId);
            return wrapper;
        }
        catch (System.QueryException ex) { System.debug('getGroup() -- EXCEPTION:  ' + ex); throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied); }
    }

    @AuraEnabled
    public static void removeGroupMember(Id groupId) {

        List <CollaborationGroupMember> grps = [
                SELECT CollaborationGroupId
                FROM CollaborationGroupMember
                WHERE MemberId = :UserInfo.getUserId() AND
                CollaborationGroupId = :groupId
        ];

        if (grps.size() > 0) {
            CollaborationGroupMember grpMember = grps[0];
            delete grpMember;
        }
    }

    @AuraEnabled
    public static void followTopic(String topicId) {
        try {
            List <EntitySubscription> memberIds = [
                    SELECT ParentId, SubscriberId
                    FROM EntitySubscription
                    WHERE SubscriberId = :UserInfo.getUserId() AND
                    ParentId = :topicId
                    WITH SECURITY_ENFORCED
                    LIMIT 500
            ];

            if (memberIds.size() == 0) {
                if (!EntitySubscription.SObjectType.getDescribe().isCreateable()) { System.debug('Unable to add subscription.');return; }

                EntitySubscription subscription = new EntitySubscription();
                subscription.ParentId = topicId;
                subscription.SubscriberId = UserInfo.getUserId();

                String topicName = [SELECT Id, Name FROM Topic WHERE Id = :topicId].Name;
                String communityIdString = Network.getNetworkId();
                subscription.NetworkId = communityIdString;

                insert subscription;

                if (TrackActivities.followTopic) {
                    AddActivities(new List<activityEntry>{ new activityEntry(topicId, topicName)
                    }, ACTIVITY_ACTION_FOLLOW, ACTIVITY_TYPE_TOPIC, ACTIVITY_PROCESS_DEFAULT);
                }
            } else {
                System.debug('already following, no subscription');
            }
        }
        catch (System.QueryException ex) { System.debug('getGroup() -- EXCEPTION:  ' + ex); throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied); }
    }

    @AuraEnabled
    public static void unfollowTopic(String topicId) {
        List <EntitySubscription> memberIds = [
                SELECT Id, ParentId, SubscriberId, Parent.Name
                FROM EntitySubscription
                WHERE SubscriberId = :UserInfo.getUserId()
                AND ParentId = :topicId
                LIMIT 500
        ];

        if (memberIds.size() > 0) {
            if (!EntitySubscription.SObjectType.getDescribe().isDeletable()) { System.debug('Unable to unfollow subscription.');return; }

            EntitySubscription subscriptionToDelete = memberIds[0];

            delete subscriptionToDelete;

            if (TrackActivities.unFollowTopic) {
                AddActivities(new List<activityEntry>{
                        new activityEntry(subscriptionToDelete.Id, subscriptionToDelete.Parent.Name)
                }, ACTIVITY_ACTION_UNFOLLOW, ACTIVITY_TYPE_TOPIC, ACTIVITY_PROCESS_DEFAULT);
            }
        }
    }

    @AuraEnabled
    public static List <OnboardingWrapperForTopicOrCollabGroup> getTopics(List <Id> topicIds) {
        List<OnboardingWrapperForTopicOrCollabGroup> topicWrappers = new List<OnboardingWrapperForTopicOrCollabGroup>();
        Set <Id> topicsAlreadyFollowedIds = new Set <Id>();
        for (EntitySubscription member : [
                SELECT ParentId
                FROM EntitySubscription
                WHERE SubscriberId = :UserInfo.getUserId()
                LIMIT 500
        ]) {
            topicsAlreadyFollowedIds.add(member.ParentId);
        }

        for (Topic top : [
                SELECT Id, Name
                FROM Topic
                WHERE Id IN :topicIds
        ]) {
            OnboardingWrapperForTopicOrCollabGroup wrapper = new OnboardingWrapperForTopicOrCollabGroup(top.Name, top.Id, false, null, null, null);

            if (topicsAlreadyFollowedIds.contains(top.Id)) {
                wrapper.following = true;
            }
            topicWrappers.add(wrapper);
        }

        return topicWrappers;
    }

    @AuraEnabled
    public static List<TopicSlide> grabTopics() {
        try {
            List<X7S_Onboarding_Topic_Setting__mdt> topicSettings = [
                    SELECT Id, Parent_Label__c, Topic_Ids__c,Message__c,Action__c, Label, Max_Topics_Per_Page__c, Sequence__c
                    FROM X7S_Onboarding_Topic_Setting__mdt
                    WITH SECURITY_ENFORCED
                    ORDER BY Sequence__c ASC NULLS LAST
            ];

            List<String> topicIds = new List<String>();
            if(Test.isRunningTest()) {
                List<Topic> testTopics = [SELECT Id FROM Topic];
                String topicList = '';
                for(Topic t : testTopics) {
                    if(topicList.length()>0) { topicList += ','; }
                    topicList += t.Id;
                }
                topicSettings.add(new X7S_Onboarding_Topic_Setting__mdt(MasterLabel='Test', DeveloperName='Test', Parent_Label__c='Test', Topic_Ids__c=topicList));
                System.debug('-------- topicSettings: ' + topicSettings);
            }

            for (X7S_Onboarding_Topic_Setting__mdt topicSetting : topicSettings) {
                if(topicSetting.Topic_Ids__c != null) {
                    String topicIdString = topicSetting.Topic_Ids__c.trim();
                    List<String> singleTopicIds = topicIdString.split(',');
                    topicIds.addAll(singleTopicIds);
                }
            }

            Set <Id> topicsAlreadyFollowedIds = new Set <Id>();
            for (EntitySubscription member : [
                    SELECT ParentId
                    FROM EntitySubscription
                    WHERE SubscriberId = :UserInfo.getUserId()
                    LIMIT 500
            ]) { topicsAlreadyFollowedIds.add(member.ParentId); }

            Map<Id, OnboardingWrapperForTopicOrCollabGroup> topicWrappers = new Map<Id, OnboardingWrapperForTopicOrCollabGroup>();

            for (Topic top : [SELECT Id, Name FROM Topic WHERE Id IN :topicIds]) {
                OnboardingWrapperForTopicOrCollabGroup wrapper = new OnboardingWrapperForTopicOrCollabGroup(top.Name, top.Id, false, null, null, null);

                if (topicsAlreadyFollowedIds.contains(top.Id)) { wrapper.following = true; }
                topicWrappers.put(top.Id, wrapper);
            }

            List<TopicSlide> topicSlides = new List<TopicSlide>();

            for (X7S_Onboarding_Topic_Setting__mdt topicSetting : topicSettings) {
                if(topicSetting.Topic_Ids__c != null) {
                    String topicIdString = topicSetting.Topic_Ids__c.trim();
                    List<String> singleTopicIds = topicIdString.split(',');

                    List<OnboardingWrapperForTopicOrCollabGroup> onboardingWrappers = new List<OnboardingWrapperForTopicOrCollabGroup>();
                    for (String singleTopicId : singleTopicIds) {

                        OnboardingWrapperForTopicOrCollabGroup onboardingWrapper = topicWrappers.get(singleTopicId);
                        onboardingWrappers.add(onboardingWrapper);
                    }

                    TopicSlide newTopicSlide = new TopicSlide(onboardingWrappers, topicSetting.Parent_Label__c, topicSetting.Message__c, topicSetting.Action__c, topicSetting.Label, topicSetting.Max_Topics_Per_Page__c);
                    topicSlides.add(newTopicSlide);
                }
            }

            System.debug('grabTopics returned =>' + topicSlides);

            return topicSlides;
        }
        catch (System.QueryException ex) { System.debug('grabTopics() -- EXCEPTION:  ' + ex);throw new OnBoardingException(System.Label.x7sOnBoardingCRUDAccessDenied); }
    }

    public class OnboardingWrapperForTopicOrCollabGroup {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Boolean following { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String notificationFrequency { get; set; }
        @AuraEnabled
        public String ownerid { get; set; }

        public OnboardingWrapperForTopicOrCollabGroup(String name, String id, Boolean following, String theDescription, String frequency, String ownerid) {
            this.name = name;
            this.id = id;
            this.following = following;
            this.description = theDescription;
            this.notificationFrequency = frequency;
            this.ownerid = ownerid;
        }

    }

    public class TopicSlide {
        @AuraEnabled
        public List<OnboardingWrapperForTopicOrCollabGroup> topics { get; set; }
        @AuraEnabled
        public String parentLabel { get; set; }
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String action { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal maxTopics { get; set; }

        public TopicSlide(List<OnboardingWrapperForTopicOrCollabGroup> wrappers, String slideName, String message, String action, String labelString, Decimal perPageTopics) {
            this.parentLabel = slideName;
            this.message = message;
            this.action = action;
            this.topics = wrappers;
            this.label = labelString;
            this.maxTopics = perPageTopics;
        }
    }

    @TestVisible
    private static void AddActivities(List<activityEntry> entityList, String actionType, String activityType, String processName) {

        if (!X7S_Onboarding_Activity__c.SObjectType.getDescribe().isCreateable()) { System.debug('AddActivities(): Unable to create x7s_Onboarding_Activity__c object'); return;
        }

        List<X7S_Onboarding_Activity__c> activities = new List<X7S_Onboarding_Activity__c>();

        for (activityEntry entityEntry : entityList) {
            activities.add(new X7S_Onboarding_Activity__c(
                    Community_Id__c = System.Network.getNetworkId(),
                    Action_Type__c = actionType,
                    Activity_Type__c = activityType,
                    Process_Name__c = processName,
                    Entity_Record_ID__c = entityEntry.id,
                    Entity_Name__c = entityEntry.name));
        }

        insert activities;
    }

}