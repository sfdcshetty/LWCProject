/**
 * Created by 7Summits on 5/21/21.
 */

global without sharing class x7s_ChatterPostUtility {

    @InvocableMethod(label='X7S Create Chatter Post')
    global static void ChatterFeedItemAction(List<ChatterPostInputs> inputs ){
        System.debug('x7s_ChatterPostUtility.ChatterFeedItemAction: Enter');

        if(!inputs.isEmpty()){
            System.debug('x7s_ChatterPostUtility.ChatterFeedItemAction: NOT EMPTY');
            List<FeedItem> feedItems = new List<FeedItem>();
            for (ChatterPostInputs input : inputs) {
                if (input.parentId != null) {
                    feedItems.add(ChatterFeedItemAction(input.parentId,input.userId,input.chatterBody, input.url, input.urlLabel));
                }
            }
            try {
                insert feedItems;
            } catch(Exception ex){
                //System.debug('x7s_ChatterPostUtility.ChatterFeedItemAction: Error - ' + ex.getMessage() + ' - ' + ex.getLineNumber());
                //System.debug('x7s_ChatterPostUtility.ChatterFeedItemAction: Error - ' + ex.getMessage() + ' - ' + ex.getLineNumber() + ' - parent id:' + input.parentId + '| user id: ' +  input.userId + ' | chatter body:  ' + input.chatterBody + ' | url: ' + input.url + ' | url label: ' + input.urlLabel);
            }

        }
    }


    global static FeedItem ChatterFeedItemAction( Id parentId,Id userId, string chatterBody, String url, String urlTitle ){
        FeedItem post = new FeedItem();
        post.ParentId = parentId;
        post.createdById = userId;
        post.Body = chatterBody;
        if (url != null) {
            post.Type = 'LinkPost';
            post.LinkUrl = url;
            post.Title = urlTitle;
        } else {
            post.Type = 'TextPost';
        }

        return post;

    }


    global class ChatterPostInputs {

        @InvocableVariable(label='Parent Id' description='Required. The Id of the Parent record.' required=true)
        global Id parentId;

        @InvocableVariable(label='User Id' description='Required. The Id of user who will be owner of the chatter post' required=true)
        global Id userId;

        @InvocableVariable(label='Chatter Body' description='Required. The Chatter message' required=true)
        global String chatterBody;

        @InvocableVariable(label='URL' description='Optional. A clickable link to the record' required=false)
        global String url;

        @InvocableVariable(label='URL Label' description='Optional. A label for the clickable link' required=false)
        global String urlLabel;

        // Empty constructor
        global ChatterPostInputs() {}
    }
}