import { LightningElement } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class X7sWegPrivacyPolicy extends NavigationMixin(LightningElement) {
    goToPrivacy1(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://f.hubspotusercontent00.net/hubfs/244952/WEAS%20Privacy%20Policy%2003-2016.pdf'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }

    goToPrivacy2(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://f.hubspotusercontent00.net/hubfs/244952/Privacy%20Policy-1.pdf'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}