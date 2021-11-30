import { fireEvent } from 'c/pubsub';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileCurrentlyEmployed extends LightningElement {
    @api debug = false;
    @api contactId = '';
    @api isRetired = false;
    @api isCoClient = false;
    showForm = false;
    blankRecord = { Id: 0 };

    _retirementAge = 0;
    @api set retirementAge(val) {
        this._retirementAge = val;
        if (val) this.showForm = true;
    }
    get retirementAge() { return this._retirementAge; }

    _employers = [{ ...this.blankRecord }];
    @api set employers(val) {
        if (val && val.length) {
            if (this.debug) console.log( 'passed employers:', JSON.parse(JSON.stringify(val)) );
            this._employers = val.map(i => ({ ...i }));
        } else {
            this._employers = [{ ...this.blankRecord }];
        }
    }
    get employers() { return this._employers; }

    @api otherContactRecord = {}; 
    get otherContact() { return (this.otherContactRecord && this.otherContactRecord.FirstName) ? this.otherContactRecord.FirstName : ''; } // name of another person this applies to

    get labelSelfEmployed() {
        return (this.otherContact.length)
            ? this.otherContact + ' is self-employed and this is their business'
            : 'I am self-employed and this is my business.';
    }

    connectedCallback() {
        if (this.isCoClient) {
            if (!this.otherContact) {
                fireEvent('goSkip','no co-client');
            }
        }
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        const obj = (this.contactId) ? { 
            Co_Client_Is_Retired__c: this.isRetired,
            Co_Client_Expected_Retirement_Age__c: this.isRetired ? null : this.retirementAge,
        } : { 
            Is_Retired__c: this.isRetired,
            Expected_Retirement_Age__c: this.isRetired ? null : this.retirementAge,
        };
        const employers = this.employers.map(i=>({
            ...i,
            Owner__c: this.contactId || null,
        } ));
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { 
                    personalInfo: obj, 
                    employers: employers,
                },
            })
        );
    }

    handleClickEmployed() {
        this.isRetired = false;
        this.showForm = true;
    }

    handleClickUnemployed() {
        this.isRetired = false;
        this.dispatchData();
        fireEvent('saveData','saving data');
        // skip to the next screen
        this.dispatchEvent(new CustomEvent('next'));
    }

    handleClickRetired() {
        this.isRetired = true;
        this.dispatchData();
        fireEvent('saveData','saving data');
        // skip to the next screen
        this.dispatchEvent(new CustomEvent('next'));
    }

    handleClickAddAnotherEmployer() {
        //this._employers.push({ Id: this._employers.length });
        this.employers = [...this.employers, { Id: this.employers.length }];
    }

    handleChangeEmployerName(event) {
        this._employers[event.currentTarget.dataset.index].Employer_Name__c =
            event.detail.value;
        this.dispatchData();
    }
    handleChangeSelfEmployed(event) {
        this._employers[event.currentTarget.dataset.index].Is_Self_Employed__c =
            event.detail.value;
        this.dispatchData();
    }
    handleChangeOccupation(event) {
        this._employers[event.currentTarget.dataset.index].Occupation__c =
            event.detail.value;
        this.dispatchData();
    }
    handleChangeAnnualIncome(event) {
        this._employers[event.currentTarget.dataset.index].Annual_Income__c =
            event.detail.value;
        this.dispatchData();
    }
    handleChangeRetirementAge(event) {
        this.retirementAge = event.detail.value;
        this.dispatchData();
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event 
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
            this.employers = this.employers.filter((i,idx)=>idx!==currIndex);
            this.dispatchData();
        }
    }
}