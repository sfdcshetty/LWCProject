import ESTATE_PLANNING_HEADER from '@salesforce/label/c.x7sFinancialProfile_EstatePlanning_Header';
import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileEstatePlanning extends LightningElement {
    @api debug = false;
    @api primaryName = '';
    @api secondaryName = '';
    @api hideHeader = false;

    _alternateLabels = []; // an ordered array of replacement questions, used by the x7sWegEstatePlanningSelection wrapper
    @api set alternateLabels(val) {
        this._alternateLabels = [...val];
        this._questions = this.addAltLabelsToQuestions(this._questions);
    }
    get alternateLabels() { return this._alternateLabels; }
    get showAlternateLabels() { return (this.alternateLabels.length>0); }

    get primaryAndSecondaryNames() {
        return (this.secondaryName) ? `you or ${this.secondaryName}` : `you`;
    }
    get header() {
        return ESTATE_PLANNING_HEADER.replace('you',this.primaryAndSecondaryNames);
    }

    _questions = []; 
    @api set questions(val) { 
        if (val) {
            this._questions = val.map(i=>({ 
                ...i, 
                isPrimary: i.fieldPath.includes('Primary_'),
            }) ); 
            this._questions = this.addAltLabelsToQuestions(this._questions);
        }
        if (this.debug) console.log('questions:',JSON.parse(JSON.stringify(this._questions)));
        if (Object.keys(this.answers).length) this.addAnswersToQuestions(); // only do this once
    }
    get questions() { return this._questions; }

    /**
     * check this.alternateLabels and add them to the questions array
     */
    addAltLabelsToQuestions(questions) {
        return questions.map((i,idx)=>{
            const obj = {...i};
            const idxAltLabel = Math.floor(idx/2);
            if (this.alternateLabels[idxAltLabel]) obj.alternateLabel = this.alternateLabels[idxAltLabel];
            return obj;
        });
    }

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