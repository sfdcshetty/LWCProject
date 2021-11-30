//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import UNIFI_OBJECT from '@salesforce/schema/Financial_Profile__c';
import HEADER from '@salesforce/label/c.x7sFinancialProfile_PlanningObjectives_Header';

import {api,LightningElement } from 'lwc';

export default class X7sFinancialProfilePlanningObjectives extends LightningElement {
    @api debug = false;
    @api fields = []; // an array of field API names; should be passed in from the parent component

    header = HEADER;
    
    _answers = {};
    @api set answers(val) { this._answers = {...val}; } // unravel this object so we can modify it and send it back for saving
    get answers() { return this._answers; }

    get questionsAndAnswers() {
        if (this.fields) {
            return this.fields.map(i=>({ 
                //field: i,
                //label: (this.objectInfo.data.fields[i]) ? this.objectInfo.data.fields[i].inlineHelpText : i,
                field: i.fieldPath,
                label: i.inlineHelpText || i.label,
                value: this.answers[i.fieldPath],
            }))
        } else {
            return [];
        }
    }
    
    //@wire(getObjectInfo, { objectApiName: UNIFI_OBJECT })
    //objectInfo;

    optionsQuestions = [
        {label:'Very Important',value:'Very Important'},
        {label:'Somewhat Important',value:'Somewhat Important'},
        {label:'Not Important',value:'Not Important'},
    ];

    /**
     * dispatch form data to the parent component for saving as temp data
     */
     dispatchData() {
        const obj = Object.fromEntries( this.questionsAndAnswers.map(i=>([i.field, i.value])) );
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: obj },
            })
        );
    }

    handleChangeAnswers(event) {
        let questionIndex = parseInt(event.currentTarget.dataset.questionIndex,10);
        let answer = event.detail.value;
        this._answers[this.fields[questionIndex].fieldPath] = answer; // this modifies the underlying _answers object directly
        this.dispatchData();
    }
}