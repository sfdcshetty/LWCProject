@RestResource(urlMapping='/quikChatterPost/*')
global class Quik_ChatterPost {
    @HttpPost
    global static void chatterPost() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = request.RequestBody.tostring();
        
        Map<String, Object> requestJSON = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Quik_SendChatterNotification.sendChatterFeed(String.valueOf(requestJSON.get('parentId')), 
                                                     String.valueOf(requestJSON.get('userOrGroupId')), 
                                                     String.valueOf(requestJSON.get('envelopeId')), 
                                                     String.valueOf(requestJSON.get('relatedAccount')), 
                                                     String.valueOf(requestJSON.get('asFasId')));
    }
}