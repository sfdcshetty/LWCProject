import HEADER from '@salesforce/label/c.x7sFinancialProfile_ShareDocuments_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_ShareDocuments_Paragraph';
import BUTTON_LABEL from '@salesforce/label/c.x7sFinancialProfile_ShareDocuments_ButtonLabel';
import LISTS from '@salesforce/label/c.x7sFinancialProfile_DocumentList_Lists';
import { fireEvent } from 'c/pubsub';
import { api,track,LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class X7sFinancialProfileShareDocuments extends NavigationMixin(LightningElement) {
    @api debug = false;
    @api vaultPageApi = 'Docuvault_Test__c';

    header = HEADER;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);
    vaultButtonLabel = BUTTON_LABEL;
    vaultUrl = '';

    @track documents;

    // copied from x7sFinancialProfileDocListModal
    connectedCallback() {
        this.generateVaultUrl();
        // take the LISTS custom label and parse it into multi-item lists and their titles
        const arr = LISTS.split(/[\r\n]+/);
        const lists = [];
        arr.forEach(i=>{
            const regexStartsWithHyphen = /^\s*-\s*(.*)$/;
            const matches = i.match(regexStartsWithHyphen);
            if (!matches) { // no hyphen, this is a list title
                lists.push({ title:i, items:[] });
            } else { // this is a list item
                lists[lists.length-1].items.push(matches[1]);
            }
        });
        this.documents = lists;
    }

    handleClickContinue() {
        fireEvent('goNext','skipping ahead');
    }

    generateVaultUrl() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: this.vaultPageApi,
            },
        }).then(url => {
            this.vaultUrl = url;
        });
    }
}