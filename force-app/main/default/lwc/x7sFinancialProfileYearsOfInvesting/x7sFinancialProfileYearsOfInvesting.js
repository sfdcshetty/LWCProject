import HEADER from '@salesforce/label/c.x7sFinancialProfile_YearsOfInvesting_Header';

import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileYearsOfInvesting extends LightningElement {
    @api debug = false;

    _yearsOfInvesting;
    @api set yearsOfInvesting(val) { this._yearsOfInvesting = parseInt(val,10) || null; }
    get yearsOfInvesting() { return this._yearsOfInvesting; }

    @api secondaryName;

    get header() {
        let str = HEADER;
        return (this.secondaryName) ? str.replace(/\byou have\b/,`you and ${this.secondaryName} have combined`) : str;
    }

    dispatchData() {
        const obj = { Combined_Years_of_Investing__c: this.yearsOfInvesting };
        this.dispatchEvent(new CustomEvent('savetempdata', {
            detail: { personalInfo: obj }
        }));
    }

    handleChangeYearsOfInvesting(event) {
        this.yearsOfInvesting = event.detail.value;
        this.dispatchData();
    }
}