import PRIMARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_TypeOfTrust_Header';
import SECONDARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_CoClientTypeOfTrust_Header';
import { api,LightningElement } from 'lwc';
import { fireEvent } from 'c/pubsub';

export default class X7sFinancialProfileTypeOfTrust extends LightningElement {
    @api debug = false;
    @api trustType = '';
    @api coClientName = '';
    @api optionsTrustType = [];

    _hasTrust = true;
    @api set hasTrust(val) { 
        if (val!==undefined) this._hasTrust = val; 
        if (!this._hasTrust) fireEvent('goSkip','skipping type of trust');
    }
    get hasTrust() { return this._hasTrust; }

    get header() { return (this.coClientName) ? this.strReplace(SECONDARY_HEADER,['coClientName',this.coClientName]) : PRIMARY_HEADER; }

    strReplace(stringToFormat, ...args) {
        const replacements = Object.fromEntries(args);
        if (typeof stringToFormat !== "string") throw new Error("'stringToFormat' must be a String");
        return stringToFormat.replace(/{(\w+)}/gm, (match, paren)=>{ return replacements[paren] || '' });
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = {};
        if (!this.coClientName) {
            obj.Primary_Trust_Type__c = this.trustType;
        } else {
            obj.Secondary_Trust_Type__c = this.trustType;
        }
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeTrustType(event) {
        this.trustType = event.detail.value;
        this.dispatchData();
    }
}