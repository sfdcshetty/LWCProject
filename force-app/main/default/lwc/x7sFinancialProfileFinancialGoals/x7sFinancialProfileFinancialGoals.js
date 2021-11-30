import HEADER from '@salesforce/label/c.x7sFinancialProfile_FinancialGoals_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_FinancialGoals_Paragraph';

import getFinancialProfileFinancialGoals from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileFinancialGoals';
import { api,track,wire,LightningElement } from 'lwc';

export default class X7sFinancialProfileFinancialGoals extends LightningElement {
    @api debug = false;

    header = HEADER;
    paragraphs = PARAGRAPH.split(/\n+/);
    hideLoading = false;

    @track buttons = [];
    @wire(getFinancialProfileFinancialGoals)
    wiredFinancialGoals({data,error}) {
        if (error) {
            console.error(error);
        } else if (data) {
            if (this.debug) console.log('financial goals data:',data);
            this.buttons = data.map(i=>{ 
                let temp = {
                    ...i,
                    isShortTerm: i.Term__c === 'Short-Term',
                    isLongTerm: i.Term__c === 'Long-Term',
                };
                delete temp.Id;
                return temp;
            });
            this.updateButtons();
            this.hideLoading = true;
        }
    }

    _goals = [];
    @api set goals(val) {
        this._goals = val || [];
        this.selectedCheckboxes = val ? val.map(i=>i.Goal_Name__c) : [];
        this.updateButtons();
    }
    get goals() {
        return this._goals;
    }
    get customGoals() { return this._goals.filter(i=>i.Term__c==='Custom'); }

    updateButtons() {
        if (this.buttons.length && this._goals.length)
        // don't use the Is_Selected__c property; just set the button 'selected' to true if the Goal exists
        this.buttons = this.buttons.map(j => ({
            ...j,
            selected: (0 <= this._goals.findIndex(i => i.Goal_Name__c === j.Label)) ? true : j.selected,
        }));
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        const selectedGoals = this.buttons.filter(i => i.selected).map(i=>({
            ...i,
            Goal_Name__c: i.Label,
            Is_Default__c: true,
        }));
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { goals: [...selectedGoals, ...this.customGoals] },
            })
        );
    }

    handleChangeGoal(event) {
        event.preventDefault();
        let label = event.currentTarget.dataset.label;
        this.buttons = this.buttons.map(i => ({
            ...i,
            selected: i.Label === label ? !i.selected : i.selected, // toggle 'selected' if 'Label' matches
        }));
        this.goals = [...this.buttons.filter(i=>i.selected), ...this.customGoals];
        this.dispatchData();
    }

    showAddCustomGoal = false;
    handleShowAddCustomGoal(event) { this.showAddCustomGoal = true; }
    hideAddCustomGoal(event) { this.showAddCustomGoal = false; }

    tempCustomGoalName = '';
    tempCustomGoalDescription = '';
    clearCustomGoalData() { this.tempCustomGoalName = ''; this.tempCustomGoalDescription = ''; }
    handleChangeGoalName(event) { this.tempCustomGoalName = event.detail.value; }
    handleChangeGoalDescription(event) { this.tempCustomGoalDescription = event.detail.value; }

    handleCancelAddCustomGoal(event) {
        this.clearCustomGoalData();
        this.hideAddCustomGoal();
    }
    handleAddCustomGoal(event) {
        if (this.isValidCustomGoal) {
            this.goals = [
                ...this.goals,
                { 
                    Id: this.goals.length, 
                    Term__c: 'Custom', 
                    Is_Default__c: false,
                    Goal_Name__c: this.tempCustomGoalName, 
                    Description__c: this.tempCustomGoalDescription,
                }
            ];
            this.dispatchData();
            this.clearCustomGoalData();
            this.hideAddCustomGoal();
        }
    }
    handleRemoveCustomGoal(event) {
        const id = event.currentTarget.dataset.id;
        this.goals = this.goals.filter(i=>i.Id!=id);
        this.dispatchData();
    }

    get isInvalidCustomGoal() { return !this.isValidCustomGoal; }
    get isValidCustomGoal() {
        const inputs = this.template.querySelectorAll('.x7s-finprofile_add-custom-goal-form lightning-input,.x7s-finprofile_add-custom-goal-form lightning-textarea');
        return inputs.length && [...inputs]
            .reduce((validSoFar, inputCmp) => {
                        //inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
    }
}