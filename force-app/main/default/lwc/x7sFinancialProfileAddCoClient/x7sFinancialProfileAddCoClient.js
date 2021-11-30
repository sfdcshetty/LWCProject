import HEADER from '@salesforce/label/c.x7sFinancialProfile_AddCoClient_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_AddCoClient_Paragraph';
import FORM_HEADER from '@salesforce/label/c.x7sFinancialProfile_AddCoClient_FormHeader';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileAddCoClient extends LightningElement {
    @api debug = false;
    @api coClientId;
    @api coClientData = {};

    header = HEADER;
    paragraphs = PARAGRAPH.split(/\n+/);
    formHeader = FORM_HEADER;

    optionsYesNo = [
        { label:"Yes", value:"Yes" },
        { label:"No",  value:"No" },
    ]

    /**
     * handle a click on the buttons to add or not add a co-client
     * @param {*} event 
     */
    handleChangeYesNo(event) {
        if (event.detail.value==='Yes') {
            this.coClientId = 1;
            this.coClientData = {
                FirstName: '', MiddleName: '', LastName: '', Suffix: '',
                Birthdate: '', 
                MailingStreet: '', MailingCity: '', MailingState: '', MailingPostalCode: '',
                WEG_Business_Email__c: '', WEGP1_PersonalEmail__c: '', WEGP1_OtherEmail__c: '',
                Phone: '', HomePhone: '', AssistantPhone: '',
            };
        }
        if (event.detail.value==='No') this.dispatchEvent(new CustomEvent('next'));
    }

    /**
     * save the temp data from the PersonalInfo subcomponent and pass it up to the parent component
     * @param {*} event 
     */
    handleSaveTempData(event) {
        this.dispatchEvent(new CustomEvent('savetempdata', { 
            detail: {
                coClient: {
                    ...event.detail.coClient,
                    Id: (typeof this.coClientId==="string") ? this.coClientId : null,
                }
            }
        } ));
    }
}