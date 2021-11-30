import PRIMARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_MoreAboutTrust_Header';
import SECONDARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_CoClientMoreAboutTrust_Header';
import { api,LightningElement } from 'lwc';
import { fireEvent } from 'c/pubsub';

export default class X7sFinancialProfileMoreAboutTrust extends LightningElement {
    @api debug = false;
    @api trustName = '';
    @api trustValue = 0;
    @api trustType = '';
    @api coClientName = '';

    _hasTrust = true;
    @api set hasTrust(val) { 
        if (val!==undefined) this._hasTrust = val; 
        if (!this._hasTrust) fireEvent('goSkip','skipping more about trust');
    }
    get hasTrust() { return this._hasTrust; }

    get header() { 
        const header = (this.coClientName) ? SECONDARY_HEADER : PRIMARY_HEADER; 
        const trustType = this.trustType || ''; // might be undefined
        return this.strReplace(header,['coClientName',this.coClientName],['trustType',trustType.toLocaleLowerCase()]);
    }

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
            obj.Primary_Trust_Name__c = this.trustName;
            obj.Primary_Trust_Value__c = this.trustValue;
        } else {
            obj.Secondary_Trust_Name__c = this.trustName;
            obj.Secondary_Trust_Value__c = this.trustValue;
        }
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeTrustName(event) {
        this.trustName = event.detail.value;
        this.dispatchData();
    }
    handleChangeTrustValue(event) {
        this.trustValue = parseInt(event.detail.value,10);
        this.dispatchData();
    }
}