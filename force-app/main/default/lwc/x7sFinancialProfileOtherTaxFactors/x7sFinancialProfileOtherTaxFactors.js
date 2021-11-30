import PRIMARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_OtherTaxFactors_Header';
import SECONDARY_HEADER from '@salesforce/label/c.x7sFinancialProfile_CoClientOtherTaxFactors_Header';
import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileOtherTaxFactors extends LightningElement {
    @api debug = false;
    @api primaryName = '';
    @api secondaryName = '';
    
    get header() {
        return (this.secondaryName) ? this.strReplace(SECONDARY_HEADER,['coClientName',this.secondaryName]) : PRIMARY_HEADER; 
    }

    strReplace(stringToFormat, ...args) {
        const replacements = Object.fromEntries(args);
        if (typeof stringToFormat !== "string") throw new Error("'stringToFormat' must be a String");
        return stringToFormat.replace(/{(\w+)}/gm, (match, paren)=>{ return replacements[paren] || '' });
    }

    _questions = []; 
    @api set questions(val) { 
        if (val) {
            this._questions = val.map(i=>({
                ...i,
                isPrimary: i.fieldPath.includes('Primary_'),
            })); 
        }
        if (this.debug) console.log('questions:',JSON.parse(JSON.stringify(this._questions)));
        if (Object.keys(this.answers).length) this.addAnswersToQuestions(); // only do this once
    }
    get questions() { return this._questions; }

    _answers = {};
    @api set answers(val) { 
        this._answers = {...val}; // unravel this object so we can modify it and send it back for saving
        if (this.questions && this.questions.length) this.addAnswersToQuestions(); // only do this once
    } 
    get answers() { return this._answers; }

    // update the questions array (used in the HTML template) with the answers we passed in separately
    // IMPORTANT: make sure both the questions and answers have been set before running this method
    addAnswersToQuestions() {
        // modify _questions directly to avoid triggering setter
        this._questions = this._questions.map(i=>({
            ...i,
            value: this.answers[i.fieldPath],
        }));
    }
    
    /**
   * dispatch form data to the parent component for saving as temp data
   */
    dispatchData() {
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { personalInfo: this.answers },
            })
        );
    }

    /**
     * when a checkbox is changed, update this.answers with the current Boolean value for that field/question
     * @param {*} event 
     */
    handleChangeQuestions(event) {
        //let questionIndex = event.currentTarget.dataset.questionIndex;
        let answer = event.currentTarget.dataset.field;
        //this.questions[questionIndex].value = answer; 
        this.answers[answer] = event.detail.checked;
        this.dispatchData();
        if (this.debug) console.log(JSON.parse(JSON.stringify(this.answers)));
    }
}