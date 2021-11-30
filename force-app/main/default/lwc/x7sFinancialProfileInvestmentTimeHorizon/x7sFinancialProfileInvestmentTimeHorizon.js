import HEADER from '@salesforce/label/c.x7sFinancialProfile_InvestmentTimeHorizon_Header';

import QUESTIONNAIRE_OBJECT from '@salesforce/schema/Financial_Profile__c';
import HORIZON_FIELD from '@salesforce/schema/Financial_Profile__c.General_Investment_Time_Horizon__c';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import { api,wire,LightningElement } from 'lwc';

export default class X7sFinancialProfileInvestmentTimeHorizon extends LightningElement {
    @api debug = false;
    @api investmentTimeHorizon;

    optionsInvestmentTimeHorizon = [];
    header = HEADER;

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: QUESTIONNAIRE_OBJECT })
    objectInfo;
    // get picklist values using objectInfo
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: HORIZON_FIELD,
    })
    wiredGetPicklistValues({ data, error }) {
        if (error) console.error(error);
        if (data) this.optionsInvestmentTimeHorizon = data.values;
    }

    connectedCallback() { }


    dispatchData() {
        const obj = { General_Investment_Time_Horizon__c: this.investmentTimeHorizon };
        this.dispatchEvent(new CustomEvent('savetempdata', {
            detail: { personalInfo: obj }
        }));
    }

    handleChangeInvestmentTimeHorizon(event) {
        this.investmentTimeHorizon = event.detail.value;
        this.dispatchData();
    }
}