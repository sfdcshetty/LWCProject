import { LightningElement,wire,api,track} from 'lwc';
import getKnowledgeBaseArticles from '@salesforce/apex/x7sKnowledgeBaseArticlesController.getKnowledgeBaseArticlesDetails';
import getTotalArticleCount from '@salesforce/apex/x7sKnowledgeBaseArticlesController.getArticleCount';

export default class x7sKnowledgeBaseArticlesList extends LightningElement {

    articleList;
    pageNumber;
    totalPages;
    totalArticles;
    searchString;
    recordId = '';
    articleDetail;
    @api numberOfArticlesPerPage;
    @api componentTitle = 'Support';
    @api supportArticleLabel = 'Support Articles';
    @api searchPlaceHolder ='Search our Library!';

    connectedCallback(){
        this.getKnowledgeBaseArticles();
        this.getTotalArticleCount();
        console.log('recordid='+this.recordId);
        this.getCurrentRecordId();
    }

    getKnowledgeBaseArticles(){
        getKnowledgeBaseArticles(this.getParams())
        .then(data => {
            this.articleList = data;
         })
        .catch(error => {
            console.error('Error in get Knowledge Base Articles Record:', error);
        })
    }

    getTotalArticleCount(){
        getTotalArticleCount()
            .then(result => { 
                this.totalArticles = result;
                this.totalPages = Math.ceil(this.totalArticles / this.numberOfArticlesPerPage);
			})
			.catch(error => {
				this.error = error;
		});
    }

    get previous() {
        return (this.pageNumber === 1)? true: false;
    }
  
    get next() {
        return (this.totalPages  === this.pageNumber)? true: false;
    }

    previousHandler(){
        this.pageNumber = (this.pageNumber != null)? ((this.pageNumber != 1)? (this.pageNumber - 1) : this.pageNumber):1; 
        this.getKnowledgeBaseArticles();
    }

    nextHandler(){
        this.pageNumber = (this.pageNumber != null)? ((this.pageNumber != this.totalPages)? (this.pageNumber + 1) : this.pageNumber):1;   
        this.getKnowledgeBaseArticles();    
    }

    handleSearchString(event){
        this.searchString = event.target.value;
        this.pageNumber = 1;
        this.getKnowledgeBaseArticles();
    }
    
    handleArticleClick(event){
        this.recordId = event.currentTarget.dataset.id;
        this.articleList.forEach(art=>{
            if(art.Id == this.recordId){
                this.articleDetail = {
                    Question: art.Question__c,
                    Answer: art.Answer__c,
                    LastPublishedDate: art.LastPublishedDate 
                };
            }
        })

    }

    getCurrentRecordId(){
        //this.recordId = event.currentTarget.dataset.id;
        console.log('RECORD ID='+this.recordId);
    }
    
    handleSupportClick(){
        this.recordId = '';
    }
    
    getParams() {
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