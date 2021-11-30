import HEADER from '@salesforce/label/c.x7sFinancialProfile_AddDependents_Header';
import FORMHEADER from '@salesforce/label/c.x7sFinancialProfile_AddDependents_FormHeader';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import DEPENDENT_OBJECT from '@salesforce/schema/Financial_Profile_Dependent__c';

import { wire,track,api,LightningElement } from 'lwc';

export default class X7sFinancialProfileAddDependents extends LightningElement {
    @api debug = false;

    _dependents = [];
    @api set dependents(val) {
        this._dependents = val.map(i => ({ ...i }));
    }
    get dependents() {
        return this._dependents;
    }

    blankRecord = { Id: 0 };

    @track optionsRelationship = [];
    @track optionsState = [];

    header = HEADER;
    formHeader = FORMHEADER;

    optionsYesNo = [
        { label:"Yes", value:"Yes" },
        { label:"No",  value:"No" },
    ]

    // get object info for unifi questionnaire
    @wire(getObjectInfo, { objectApiName: DEPENDENT_OBJECT })
    objectInfo;
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        objectApiName: DEPENDENT_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (data) {
            this.optionsRelationship = data.picklistFieldValues.Relationship__c.values;
            this.optionsState = data.picklistFieldValues.State__c.values;
        } else if (error) {
            console.error('error getting picklist values:', error.body.message);
        } else {
            console.log('unknown error getting picklists');
        }
    }

    connectedCallback() {}

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { dependents: this.dependents },
            })
        );
    }

    handleChangeYesNo(event) {
        if (event.detail.value==='Yes') {
            this.dependents = [{ ...this.blankRecord }];
        } else {
            this.dispatchEvent(new CustomEvent('next'))
        };
    }

    handleChangeFirstName(event) {
        this.dependents[event.currentTarget.dataset.index].First_Name__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeMiddleInitial(event) {
        this.dependents[event.currentTarget.dataset.index].Middle_Initial__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeLastName(event) {
        this.dependents[event.currentTarget.dataset.index].Last_Name__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeSuffix(event) {
        this.dependents[event.currentTarget.dataset.index].Suffix__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeDateOfBirth(event) {
        this.dependents[event.currentTarget.dataset.index].Date_of_Birth__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeState(event) {
        this.dependents[event.currentTarget.dataset.index].State__c = event.detail.value;
        this.dispatchData();
    }
    handleChangeRelationship(event) {
        this.dependents[event.currentTarget.dataset.index].Relationship__c = event.detail.value;
        this.dispatchData();
    }

    handleClickAddAnotherDependent() {
        this.dependents = [...this.dependents, { 
            ...this.blankRecord,
            Id: this.dependents.length,
        }];
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            const currIndex = parseInt(event.currentTarget.dataset.rowIndex, 10);
            this.dependents = this.dependents.filter((i, idx) => idx !== currIndex);
            this.dispatchData();
        }
    }
}