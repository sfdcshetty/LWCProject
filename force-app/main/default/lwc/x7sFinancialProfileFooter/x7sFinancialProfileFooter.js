/**
 * Created by martinblase on 4/6/21.
 */

//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { api,LightningElement } from "lwc";

export default class X7sFinancialProfileFooter extends LightningElement {
    @api goHomeAfterComplete = false;

    percentProgress = 0;
    isFirstPage = false;
    isLastPage = false;
    totalAssets = -1; // don't display
    get labelSaveAndClose() { return (this.goHomeAfterComplete) ? 'Save and Exit' : 'Save & Close'; }

    get showTotalAssets() { return (this.totalAssets>=0); }

    connectedCallback() {
        registerListener('updateProgress',this.updateProgress, this);
        registerListener('showFirstPage', this.showFirstPage, this);
        registerListener('hideFirstPage', this.hideFirstPage, this);
        registerListener('showLastPage', this.showLastPage, this);
        registerListener('hideLastPage', this.hideLastPage, this);
        registerListener('updateTotalAssets', this.updateTotalAssets, this);
        fireEvent('getPercent'); 
        fireEvent('getButtons');
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleClickSkip() {
        fireEvent('goNext','skipping ahead');
    }

    handleClickBack() {
        fireEvent('goBack','going back');
    }

    handleClickSaveAndNext() {
        fireEvent('saveData','saving data');
        fireEvent('goNext','skipping ahead');
    }

    handleClickSaveAndClose() {
        fireEvent('saveData','saving data');
        if (this.goHomeAfterComplete) {
            fireEvent('goHome','going home');
        } else {
            fireEvent('closeModal','closing window');
        }
    }

    updateProgress(pct) {
        this.percentProgress = pct;
    }

    updateTotalAssets(amt) {
        this.totalAssets = amt;
    }

    showFirstPage() { this.isFirstPage = true; }
    hideFirstPage() { this.isFirstPage = false; }
    showLastPage() { this.isLastPage = true; }
    hideLastPage() { this.isLastPage = false; }
}