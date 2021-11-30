/******************************************************************************************************************************
* @class name    : Wave6_CustomChatterPost
* @description   : This Class contains invokable method for creating Chatter Feed Items. Invokable method will be called from process created in process builder.
* 
* @test class    : Wave6_CustomChatterPostTest
* @author        : Ganesh Ekhande
* @date          : 05/11/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/11/2017             Created.
*
******************************************************************************************************************************/
global with sharing class Wave6_CustomChatterPost {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method which is used to create chatter feed item using procided information.
    * @created      : 05/11/2017
    * @param        : list<CustomChatterPost.ChatterPostInputs> inputs 
    * @return       : void
    */
    @InvocableMethod(label='Create Chatter Post')
    global static void ChatterFeedItemAction(List<Wave6_CustomChatterPost.ChatterPostInputs> inputs ){
        if(!inputs.isEmpty()){
            List<FeedItem> feedItems = new List<FeedItem>();
            for (Wave6_CustomChatterPost.ChatterPostInputs input : inputs) {
                if (input.parentId != null) {
                	feedItems.add(ChatterFeedItemAction(input.parentId,input.userId,input.chatterBody, input.url, input.urlLabel));
                }
             }
            insert feedItems;
        }
    }
    
    
     /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to create chatter feed item using provided information.
    * @created      : 05/11/2017
    * @param        : Id parentId,Id userId, string chatterBody
    * @return       : FeedItem
    */
    global static FeedItem ChatterFeedItemAction( Id parentId,Id userId, string chatterBody, String url, String urlTitle ){  
        FeedItem post = new FeedItem();  
        post.ParentId = parentId;  
        //post.createdById = userId;  
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
    
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : Inner wrapper class which wraps different inputs required for creating chatter feed item.
    * @created      : 05/11/2017
    */
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