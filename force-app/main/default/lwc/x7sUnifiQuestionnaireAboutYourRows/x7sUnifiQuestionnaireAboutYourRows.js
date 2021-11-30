import { api, LightningElement } from 'lwc';

export default class X7sUnifiQuestionnaireAboutYourRows extends LightningElement {
    blankRow = { id: 0, description: '', owner: '', amount: 0 };
    @api owners = [{}];
    @api type = "income";

    @api _rowData = [{}];
    @api set rowData(arr) { this._rowData = arr.map(i=>({...i})).map(j=>({...j})); } // need to unroll this object twice to completely de-proxy it
    get rowData() { return this._rowData; }

    get labelAmount() { return (this.type==='expense' ? 'Amount' : 'Current monthly income') };

    /**
     * Update the 'description' field for a specific row
     * @param {*} event 
     */
    handleChangeDescription(event) { 
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].description = event.detail.value;
     };
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
     handleChangeAmount(event) { 
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].amount = parseInt(event.detail.value,10) || 0;
    }
    
    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].owner = event.detail.value;
    }

    /**
     * Add an extra blank row to the bottom
     * @param {*} event 
     */
    handleClickAddAnotherRow(event) {
        this.rowData.push( {...this.blankRow, id: this.rowData.length} );
        this.deployRowData();
    }

    /**
     * Remove a given row, with a prompt to confirm
     * @param {*} event 
     */
    handleClickRemoveRow(event) {
        if (window.confirm('Are you sure you want to completely delete this row of data?')) {
            const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
            this.rowData.splice(currIndex,1);
            this.deployRowData();
        }
    }

    deployRowData() {
        this.dispatchEvent(new CustomEvent('update', { detail: this.rowData }));
    }

}