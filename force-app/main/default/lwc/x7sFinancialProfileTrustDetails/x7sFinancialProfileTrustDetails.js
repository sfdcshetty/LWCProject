import HEADER from '@salesforce/label/c.x7sFinancialProfile_MoreAboutTrust_Header';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileMoreAboutTrust extends LightningElement {
    @api debug = false;
    @api typeOfTrust = '';
    @api coClientName = '';
    @api optionsTypeOfTrust = [];

    get header() { return HEADER; }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = {};
        if (this.coClientName) {
            obj.Primary_Trust_Type__c = this.typeOfTrust;
        } else {
            obj.Secondary_Trust_Type__c = this.typeOfTrust;
        }
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeTypeOfTrust(event) {
        this.typeOfTrust = event.detail.value;
        this.dispatchData();
    }
}