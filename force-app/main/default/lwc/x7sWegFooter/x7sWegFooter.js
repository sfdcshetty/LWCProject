import { LightningElement, api } from 'lwc';
//import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";
import {NavigationMixin} from 'lightning/navigation';


export default class X7s_WEG_footer extends NavigationMixin(LightningElement) {
    @api copyText;
    @api contactText;
    @api contactLabel;
    @api contactUrl;
    @api advisorText;
    @api advisorLabel;
    @api advisorUrl;
    @api supportText;
    @api supportLabel;
    @api supportUrl;
    @api termsUseUrl;
    @api privacyText;
    @api privacyUrl;
    @api termsText;
    @api footerDisclosureText1;
    @api disclosureLabel;
    @api disclosureLink1;
    @api disclosureLink2;
    @api disclosureLink3;
    @api footerDisclosureText2;
    @api copyLabel;

    termsUrl;

    //wegLogo = WEG_LOGO_PATH + '/WEG_Assets/logos/WEG_footer.png';
    

    termsHref() {
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
              attributes: {
            name: "Terms_and_Conditions__c"
          }
        });
    }

    privacyHref() {
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
              attributes: {
            name: "Privacy_Policy__c"
          }
        });
    }

    goToFinra(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'http://www.finra.org'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }

    goToWeas(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://f.hubspotusercontent00.net/hubfs/244952/February%202021%20WEAS%20ADV%20Part%202A.pdf'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }

    goToWeas2(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://cdn2.hubspot.net/hubfs/244952/202003%20WEAS%20Supplement%20to%20ADV%20Part%202A%20-%20Final.pdf'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }

    goToWeas3(){
      // Navigate to a URL
      this[NavigationMixin.Navigate]({
          type: 'standard__webPage',
          attributes: {
              url: 'https://f.hubspotusercontent00.net/hubfs/244952/WEAS_ADV/WEAS%20-%20JANUARY%202021%20WEAS%20ADV%20Part%202A%20Appendix%201%20Final.pdf'
          }
      },
      true // Replaces the current page in your browser history with the URL
    );
  }

    goToSipc(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'http://www.sipc.org'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}