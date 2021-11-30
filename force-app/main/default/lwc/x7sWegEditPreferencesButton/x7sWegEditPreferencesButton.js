import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";

import Id from '@salesforce/user/Id';

export default class X7sWegEditPreferencesButton extends NavigationMixin(LightningElement) {
  userId = Id;
    chevron = WEG_LOGO_PATH + '/WEG_Assets/icons/chevronright.png';

    goToPreferences(){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
              attributes: {
                pageName: "profile",
                recordId: this.userId
              }
          });
    } 
}