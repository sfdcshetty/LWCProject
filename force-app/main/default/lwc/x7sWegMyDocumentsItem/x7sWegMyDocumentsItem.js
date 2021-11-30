import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class X7sWegMyDocumentsItem extends NavigationMixin(LightningElement) {
    @api title;
    @api url
    href;

    connectedCallback() {
        this.getUrl(this.url);
        console.log('myurl', this.url);
    }

    getUrl(page) {
        this[NavigationMixin.GenerateUrl]({
          type: "comm__namedPage",
              attributes: {
            name: page
          }
        }).then(result => {
            this.href = result;
        });
    }
}