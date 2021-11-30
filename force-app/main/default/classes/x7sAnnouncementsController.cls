/*
 * Copyright (c) 2020. 7Summits Inc.
 */

// ===================
// X7S Announcements Controller
// ===================
public with sharing class x7sAnnouncementsController {

	// Get the current community's name
	@AuraEnabled
	public static String getCommunityName() {
		String communityName;

		try {
			// Get the Community ID and associated name
			Id networkId = System.Network.getNetworkId();
			List<Network> communityResults = [SELECT Name FROM Network WHERE Id = :networkId WITH SECURITY_ENFORCED];
			if (communityResults != null && !communityResults.isEmpty() && communityResults[0] != null) {
				communityName = communityResults[0].Name;
			}
		}
		catch (Exception e) {
			System.debug('getCommunityName() : ' + e.getMessage() + ' line number: ' + e.getLineNumber());
		}

		return communityName;
	}

	// Get the Network ID
	@AuraEnabled
	public static String getNetworkId() {
		String networkId = System.Network.getNetworkId();
		return String.isNotBlank(networkId) ? networkId : '';
	}

	// Get the logged in user's ID
	@AuraEnabled
	public static String getUserId() {
		return UserInfo.getUserId();
	}

	// Get the announcements
	@AuraEnabled
	public static x7sAnnouncementsResponse getActiveAnnouncements(String numResultsString, String displayChannelString, String displayTypeString, String hiddenAnnouncementString) {
		x7sAnnouncementsResponse response = new x7sAnnouncementsResponse();

		try {
			// Get the selected query limit
			Integer queryLimit = Integer.valueOf(numResultsString);
			// If the user entered 0 or less, we want to set this to "unlimited" results.
			if (queryLimit <= 0) { queryLimit = 10000; }

			// Get the selected channel to display
			String displayChannel = displayChannelString;

			// Get the selected type of announcement to display
			String displayType;
			// If the announcement is set to all, we want to grab everything, otherwise filter.
			if (displayTypeString == 'All') {
				displayType = '%';
			}
			else { displayType = displayTypeString; }

			// Get the announcements to hide, based on user's cookies
			List<String> hiddenAnnouncements = new List<String>();
			if (hiddenAnnouncementString == null) { hiddenAnnouncements.add('');
			} else {
				hiddenAnnouncements = hiddenAnnouncementString.split(',');
			}

			// Get the Community Name
			String communityName = getCommunityName();

			// Perform the query
			List<X7S_Announcement__c> activeAnnouncements = [
				SELECT Announcement_Body__c, Announcement_Call_to_Action__c, Announcement_Type__c, Announce_to_Community__c, Announcement_Channel__c, Announcement_Dismissible__c, Announcement_URL__c, CreatedById, End_Date_Time__c, Id, Name, Owner.Name, Start_Date_Time__c
				FROM X7S_Announcement__c
				WHERE (Start_Date_Time__c < :Datetime.now() AND (End_Date_Time__c = null OR End_Date_Time__c > :Datetime.now()))
				AND Announce_to_Community__c INCLUDES ('All', :communityName)
				AND Announcement_Channel__c INCLUDES ('All', :displayChannel)
				AND Announcement_Type__c LIKE :displayType
				AND Id NOT IN :hiddenAnnouncements
				WITH SECURITY_ENFORCED
				ORDER BY Order__c, Start_Date_Time__c DESC
				LIMIT :queryLimit
			];

			response.results = activeAnnouncements;

		}
		catch (Exception e) { response.success = false; response.messages.add(e.getMessage());
			System.debug('getActiveAnnouncements() : ' + e.getMessage() + ' line number : ' + e.getLineNumber());

		}

		return response;
	}

	// Get the site prefix (for displaying links/assets)
	@AuraEnabled
	public static String getSitePrefix() {
		return x7sAnnouncementsUtils.getSitePrefix();
	}
}