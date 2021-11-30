import { track, LightningElement } from 'lwc';

export default class X7sFinancialProfileAboutYourPlannedExpenses extends LightningElement {
    showForm = false;
    optionsOwner = [
        { label: 'Joanna', value: 'Joanna' }, // TODO: retrieve these options from the org
        { label: 'Thomas', value: 'Thomas' },
    ];
    @track data = [{ id: 0, description: '', owner: '', amount: 0 }];

    handleUpdateRowData(event) {
        this.data = [...event.detail];
    }

    /**
     * show the 'add future expenses' form
     */
    handleClickAddFutureExpenses() {
        this.showForm = true;
    }

    /**
     * skip to the next screen
     */
    handleClickDontAddFutureExpenses() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}