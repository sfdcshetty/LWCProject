/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sAnnouncementsSettings {
	private static final String X7S_SETTINGS_NAME = 'Default';

	public static String AnnouncementEmailTemplate {
		get {
			if (AnnouncementEmailTemplate == null) {
				try {
					X7S_Announcements_Setting__mdt setting = [SELECT Announcement_Email_template__c FROM X7S_Announcements_Setting__mdt WHERE DeveloperName = :X7S_SETTINGS_NAME LIMIT 1];
					AnnouncementEmailTemplate = setting.Announcement_Email_template__c;
				}
				catch (Exception ex) { AnnouncementEmailTemplate = x7sAnnouncementsTestConstants.DEFAULT_EMAIL_TEMPLATE; }
			}

			return AnnouncementEmailTemplate;
		}

		set {
			AnnouncementEmailTemplate = value;
		}
	}

	public static String AnnouncementProfile {
		get {
			if (AnnouncementProfile == null) {
				try {
					X7S_Announcements_Setting__mdt setting = [SELECT Announcement_Email_Profile__c FROM X7S_Announcements_Setting__mdt WHERE DeveloperName = :X7S_SETTINGS_NAME LIMIT 1];
					AnnouncementProfile = setting.Announcement_Email_Profile__c;
				}
				catch (Exception ex) { AnnouncementProfile = x7sAnnouncementsTestConstants.COMMUNITY_PROFILE; }
			}

			return AnnouncementProfile;
		}

		set {
			AnnouncementProfile = value;
		}
	}
}