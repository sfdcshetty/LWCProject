import HEADER from '@salesforce/label/c.x7sFinancialProfile_DocumentList_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_DocumentList_Paragraph';
import LISTS from '@salesforce/label/c.x7sFinancialProfile_DocumentList_Lists';
/* initial value for LISTS looks like below. Each document/list item should begin with a hyphen; each list title should not.

General
-Federal and state income tax returns
-Recent W2s
-Recent pay stubs
-Social Security statements

Investments
-Employer retirement plan statements
-Retirement account statements
-Investments account statements
-Pension benefit statements
*/

import {track,LightningElement} from 'lwc';

export default class X7sFinancialProfileDocListModal extends LightningElement {

    header = HEADER;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);
    @track documents = [];

    connectedCallback() {
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

    /**
     * dispatch a custom event (close) up to parent component
     * parent component handles 'close' event with 'onclose' and sends to event handler
     */
    handleModalClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

}