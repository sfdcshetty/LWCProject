import HEADER from '@salesforce/label/c.x7sUnifiQuestionnaire_InvestmentTimeHorizon_Header';

import QUESTIONNAIRE_OBJECT from '@salesforce/schema/Financial_Profile__c';
//import HORIZON_FIELD from '@salesforce/schema/WEG_Unifi_Questionnaire__c.Investment_Time_Horizon__c';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import { api,wire,LightningElement } from 'lwc';

export default class X7sUnifiQuestionnaireInvestmentTimeHorizon extends LightningElement {
    @api debug = false;
    @api investmentTimeHorizon;

    header = HEADER;
    optionsInvestmentTimeHorizon = [];

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
        if (data) this.optionsLifeEvents = data.values;
    }


    dispatchData() {
        const obj = {};
        this.dispatchEvent(new CustomEvent('savetempdata', {
            detail: {
                personalInfo: obj
            }
        }));
    }

    handleChangeInvestmentTimeHorizon(event) {
        this.investmentTimeHorizon = event.detail.value;
        this.dispatchData();
    }
}