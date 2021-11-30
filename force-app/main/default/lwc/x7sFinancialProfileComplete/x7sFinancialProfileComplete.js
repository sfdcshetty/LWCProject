import HEADER from '@salesforce/label/c.x7sFinancialProfile_Complete_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_Complete_Paragraph';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileComplete extends LightningElement {
    @api debug = false;
    @api isCompleted = false;
    @api completedDate = '';

    header = HEADER;
    //paragraph = PARAGRAPH;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);

    handleSaveTempData(event) {
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: event.detail,
            })
        );
    }
}