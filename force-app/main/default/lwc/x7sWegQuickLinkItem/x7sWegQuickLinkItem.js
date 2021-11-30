import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class X7sQuickLinkItem extends NavigationMixin(LightningElement) {
    @api recordid;
    @api title;
    @api url;
    @api intorext;
    myHref;

    connectedCallback(){
        this.generateUrl();
    }

    generateUrl(){
        let nameIndex = this.url.indexOf('User_Profile');
        if(this.intorext){
            console.log('navigateToWebPage');
            this.navigateToWebPage(this.url);
        }else if(nameIndex >-1){
            console.log('navigateToViewAccountPage');
            this.navigateToViewAccountPage();
        }else{
            console.log('navigateToInternalWebPage');
            this.navigateToInternalWebPage(this.url);
        }
    }
    // Navigate to View Account Page
    navigateToViewAccountPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordid,
                objectApiName: 'User_Profile',
                actionName: 'view'
            },
        }).then(result => {
            this.myHref = result;
        });
    }

    navigateToInternalWebPage(page) {
        console.log('QuickLINKPage='+page)
        this[NavigationMixin.GenerateUrl]({
          type: "comm__namedPage",
              attributes: {
            name: page
          }
        }).then(result => {
            this.myHref = result;
        });
    }
        
    navigateToWebPage(url) {
        console.log('QuickLINKURL='+url)
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        }).then(result => {
            this.myHref = result;
        });
    }
}