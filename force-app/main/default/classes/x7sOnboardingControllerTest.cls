/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

@IsTest
public with sharing class x7sOnboardingControllerTest {

    @testSetup
	public static void setup() {
		List<X7S_Onboarding_Setting__mdt> settings = [SELECT Community_ID__c FROM X7S_Onboarding_Setting__mdt WHERE DeveloperName = 'Default'];

		Id networkId;
		List <Network> testNetworkList;

		testNetworkList = [SELECT Id FROM Network WHERE Id = :settings[0].Community_ID__c];

		if (testNetworkList != null && testNetworkList.size() > 0) {
			networkId = testNetworkList[0].Id;
		} else {
			// pick the first network that is not DwnForMaintenance
			testNetworkList = [SELECT Id FROM Network WHERE Status IN ('Live', 'UnderConstruction', 'Preview')];
			networkId = testNetworkList[0].Id;
		}
		

		Test.startTest();
		
		User testUser = x7sOnboardingTestUtils.createStandardUserNoContact();
		insert testUser;
		System.assertNotEquals(null, testUser);
		Test.stopTest();
		
        System.runAs(testUser) {
            List <CollaborationGroup> testGroups = new List <CollaborationGroup>();
            for (Integer i = 0; i < 4; i++) {
                CollaborationGroup colGroup = new CollaborationGroup(
                    Name = 'Test Chatter Group' + i,
                    CollaborationType = 'Public',
                    CanHaveGuests = false,
                    NetworkId = networkId);
                testGroups.add(colGroup);
            }
            
            insert testGroups;
            
            List <Topic> testTopics = new List <Topic>();
            for (Integer i = 0; i < 2; i++) {
                Topic testTopic = new Topic(Name = 'Test Topic ' + i, Description = 'Test Topic1 Description', NetworkId = networkId);
                testTopics.add(testTopic);
            }
    
            insert testTopics;
            
            User u1 = insertTestUser();

        }
		
	}
    
    private static User insertTestUser(){
        User testUser = [SELECT Id, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
        System.runAs(testUser) {
            
        }
        
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            system.debug('portalRole is ' + portalRole);
        
      		Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        	/*Account portalAccount1 = new Account(Name = 'Test Portal Account');
            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = portalAccount1.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1); */

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'x7sonboarding@controllertest.com',
                                   //UserRoleId = portalRole.Id,
                                    //ContactId = contact1.Id,
                                    ProfileId = profile1.Id,
                                    Alias = 'test123',
                                    Email = 'x7sonboarding@controllertest.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
           	Database.insert(user1);

        
        return user1;
    }

	@IsTest
	public static void testGetIsModalViewEnabled() {
		//setup();
		
		User testUser = [SELECT Id, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser) {
			Boolean isModalViewEnabled = x7sOnboardingController.getIsModalViewEnabled();
			System.assertNotEquals(null, isModalViewEnabled);
		}
	}

	@IsTest
	public static void testGetOnboardingComplete() {
		//setup();

		User testUser = [SELECT Id, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.X7S_Onboarding_Complete__c = true;
		update testUser;
		System.runAs(testUser) {
			User testUser1 = x7sOnboardingController.getUserRecord();
			System.assert(testUser1.X7S_Onboarding_Complete__c == true);
		}
	}

	@IsTest
	public static void testUpdateUserNames() {
		//setup();
		User testUser = [SELECT Id, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.FirstName = 'TestChange';
		System.runAs(testUser) {
			x7sOnboardingController.updateUserNames(testUser);
			User testUserName = [SELECT Id, FirstName FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
			System.assert(testUserName.FirstName == 'TestChange');
		}
	}

	@IsTest
	public static void testUpdatePreferences() {
		//setup();
		User testUser = [SELECT Id, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser) {
			x7sOnboardingController.updatePreferences(false);
			NetworkMember testUserName = [SELECT PreferencesDisableAllFeedsEmail FROM NetworkMember WHERE MemberId = :testUser.Id LIMIT 1];
			System.assert(testUserName.PreferencesDisableAllFeedsEmail == false);
		}
	}
	@IsTest
	static void testGroupMembership() {
		//setup();

        User u1 = [SELECT Id FROM User WHERE Email = 'x7sonboarding@controllertest.com' LIMIT 1 ];
		User testUser = [SELECT Id, X7S_Onboarding_Complete__c, Email FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_EMAIL LIMIT 1];
		System.debug('testUser: ' + testUser);

		List <CollaborationGroup> testGroups = [
			SELECT Id
			FROM CollaborationGroup
			WHERE Name = 'Test Chatter Group0'
			OR Name = 'Test Chatter Group1'
			OR Name = 'Test Chatter Group2'
			OR Name = 'Test Chatter Group3'
		];

		System.runAs(u1) {
			List <CollaborationGroupMember> memberList = [
				SELECT Id,NotificationFrequency
				FROM CollaborationGroupMember
				WHERE MemberId = :u1.Id
			];
            
            //join group
			x7sOnboardingController.joinGroup(testGroups[0].Id);
			System.assertEquals(1, 1);
			
			//leave group
			x7sOnboardingController.leaveGroup(testGroups[0].Id);
			System.assertEquals(1, 1);			
		}
        
        System.runAs(testUser) {
            //update Frequency
            List <CollaborationGroupMember> memberList1 = [
				SELECT Id,NotificationFrequency
				FROM CollaborationGroupMember
				WHERE MemberId = :testUser.Id
			];
            x7sOnboardingController.updateFrequenv(testGroups[0].Id, 'W');
			if (memberList1.size() > 0) {
				System.assertEquals('W', memberList1[0].NotificationFrequency);
			}
        }
	}

	@IsTest
	public static void testCompleteSlide() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser) {
			x7sOnboardingController.completeSlide('Welcome');
			x7sOnboardingController.completeSlide('Profile');
			x7sOnboardingController.completeSlide('Notification');
			x7sOnboardingController.completeSlide('Topic');
			x7sOnboardingController.completeSlide('Group');
			x7sOnboardingController.completeSlide('Tours');
			x7sOnboardingController.completeSlide('Done');

			User testUserName = [SELECT X7S_Completed_Tours_Slide__c, X7S_Onboarding_Complete__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
			System.assert(testUserName.X7S_Completed_Tours_Slide__c == true);
			System.assert(testUserName.X7S_Onboarding_Complete__c == true);
		}
	}


	@IsTest
	public static void testGetTopics() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		List <Id> topicIds = new List <Id>();
		for (Topic top : [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' OR Name = 'Test Topic 1']) {
			topicIds.add(top.Id);
		}
		Id networkId1 = [SELECT Id FROM Network LIMIT 1].Id;
		EntitySubscription subscription = new EntitySubscription(ParentId = topicIds[0], SubscriberId = testUser.Id, NetworkId = networkId1);
		insert subscription;

		System.runAs(testUser) {
			List <x7sOnboardingController.OnboardingWrapperForTopicOrCollabGroup> topicWrapper = x7sOnboardingController.getTopics(topicIds);
			System.assert(topicWrapper.size() == 2);
		}
	}

	@IsTest
	public static void testGetGroups() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
        User u1 = [SELECT Id FROM User WHERE Email = 'x7sonboarding@controllertest.com' LIMIT 1];
		List <Id> groupIds = new List <Id>();
		for (CollaborationGroup grp : [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group0' OR Name = 'Test Chatter Group1']) {
			groupIds.add(grp.Id);
		}

		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupIds[0], MemberId = u1.Id);
		insert member;
		System.runAs(u1) {
			List <x7sOnboardingController.OnboardingWrapperForTopicOrCollabGroup> groupWrapper = x7sOnboardingController.getGroups(groupIds);
			System.assert(groupWrapper.size() == 2);
		}
	}

	@IsTest
	public static void testGetGroup() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group1' LIMIT 1].Id;
        //User u1=insertTestUser();
        User u1 = [SELECT Id FROM User WHERE Email = 'x7sonboarding@controllertest.com' LIMIT 1];
        System.runAs(u1) {
        	CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupId, MemberId = u1.Id);
			insert member;    
        }        
        
		System.runAs(u1) {
            
			x7sOnboardingController.OnboardingWrapperForTopicOrCollabGroup groupWrapper = x7sOnboardingController.getGroup(groupId);
			System.assert(groupWrapper.id == groupId);
		}
	}
	@IsTest
	public static void testGrabTopics() {
		//setup();
		List<x7sOnboardingController.TopicSlide> topicSlides = x7sOnboardingController.grabTopics();
		System.assertNotEquals(null, topicSlides);
	}

	@IsTest
	public static void testFollowTopic() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		String topicId = [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' LIMIT 1].Id;

		System.runAs(testUser) {
			x7sOnboardingController.followTopic(topicId);
			List <EntitySubscription> userFollow = [SELECT Id FROM EntitySubscription WHERE ParentId = :topicId AND SubscriberId = :testUser.Id LIMIT 1];
			System.assert(userFollow.size() == 1);
		}
	}

	@IsTest
	public static void testRemoveGroupMember() {
		//setup();
		
        User u1= [Select Id From User Where Email ='x7sonboarding@controllertest.com'];
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
        CollaborationGroup testGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group3' LIMIT 1];
        System.runAs(u1) {
            CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = testGroup.Id, MemberId = u1.Id);
            insert member;
        }
		
		System.runAs(u1) {
			x7sOnboardingController.removeGroupMember(testGroup.Id);
			List <CollaborationGroupMember> userFollow = [SELECT Id FROM CollaborationGroupMember WHERE MemberId = :u1.Id];
			System.assert(userFollow.size() == 0);
		}
	}

	@IsTest
	public static void testUnFollowTopic() {
		//setup();
		User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		Id networkId1 = [SELECT Id FROM Network LIMIT 1].Id;
		String topicId = [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' LIMIT 1].Id;
		EntitySubscription topicFollow = new EntitySubscription(NetworkId = networkId1, ParentId = topicId, SubscriberId = testUser.Id);
		insert topicFollow;

		System.runAs(testUser) {
			x7sOnboardingController.unfollowTopic(topicId);
			List <EntitySubscription> userFollow = [SELECT Id FROM EntitySubscription WHERE ParentId = :topicId AND SubscriberId = :testUser.Id LIMIT 1];
			System.assert(userFollow.size() == 0);
		}
	}

/*
	TODO: Dynamic query builder for custom fields
	@IsTest
	public static void testGetUserSpecificGroups()
	{
		setup();
		User testUser = [SELECT Id,Region__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.Region__c = 'Northeast';
		update testUser;
		List <Id> groupIds = new List <Id>();
		for (CollaborationGroup grp : [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group0' OR Name = 'Test Chatter Group1'])
		{
			groupIds.add(grp.Id);
		}

		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupIds[0], MemberId = testUser.Id);
		insert member;

		System.runAs(testUser)
		{

			List <x7sOnboardingController.OnboardingWrapper> OnboardingWrapperList = x7sOnboardingController.getUserSpecificGroups();
			System.assert(OnboardingWrapperList.size() == 1);
		}
	}
 */

	// @IsTest
	// public static void testUploadUserPhoto() {
	// 	//setup();
	// 	User testUser = [SELECT Id FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
	// 	//update testUser;

	// 	ContentVersion contentVersionInsert = new ContentVersion(
	// 		Title = 'User Photo',
	// 		PathOnClient = x7sOnboardingTestConstants.TEST_FILENAME,
	// 		VersionData = EncodingUtil.base64Decode(x7sOnboardingTestConstants.BASE64FILE),
	// 		IsMajorVersion = true
	// 	);
	// 	insert contentVersionInsert;

	// 	ContentDocument documents = [SELECT Id, Title,FileType, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

	// 	System.debug(' --- Document (Image):  ' + documents);

	// 	System.runAs(testUser) {
	// 		x7sOnboardingController.uploadUserPhoto(documents.Id, x7sOnboardingTestConstants.TEST_FILENAME);
	// 		//System.assertNotEquals(null, uploadUserPhoto);
	// 	}
	// }

	@IsTest
	public static void testGetTrackingOptions() {
		x7sOnboardingController.ActivityTracking myTracking = x7sOnboardingController.TrackActivities;
		System.assertNotEquals(null, myTracking);
		x7sOnboardingController.DumpTracking();
	}

	@IsTest
	public static void testActivityEntry() {
		x7sOnboardingController.activityEntry entry = new x7sOnboardingController.activityEntry('ID1', 'Name');
		System.assertNotEquals(null, entry);
	}

	@IsTest
	public static void testGetCommunityTermsAndConditions() {
		String defaultTermsAndConditions = 'Default Terms and Conditions (Used in Test Class)';
		String retrievedTermsAndConditions = x7sOnboardingController.getCommunityTermsAndConditions();
		System.assertNotEquals(null, retrievedTermsAndConditions);
		System.assertEquals(defaultTermsAndConditions, retrievedTermsAndConditions, 'Retrieved Terms and Conditions should match Terms and Conditions Set in the Default 7S Onboarding Settings');
	}

	@IsTest
	public static void testSetAgreedTermsAndConditions() {
		//setup();

		User testUser = [SELECT Id, X7S_Agreed_to_Terms_and_Conditions__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		System.assertEquals(false, testUser.X7S_Agreed_to_Terms_and_Conditions__c, 'Test User shouldn\'t have agreed to terms and conditions yet');
		System.runAs(testUser) {
			x7sOnboardingController.setAgreedTermsAndConditions(true);
		}
		testUser = [SELECT Id, X7S_Agreed_to_Terms_and_Conditions__c FROM User WHERE Email = :x7sOnboardingTestConstants.STANDARD_USERNAME LIMIT 1];
		System.assertEquals(true, testUser.X7S_Agreed_to_Terms_and_Conditions__c, 'Test User should have agreed to terms and conditions');
	}

	@IsTest
	public static void testGetDisplayLimit() {
		X7S_Onboarding_Setting__mdt setting = x7sOnboardingController.getDisplayLimit();
		System.assertEquals(null, setting);
	}

	@IsTest
	public static void testGetEmailPreference() {
		NetworkMember memberPreference = x7sOnboardingController.getMemberEmailPreference();
		System.assertEquals(null, memberPreference);
	}
}