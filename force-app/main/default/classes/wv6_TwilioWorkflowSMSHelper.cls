/*
 * Author: Wave6
 * Project: Community 2FA
 * Description: Twilio REST API helper to send SMS.
 *  
 */

public with sharing class wv6_TwilioWorkflowSMSHelper {
    
    //input details that comes to apex from flow
    public class SMSDetails {
    
        @InvocableVariable(label='To Mobile Number' description='Receipient mobile number' required=true)
        public string toNumber;
        
        @InvocableVariable(label='Message' description='Message body' required=true)
        public string message;
        
    }
    
    @InvocableMethod(label='Send SMS' description='Send SMS using Twilio REST API')
    public static void sendSMSViaTwilio(List<SMSDetails> smsRequests) {
        
        // if input was provided, send the sms in a future method
        if (!smsRequests.isEmpty()) {
            SMSDetails sms = smsRequests.get(0);
            sendSms(sms.toNumber, sms.message);
        }
    }
    
    @future(callout=true)
    private static void sendSms(string toNumber, string message) {
        // get Twilio configurations used for API
        List<Twilio_Configuration__mdt> twilioConfigsList =
            [SELECT API_Endpoint__c, API_Version__c, AccountSid__c, AuthToken__c, Twilio_Number__c,
             ApplicationSid__c FROM Twilio_Configuration__mdt LIMIT 1];
        
        // as long as we got configurations
        if (!twilioConfigsList.isEmpty()) {
            // grab the first
            Twilio_Configuration__mdt twilioConfig = twilioConfigsList.get(0);
            
            // create the request
            HttpRequest req = requestBuilder(twilioConfig);
            
            // set the body of the request
            req.setBody(bodyBuilder(toNumber, message, twilioConfig));
            
            system.debug(req);
            
            // send the request
            http h = new http();
            HttpResponse res = h.send(req);
        }
    }
    
    private static HttpRequest requestBuilder (Twilio_Configuration__mdt tc) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlBuilder(tc));
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(tc.AccountSid__c + ':' + tc.AuthToken__c)));
        req.setMethod('POST');
        return req;
    }

    private static string bodyBuilder(string toNumber, string message, Twilio_Configuration__mdt tc) {
        
        string output = 'To=' + toNumber + '&Body=' + message + '&From=' + '1' + tc.Twilio_Number__c;
        return output;
    }
    
    private static string urlBuilder(Twilio_Configuration__mdt tc) {

        return tc.API_Endpoint__c + '/' + tc.API_Version__c + '/' + 'Accounts' + '/' + tc.AccountSid__c + '/' + 'SMS/Messages.json';
    }
}