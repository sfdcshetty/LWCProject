import HEADER from '@salesforce/label/c.x7sFinancialProfile_AddTrustedContact_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_AddTrustedContact_Paragraph';

import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileAddTrustedContact extends LightningElement {
    @api debug = false;

    @api firstName = '';
    @api lastName = '';
    @api phone = '';
    @api email = '';

    header = HEADER;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        const obj = {
            Trusted_Contact_First_Name__c: this.firstName,
            Trusted_Contact_Last_Name__c: this.lastName,
            Trusted_Contact_Phone__c: this.phone,
            Trusted_Contact_Email__c: this.email,
        };
        this.dispatchEvent(
            new CustomEvent('savetempdata', { detail: { personalInfo: obj } })
        );
    }

    // change event handlers for the form fields
    handleChangeFirstName(event) {
        this.firstName = event.detail.value;
        this.dispatchData();
    }
    handleChangeLastName(event) {
        this.lastName = event.detail.value;
        this.dispatchData();
    }
    handleChangePhone(event) {
        this.phone = event.detail.value;
        this.dispatchData();
    }
    handleChangeEmail(event) {
        this.email = event.detail.value;
        this.dispatchData();
    }
}