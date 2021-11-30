import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class X7sWegFooterLink extends NavigationMixin(LightningElement) {
    @api linktext;
    @api target;
    @api arialabel;
    @api linkclass;
    @api url;
    href;

    connectedCallback() {
        this.getUrl(this.url);
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