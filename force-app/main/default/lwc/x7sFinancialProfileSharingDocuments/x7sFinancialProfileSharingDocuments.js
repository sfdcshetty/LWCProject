import HEADER from '@salesforce/label/c.x7sFinancialProfile_SharingDocuments_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_SharingDocuments_Paragraph';
import { fireEvent } from 'c/pubsub';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileIncomeExpenses extends LightningElement {
    @api debug = false;

    header = HEADER;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);

    handleClickContinue() {
        fireEvent('goNext','skipping ahead');
    }
}