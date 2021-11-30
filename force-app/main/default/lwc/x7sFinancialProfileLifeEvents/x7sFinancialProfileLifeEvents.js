import HEADER from '@salesforce/label/c.x7sFinancialProfile_LifeEvents_Header';
import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileLifeEvents extends LightningElement {
    @api debug = false;
    @api explanation = '';
    header = HEADER;
    
    _selectedEvents = [];
    // selectedEvents can't be null or undefined
    @api set selectedEvents(val) { this._selectedEvents = (val) ? val : []; }
    get selectedEvents() { return this._selectedEvents; }

    @api optionsEvents = [];
    get showExplanation() { return this.optionsEvents.length && this.selectedEvents.includes('Other'); }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        const obj = {
            Future_Life_Event__c: [...this.selectedEvents],
            Future_Life_Event_Explanation__c: this.explanation,
        };
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeEvents(event) {
        this.selectedEvents = event.detail.value;
        if (this.debug) console.log('selected events:', this.selectedEvents);
        this.dispatchData();
    }

    handleChangeExplanation(event) {
        this.explanation = event.detail.value;
        this.dispatchData();
    }
}