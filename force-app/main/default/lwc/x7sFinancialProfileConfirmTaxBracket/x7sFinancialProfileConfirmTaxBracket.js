import HEADER from '@salesforce/label/c.x7sFinancialProfile_ConfirmTaxBracket_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_ConfirmTaxBracket_Paragraph';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import QUESTIONNAIRE_OBJECT from '@salesforce/schema/Financial_Profile__c';

import { wire,api,track,LightningElement } from 'lwc';

export default class X7sFinancialProfileConfirmTaxBracket extends LightningElement {
    @api debug = false;
    header = HEADER;
    regexUrl = /(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))/;
    paragraphs = PARAGRAPH.replace(this.regexUrl,'<a href="$1" target="_blank">$1</a>').split(/[\r\n]+/);

    @api incomeCombined = 0;
    @api filingStatus = '';
    @api taxBracketRate = 0;
    @track optionsFilingStatus = [];
    @track optionsTaxBrackets = [];

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: QUESTIONNAIRE_OBJECT })
    objectInfo;
    
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        objectApiName: QUESTIONNAIRE_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) {
            console.error('error getting picklist values:', error.body.message);
        } else if (data) {
            this.optionsFilingStatus = data.picklistFieldValues.Filing_Status__c.values;
            this.optionsTaxBrackets = data.picklistFieldValues.Tax_Bracket_Rate__c.values;
        } else {
            console.log('unknown error getting picklists');
        }
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = {
            Combined_Annual_Income__c: this.incomeCombined,
            Filing_Status__c: this.filingStatus,
            Tax_Bracket_Rate__c: this.taxBracketRate,
        };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeIncome(event) {
        this.incomeCombined = parseInt(event.detail.value,10);
        this.dispatchData();
    }
    handleChangeFilingStatus(event) {
        this.filingStatus = event.detail.value;
        this.dispatchData();
    }
    handleChangeRate(event) {
        this.taxBracketRate = event.detail.value;
        this.dispatchData();
    }

}