import HEADER from '@salesforce/label/c.x7sFinancialProfile_FederalTaxBracket_Header';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import QUESTIONNAIRE_OBJECT from '@salesforce/schema/Financial_Profile__c';
import FILING_FIELD from '@salesforce/schema/Financial_Profile__c.Filing_Status__c';

import { wire,api,LightningElement } from 'lwc';

export default class X7sFinancialProfileFederalTaxBracket extends LightningElement {
    @api debug = false;
    header = HEADER;

    @api filingStatus='';
    optionsFilingStatus = [];

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: QUESTIONNAIRE_OBJECT })
    objectInfo;
    // get picklist values using objectInfo
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FILING_FIELD,
    })
    wiredGetPicklistValues({ data, error }) {
        if (data) this.optionsFilingStatus = data.values;
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        const obj = {
            Filing_Status__c: this.filingStatus,
        };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeFilingStatus(event) {
        this.filingStatus = event.detail.value;
        this.dispatchData();
    }
}