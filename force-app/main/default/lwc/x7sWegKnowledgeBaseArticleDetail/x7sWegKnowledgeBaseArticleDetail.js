import { LightningElement,wire} from 'lwc';
import getKnowledgeBaseArticles from '@salesforce/apex/x7sKnowledgeBaseArticlesController.getKnowledgeBaseArticlesDetails';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class X7sWegKnowledgeBaseArticles extends NavigationMixin(LightningElement) {
    debug = true;

    articleList;
    articleDetail;
    urlName;
    recordId;

    // set default params
    searchString = '';
    pageNumber = 0;
    numberOfArticlesPerPage = 5;

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        this.urlName = pageRef.attributes.urlName;
        this.getKnowledgeBaseArticles();
    }

    getKnowledgeBaseArticles(){
        if (this.debug) console.log('fetching article:',this.params)
        getKnowledgeBaseArticles(this.params)
        .then(data => {
            if (this.debug) console.log('fetched articles:',data);
            if (data && data.length) {
                this.articleDetail = data.find(i=>i.UrlName === this.urlName);
                if (this.articleDetail) {
                    if (this.debug) console.log('this.articleDetail:',this.articleDetail);
                    this.recordId = this.articleDetail.Id;
                } else { 
                    // fetch the next batch of articles
                    this.pageNumber = 1+this.pageNumber;
                    if (this.debug) console.log('this.pageNumber:',this.pageNumber);
                    this.getKnowledgeBaseArticles();
                }
            }
            /*this.articleList = data;
            this.articleList.forEach(art=>{
                if(art.UrlName == this.urlName){
                    this.recordId = art.Id;
                    this.articleDetail = {
                        Question: art.Question__c,
                        Answer: art.Answer__c,
                        LastPublishedDate: art.LastPublishedDate 
                    };
                }
            })*/
        })
        .catch(error => {
            console.error('Error in get Knowledge Base Articles Record:', error);
        });
    }

    handleSupportClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/clientportal/s/support'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
    
    get params() {
        this.pageNumber = (this.pageNumber != null)? this.pageNumber : 1;
        this.numberOfArticlesPerPage = (this.numberOfArticlesPerPage != null)?this.numberOfArticlesPerPage : 10;
        let params = {
            searchTerm: this.searchString,
            numberOfArticlesPerPage: this.numberOfArticlesPerPage,
            pageNumber: this.pageNumber,
        };
        return params;
    }
}