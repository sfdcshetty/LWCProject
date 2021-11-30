import HEADER from '@salesforce/label/c.x7sFinancialProfile_MonthlySpending_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_MonthlySpending_Paragraph';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileMonthlySpending extends LightningElement {
    @api debug = false;
    header = HEADER;
    regexUrl = /(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))/;
    paragraphs = PARAGRAPH.replace(this.regexUrl,'<a href="$1" target="_blank">$1</a>').split(/[\r\n]+/);

    _estimateMonthlySpending = 0;
    @api set estimateMonthlySpending(val) { this._estimateMonthlySpending = parseInt(val,10) || 0; }
    get estimateMonthlySpending() { return this._estimateMonthlySpending; }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = { Estimated_Monthly_Spending__c: this.estimateMonthlySpending };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeMonthlySpending(event) { 
        this.estimateMonthlySpending = event.detail.value; 
        this.dispatchData();
    }
}