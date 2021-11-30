/*
 * Author: Wave6
 * Project: Community 2FA
 * Description: Unit test class for wv6_TwilioWorkflowSMSHelper
 *  
 */

@isTest
private class wv6_TwilioWorkflowSMSHelperTest {
	
	@isTest static void sendSMSViaTwilio_test() {

		Test.setMock(HttpCalloutMock.class, new wv6_TwilioHttpMockResponseGenerator());
		Test.startTest();
        
		wv6_TwilioWorkflowSMSHelper.SMSDetails sms = new wv6_TwilioWorkflowSMSHelper.SMSDetails();
        sms.toNumber = '43565467567';
        sms.message = 'Test Message';
        
        wv6_TwilioWorkflowSMSHelper.sendSMSViaTwilio(new List<wv6_TwilioWorkflowSMSHelper.SMSDetails> {sms});
		Test.stopTest();
	}

}