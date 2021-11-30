import { api, LightningElement } from 'lwc';

export default class X7sUnifiQuestionnaireAboutYourRows extends LightningElement {
    blankRow = { id: 0, type: '', name: '', owner: '', amount: 0 };
    @api owners = [{}];
    @api types = [{}];
    @api type = "account"; // account, asset, realestate, vehicle, debt

    @api _rowData = [{}];
    @api set rowData(arr) { this._rowData = arr.map(i=>({...i})).map(j=>({...j})); } // need to unroll this object twice to completely de-proxy it
    get rowData() { return this._rowData; }

    get labelType() { return (this.type==='account' ? 'Account Type' : 'Property Type') };
    get labelName() { return (this.type==='account' ? 'Financial Institution' : 'Nickname') };
    get isRealEstate() { return (this.type==='realestate'); }
    get isVehicle() { return (this.type==='vehicle'); }
    get isDebt() { return (this.type==='debt'); }

    /**
     * Update the 'type' field for a specific row
     * @param {*} event 
     */
    handleChangeType(event) {
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].type = event.detail.value;
    }
    
    /**
     * Update the 'name' field for a specific row
     * @param {*} event 
     */
    handleChangeName(event) { 
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].name = event.detail.value;
     };

    /**
     * Update the 'owner' field for a specific row
     * @param {*} event 
     */
    handleChangeOwner(event) {
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].owner = event.detail.value;
    }
    
     /**
      * Update the 'amount' field for a specific row
      * @param {*} event 
      */
     handleChangeAmount(event) { 
        const currIndex = parseInt(event.currentTarget.dataset.rowIndex,10);
        this.rowData[currIndex].amount = parseInt(event.detail.value,10) || 0;
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