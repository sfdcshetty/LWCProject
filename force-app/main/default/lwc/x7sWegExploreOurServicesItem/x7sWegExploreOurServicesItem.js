import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class X7sWegExploreOurServicesItem extends NavigationMixin(LightningElement) {
    @api title;
    @api url;
    @api external;
    href;

    connectedCallback(){
        
    }

    navigate(){
        if(this.external === true){
            this.navigateToExternal();
        }else{
            this.navigateToInternal();
        }
    }

    navigateToExternal(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.url
            }
        }).then(result => {
            this.href = result;
            window.open(this.href, '_blank');
        });
    }

    navigateToInternal(){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
                attributes: {
              name: this.url
            }
          });
    }
}