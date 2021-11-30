import HEADER from '@salesforce/label/c.x7sFinancialProfile_SocialSecurityBenefit_Header';
import { fireEvent } from 'c/pubsub';
import { api,LightningElement } from 'lwc';

export default class X7sFinancialProfileSocialSecurityBenefit extends LightningElement {
    incomeExpenseType = 'Social Security';

    @api debug = false;
    @api primaryName = '';
    @api secondaryName = '';
    @api primaryContactId = '';
    @api secondaryContactId = '';
    @api showPrimary = false;
    @api showSecondary = false;

    @api incomeExpenses = [];
    get primaryAmount() { return this.getAmount(this.primaryContactId); }
    get secondaryAmount() { return this.getAmount(this.secondaryContactId); }
    
    getAmount(id) {
        let el = {};
        if (this.incomeExpenses) el = this.incomeExpenses.find(i=>(i.Type__c===this.incomeExpenseType&&i.Owner__c===id));
        return el ? el.Amount__c : undefined;
    }

    header = HEADER;

    connectedCallback() {
        // check if this is even necessary, or skip to the next screen if it's not
        if (!this.showPrimary && !this.showSecondary) {
            fireEvent('goSkip','skipping '+this.incomeExpenseType);
        }
    }

    /**
     * dispatch form data to the parent component for saving as temp data
     */
    dispatchData() {
        this.dispatchEvent(
            new CustomEvent('savetempdata', {
                detail: { incomeExpenses: this.incomeExpenses },
            })
        );
    }

    handleChangePrimaryBenefit(event) {
        const amount = parseInt(event.detail.value,10);
        this.incomeExpenses = this.updateIncomeExpenses(amount,this.primaryContactId);
        this.dispatchData();
    }

    handleChangeSecondaryBenefit(event) {
        const amount = parseInt(event.detail.value,10);
        this.incomeExpenses = this.updateIncomeExpenses(amount,this.secondaryContactId);
        this.dispatchData();
    }

    updateIncomeExpenses(amount,id) {
        if (this.incomeExpenses.some(i=>(i.Type__c===this.incomeExpenseType&&i.Owner__c===id))) {
            return this.incomeExpenses.map(i=>({
                ...i,
                Amount__c: (i.Type__c===this.incomeExpenseType&&i.Owner__c===id) ? amount : i.Amount__c,
            }));
        } else {
            const newObj = {
                Name: this.incomeExpenseType,
                Description__c: '',
                Amount__c: amount,
                Type__c: this.incomeExpenseType,
                Owner__c: id,
            };
            return [ ...this.incomeExpenses, newObj ];
        }
    }
}