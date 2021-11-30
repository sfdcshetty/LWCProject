import LABEL from '@salesforce/label/c.x7sFinancialProfile_MarkCompleted_ButtonLabel';
import { fireEvent } from 'c/pubsub';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileMarkCompleted extends LightningElement {
    labelButton = LABEL;
    @api isCompleted = false;
    @api completedDate = '';

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = { 
            Is_Completed__c: true,
            Completed_Date__c: new Date().toISOString(),
        };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
        // save the form once the temp data has been dispatched
        fireEvent('saveData','saving completed form');
    }
}