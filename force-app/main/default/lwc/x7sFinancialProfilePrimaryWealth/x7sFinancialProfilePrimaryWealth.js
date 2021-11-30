import HEADER from '@salesforce/label/c.x7sFinancialProfile_PrimarySourceOfWealth_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_PrimarySourceOfWealth_Paragraph';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfilePrimaryWealth extends LightningElement {
    @api debug = false;
    @api primaryWealth = '';
    @api optionsWealth = [];

    header = HEADER;
    paragraphs = PARAGRAPH.split(/\n+/);

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = { "Primary_Source_of_Wealth__c": this.primaryWealth };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangePrimaryWealth(event) { 
        this.primaryWealth = event.detail.value; 
        this.dispatchData(); 
    }
}