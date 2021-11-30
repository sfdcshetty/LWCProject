import { LightningElement,api} from 'lwc';
import getKnowledgeBaseArticles from '@salesforce/apex/x7sKnowledgeBaseArticlesController.getKnowledgeBaseArticlesDetails';
import getTotalArticleCount from '@salesforce/apex/x7sKnowledgeBaseArticlesController.getArticleCount';


export default class X7sWegKnowledgeBaseArticles extends LightningElement() {

    articleList;
    pageNumber;
    totalPages;
    totalArticles;
    searchString;
    urlName;
    recordId;
    @api numberOfArticlesPerPage;
    @api componentTitle = 'Support';
    @api supportArticleLabel = 'Support Articles';
    @api searchPlaceHolder ='Search our Library';




    connectedCallback(){
        this.getKnowledgeBaseArticles();
        this.getTotalArticleCount();
    }

    getKnowledgeBaseArticles(){
        getKnowledgeBaseArticles(this.getParams())
        .then(data => {
            this.record = data;
            this.articleList = this.record.map(row => ({
                ...row,
                UrlPath: '../s/article/'+row.UrlName
            }));
            console.log('articleList: '+JSON.stringify(this.articleList));
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