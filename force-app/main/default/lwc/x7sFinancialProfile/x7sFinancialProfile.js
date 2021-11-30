/**
 * Created by martinblase on 4/6/21.
 */
import HEADER from '@salesforce/label/c.x7sFinancialProfile_Introduction_Header';
import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_Introduction_Paragraph';
import NOTE from '@salesforce/label/c.x7sFinancialProfile_Introduction_Note';

import getFinancialProfilePersonalInfoForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfilePersonalInfoForCurrentUser';
import saveFinancialProfile from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfile';
import saveFinancialProfileCoClient from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileCoClient';
import getFinancialProfileDependentsForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileDependentsForCurrentUser';
import saveFinancialProfileDependents from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileDependents';
import getFinancialProfileEmploymentsForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileEmploymentsForCurrentUser';
import getFinancialProfileEmploymentsForCoClient from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileEmploymentsForCoClient';
import saveFinancialProfileEmployments from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileEmployments';
import getFinancialProfileGoalsForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileGoalsForCurrentUser';
import saveFinancialProfileGoals from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileGoals';
import getFinancialProfileAssetsLiabilitiesForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileAssetsLiabilitiesForCurrentUser';
import saveFinancialProfileAssets from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileAssets';

import getFinancialProfileIncomeExpensesForBoth from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileIncomeExpensesForBoth';
import saveFinancialProfileIncomeExpenses from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileIncomeExpenses';
import getFinancialProfileFinancialAccountsForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileFinancialAccountsForCurrentUser';
import saveFinancialProfileFinancialAccounts from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileFinancialAccounts';
import getFinancialProfileInsurancePoliciesForCurrentUser from '@salesforce/apex/x7s_FinancialProfileController.getFinancialProfileInsurancePoliciesForCurrentUser';
import saveFinancialProfileInsurancePolicies from '@salesforce/apex/x7s_FinancialProfileController.saveFinancialProfileInsurancePolicies';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import QUESTIONNAIRE_OBJECT from '@salesforce/schema/Financial_Profile__c';

//import { refreshApex } from "@salesforce/apex";
import { menuItems } from './menuItems';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { wire, api, track, LightningElement } from 'lwc';
import { showToast } from 'c/x7sShrUtils';

import getPlanningObjectivesList from '@salesforce/apex/x7s_FinancialProfileController.getPlanningObjectivesList';
import getOtherTaxFactorsList from '@salesforce/apex/x7s_FinancialProfileController.getOtherTaxFactorsList';
import getEstatePlanningList from '@salesforce/apex/x7s_FinancialProfileController.getEstatePlanningList';
import getInsuranceCategoriesList from '@salesforce/apex/x7s_FinancialProfileController.getInsuranceCategoriesList';

export default class X7sFinancialProfile extends NavigationMixin(LightningElement) {
    debug = true; // set to false before moving to production

    @api documentVaultPageApi = 'Docuvault_Test__c';
    
    header = HEADER;
    paragraphs = PARAGRAPH.split(/[\r\n]+/);
    note = NOTE;

    // get the list of Planning Objectives field API names and inline help text from the org, 
    // where they're stored in a Field Set called "Planning Objectives" on the Financial Profil object
    @wire(getPlanningObjectivesList) 
    planningFields;
    @wire(getOtherTaxFactorsList) 
    otherTaxFactorsFields;
    @wire(getEstatePlanningList) 
    estatePlanningFields;
    @wire(getInsuranceCategoriesList) 
    insuranceCategoriesFields;

    @api message = 'no message';
    navigate = '';
    @track menuItems = menuItems;
    @track finProfile = {};
    @track finProfileDependents = [];
    @track finProfileEmployers = [];
    @track finProfileCoClientEmployers = [];
    @track finProfileGoals = [];
    @track finProfileIncomeExpenses = [];
    @track finProfileFinancialAccounts = [];
    @track finProfileAssets = [];
    @track finProfileInsurance = [];
    
    @track optionsLifeEvents = [];
    @track optionsTypeOfTrust = [];
    @track optionsSourceOfWealth = [];
    // get object info for Financial Profile
    @wire(getObjectInfo, { objectApiName: QUESTIONNAIRE_OBJECT })
    objectInfo;
    // get picklist values using objectInfo
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        objectApiName: QUESTIONNAIRE_OBJECT,
    })
    getPicklistValues({ data, error }) {
        if (error) {
            console.error('error getting picklist values:', error.body.message);
        } else if (data) {
            this.optionsLifeEvents = data.picklistFieldValues.Future_Life_Event__c.values;
            this.optionsTypeOfTrust = data.picklistFieldValues.Primary_Trust_Type__c.values;
            this.optionsSourceOfWealth = data.picklistFieldValues.Primary_Source_of_Wealth__c.values;
        } else {
            console.log('unknown error getting picklists');
        }
    }
    

    /* ******************************************************************************** */

    get planningAnswers() {
        if (!this.planningFields.data) return [];
        const planningFieldPaths = this.planningFields.data.map(i=>i.fieldPath);
        return Object.fromEntries( 
            Object.entries(this.finProfile).filter( 
                ([k])=>planningFieldPaths.includes(k)
            ) 
        );
    }
    get otherTaxFactorsAnswers() {
        if (!this.otherTaxFactorsFields.data) return [];
        const otherTaxFactorsFieldPaths = this.otherTaxFactorsFields.data.map(i=>i.fieldPath);
        return Object.fromEntries( 
            Object.entries(this.finProfile).filter( 
                ([k])=>otherTaxFactorsFieldPaths.includes(k)
            ) 
        );
    }
    get estatePlanningAnswers() {
        if (!this.estatePlanningFields.data) return [];
        const estatePlanningFieldPaths = this.estatePlanningFields.data.map(i=>i.fieldPath);
        return Object.fromEntries( 
            Object.entries(this.finProfile).filter( 
                ([k])=>estatePlanningFieldPaths.includes(k)
            ) 
        );
    }
    get insuranceCategoriesAnswers() {
        if (!this.insuranceCategoriesFields.data) return [];
        const insuranceCategoriesFieldPaths = this.insuranceCategoriesFields.data.map(i=>i.fieldPath);
        return Object.fromEntries( 
            Object.entries(this.finProfile).filter( 
                ([k])=>insuranceCategoriesFieldPaths.includes(k)
            ) 
        );
    }

    /* ******************************************************************************** */

    get coClientFirstName() {
        if (this.finProfile && this.finProfile.Co_Client_Contact__r) 
            return this.finProfile.Co_Client_Contact__r.FirstName;
        return;
    }

    /**
     * get/set specific types within the finProfileIncomeExpenses array of records
     */
    setFinProfileIncomeExpenses(type,arr=[]) {
        if (type && arr && arr.length) {
            const ie = this.finProfileIncomeExpenses.filter(i=>i.Type__c!==type);
            this.finProfileIncomeExpenses = [...ie, ...arr];
        }
    }
    /**
     * get/set specific types within the finProfileFinancialAccounts array of records
     */
    setFinProfileFinancialAccounts(type,arr=[]) {
        if (type && arr && arr.length) {
            const ie = this.finProfileFinancialAccounts.filter(i=>i.Type__c!==type);
            this.finProfileFinancialAccounts = [...ie, ...arr];
        }
    }
    /**
     * get/set specific types within the finProfileAssets array of records
     */
    setFinProfileAssets(type,arr=[]) {
        if (type && arr && arr.length) {
            const ie = this.finProfileAssets.filter(i=>i.Type__c!==type);
            this.finProfileAssets = [...ie, ...arr];
        }
    }
    /**
     * get/set specific types within the finProfileAssets array of records
     */
    setFinProfileInsurance(type,arr=[]) {
        if (type && arr && arr.length) {
            const ie = this.finProfileInsurance.filter(i=>i.Type__c!==type);
            this.finProfileInsurance = [...ie, ...arr];
        }
    }

    /* ******************************************************************************** */

    /**
     * use the URL query string to determine the current index for the menuItems nav array
     */
    get currentMenuIndex() {
        if (this.currentPageReference && this.currentPageReference.state) {
            return parseInt(this.currentPageReference.state.page, 10) || 0;
        }
        return 0;
    }

    /**
     * use the URL query string to determine the current direction the user is navigating (next/forward is positive, back is negative)
     */
     get currentNavDirection() {
        if (this.currentPageReference && this.currentPageReference.state) {
            return parseInt(this.currentPageReference.state.direction, 10) || 1;
        }
        return 1;
    }

    /**
     * return the current section header string for displaying in the Header component
     */
    get currentSectionHeader() {
        let objIdx = this.currentMenuIndex;
        let obj = this.menuItems[objIdx];
        while (obj.hideInNav && objIdx >= 0) {
            objIdx--;
            obj = this.menuItems[objIdx];
        }
        return obj.label;
    }

    /**
     * return a simple object like { activeFormMenuItemKey: true} for use in this component's template
     */
    get menuActiveState() {
        let obj = {};
        obj[this.menuItems[this.currentMenuIndex].key] = true;
        return obj;
    }

    /* ******************************************************************************** */

    /**
     * retrieve the currentPageReference so we can read the URL query string
     */
    currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        // update the active form from the currentPageReference state
        if (this.connected) {
            this.updateForm();
        } else {
            this.updateNavOnConnected = true;
        }
    }

    connectedCallback() {
        // update the active form from the currentPageReference state
        this.connected = true;
        if (this.updateNavOnConnected) {
            this.updateForm();
        }
        fireEvent('updateHeader', this.currentSectionHeader);
        // register button actions from the header and footer
        registerListener('saveData', this.saveData, this);
        registerListener('goBack', this.goBack, this);
        registerListener('goNext', this.goNext, this);
        registerListener('goSkip', this.goSkip, this);
        registerListener('showDocList', this.toggleDocList, this);
        registerListener('getPercent', this.getPercent, this);
        registerListener('getButtons', this.getButtons, this);
        registerListener('closeModal', this.closeModal, this);
        registerListener('goHome', this.goHome, this);
        // get the existing Financial Profile, or create a new one if needed
        this.getFinancialProfileQuestionnaire();
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    /* ******************************************************************************** */

    /**
     * show a modal with the list of needed documents
     */
    showDocListModal = false;
    toggleDocList() { this.showDocListModal = !this.showDocListModal; }

    /**
     * handle a 'navigate' event from a child component
     */
    handleNavigate(event) {
        let idx = parseInt(event.detail.index, 10);
        // navigate to the new form
        this.updateState(idx);
    }

    /**
     * determine which footer buttons should be disabled
     */
    getButtons() {
        // update footer buttons
        if (this.currentMenuIndex===0) {
            fireEvent('showFirstPage');
        } else {
            fireEvent('hideFirstPage');
        }
        if (this.currentMenuIndex===this.menuItems.length-1) {
            fireEvent('showLastPage');
        } else {
            fireEvent('hideLastPage');
        }
    }

    /**
     * compute the percent-complete based on navigation progress
     */
    getPercent() {
        let percent = Math.round((100 * this.currentMenuIndex) / (this.menuItems.length - 1));
        fireEvent('updateProgress', percent);
    }
    /**
     * go backwards one navigation item
     * @param {*} str - informational message
     */
    goBack(str) {
        if (this.debug) console.log('goBack:',str);
        fireEvent('hideLastPage');
        this.navigateForm(-1);
    }
    /**
     * go forwards one navigation item
     * @param {*} str - informational message
     */
    goNext(str) {
        if (this.debug) console.log('goNext:',str);
        fireEvent('hideFirstPage');
        this.navigateForm(1);
    }
    /**
     * go backwards or forwards one navigation item, depending on what's in this.currentNavDirection
     * @param {*} str - informational message
     */
    goSkip(str) {
        const direction = this.currentNavDirection;
        if (this.debug) console.log('goSkip:',str,direction);
        if (direction<0) this.goBack('skipping backward');
        else this.goNext('skipping ahead');
    }

    /**
     * navigate to the site home
     */
    goHome(str) {
        if (this.debug) console.log('goHome:',str);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home',
            },
        });
    }

    /**
     * close the containing modal
     */
    closeModal(str) {
        if (this.debug) console.log('closeModal:',str);
        this.dispatchEvent(new CustomEvent('close'));
    }

    /**
     * navigate forward or backward the specified number of pages
     */
     navigateForm(incr) {
        let newMenuIndex = this.currentMenuIndex + incr;
        if (this.menuItems[newMenuIndex]) {
            this.updateState(newMenuIndex,incr);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Navigation error',
                    message: "Sorry, that isn't a valid navigation page.",
                    variant: 'error',
                })
            );
        }
    }

    /**
     * navigate directly to the specified page
     */
    updateForm() {
        let idx = this.currentMenuIndex;
        if (this.menuItems[idx]) {
            if (this.debug) console.log('updateForm:',`navigate to ${idx}`);
            // update the title in the header
            fireEvent('updateHeader', this.currentSectionHeader);
            this.updateFooter();
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Navigation error',
                    message: "Sorry, that isn't a valid navigation page.",
                    variant: 'error',
                })
            );
        }
    }

    /**
     * update the various elements of the financial profile footer component
     */
    updateFooter() {
        this.getPercent(); // update the progress bar in the footer
        this.getButtons(); // update the disabled buttons in the footer
    }

    /**
     * update the currentPageReference state
     */
    updateState(idx,direction) {
        const state = {
            ...this.currentPageReference.state,
            page: idx,
        };
        if (direction<0) state.direction = -1; 
        else delete state.direction;
        fireEvent('updateTotalAssets',-1); // hide the total assets bar in the footer component
        // update the current page reference 
        if (this.currentMenuIndex !== idx) {
            this.currentPageReference = {
                ...this.currentPageReference,
                state: state,
            };
            this[NavigationMixin.Navigate](this.currentPageReference);
            document.title = 'Financial Profile: '+this.menuItems[idx].label;
        }
    }

    /* ******************************************************************************** */

    /**
     * retrieve the user's profile data from the org imperatively
     */
    getFinancialProfileQuestionnaire() {
        this.getPersonalInfo();
        this.getDependents();
        this.getEmployments();
        this.getEmploymentsForCoClient();
        this.getGoals();
        this.getIncomeExpenses();
        this.getFinancialAccounts();
        this.getAssets();
        this.getInsurance();
    }
    // personal info (main record)
    getPersonalInfo() {
        getFinancialProfilePersonalInfoForCurrentUser()
        .then(result => {
            if (this.debug) console.log('personal info:', result);
            this.finProfile = { ...result };
        })
        .catch(error => {
            console.error(error);
        });
    }
    // related dependents
    getDependents() {
        getFinancialProfileDependentsForCurrentUser()
        .then(result => {
            if (this.debug) console.log('dependents:', result);
            this.finProfileDependents = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    // related employment records
    getEmployments() {
        getFinancialProfileEmploymentsForCurrentUser()
        .then(result => {
            if (this.debug) console.log('employers:', result);
            this.finProfileEmployers = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getEmploymentsForCoClient() {
        getFinancialProfileEmploymentsForCoClient()
        .then(result => {
            if (this.debug) console.log('co-client employers:', result);
            this.finProfileCoClientEmployers = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getGoals() {
        getFinancialProfileGoalsForCurrentUser()
        .then(result => {
            if (this.debug) console.log('goals:', result);
            this.finProfileGoals = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getIncomeExpenses() {
        getFinancialProfileIncomeExpensesForBoth()
        .then(result => {
            if (this.debug) console.log('income/expenses:', result);
            this.finProfileIncomeExpenses = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getFinancialAccounts() {
        getFinancialProfileFinancialAccountsForCurrentUser()
        .then(result => {
            if (this.debug) console.log('financial accounts:', result);
            this.finProfileFinancialAccounts = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getAssets() {
        getFinancialProfileAssetsLiabilitiesForCurrentUser()
        .then(result => {
            if (this.debug) console.log('assets:', result);
            this.finProfileAssets = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }
    getInsurance() {
        getFinancialProfileInsurancePoliciesForCurrentUser()
        .then(result => {
            if (this.debug) console.log('insurance:', result);
            this.finProfileInsurance = [...result];
        })
        .catch(error => {
            console.error(error);
        });
    }

    /* ******************************************************************************** */

    /**
     * store temp data from the child components pending save to the org
     * @param {*} event
     */
    handleSaveTempData(event) {
        const addQuestionnaireIdToObject = function(obj) {
            return { ...obj, Financial_Profile__c: this.finProfile.Id };
        };
        if (event.detail.personalInfo) // single object
            this.tempData = { ...this.tempData, ...event.detail.personalInfo };
        if (event.detail.coClient) // single object
            this.tempCoClient = addQuestionnaireIdToObject.call(this,event.detail.coClient);
        if (event.detail.employers) // array of objects
            this.tempEmployers = event.detail.employers.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
        if (event.detail.dependents)
            this.tempDependents = event.detail.dependents.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
        if (event.detail.goals)
            this.tempGoals = event.detail.goals.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
        if (event.detail.incomeExpenses) {
            this.tempIncomeExpenses = event.detail.incomeExpenses.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
            this.tempIncomeExpenseType = event.detail.incomeExpenseType || this.tempIncomeExpenses[0].Type__c;
        }
        if (event.detail.financialAccounts) {
            this.tempFinancialAccounts = event.detail.financialAccounts.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
            this.tempFinancialAccountsType = event.detail.financialAccountsType || this.tempFinancialAccounts[0].Type__c;
        }
        if (event.detail.assets) {
            this.tempAssets = event.detail.assets.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
            this.tempAssetsType = event.detail.assetsType || this.tempAssets[0].Type__c;
        }
        if (event.detail.insurances) {
            this.tempInsurance = event.detail.insurances.map(i => {
                if (Number.isInteger(i.Id)) delete i.Id;
                return addQuestionnaireIdToObject.call(this,i);
            });
            this.tempInsuranceType = event.detail.insuranceType || this.tempInsurance[0].Type__c;
        }
    }

    /**
     * save data up to the org
     * @param {*} str - informational text, not saved to org
     */
    saveData(str) {
        if (this.debug) console.log('saveData:',str);
        if (this.tempData) {
            const updatedData = { ...this.finProfile, ...this.tempData };
            this.updateFinProfile(updatedData);
            this.tempData = undefined;
        }
        if (this.tempCoClient) {
            this.updateFinProfileCoClient(this.tempCoClient);
            this.tempCoClient = undefined;
        }
        if (this.tempDependents) {
            this.updateFinProfileDependents(this.tempDependents);
            this.tempDependents = undefined;
        }
        if (this.tempEmployers) {
            this.updateFinProfileEmployers(this.tempEmployers);
            this.tempEmployers = undefined;
        }
        if (this.tempGoals) {
            this.updateFinProfileGoals(this.tempGoals);
            this.tempGoals = undefined;
        }
        if (this.tempIncomeExpenses) {
            this.updateFinProfileIncomeExpenses(this.tempIncomeExpenses,this.tempIncomeExpenseType);
            this.tempIncomeExpenses = undefined;
            this.tempIncomeExpenseType = undefined;
        }
        if (this.tempFinancialAccounts) {
            this.updateFinProfileFinancialAccounts(this.tempFinancialAccounts,this.tempFinancialAccountsType);
            this.tempFinancialAccounts = undefined;
            this.tempFinancialAccountsType = undefined;
        }
        if (this.tempAssets) {
            this.updateFinProfileAssets(this.tempAssets,this.tempAssetsType);
            this.tempAssets = undefined;
            this.tempAssetsType = undefined;
        }
        if (this.tempInsurance) {
            this.updateFinProfileInsurance(this.tempInsurance,this.tempInsuranceType);
            this.tempInsurance = undefined;
            this.tempInsuranceType = undefined;
        }
    }

    /**
     * call backend method to update Financial Profile
     * @param {*} data - data object
     */
    updateFinProfile(data) {
        delete data.Co_Client_Contact__r; // co-client data is saved separately
        if (this.debug) console.log('updateFinProfile data:',JSON.parse(JSON.stringify(data)));
        this.finProfile = { ...this.finProfile, ...data };
        // save using backend method
        saveFinancialProfile({ questionnaire: data })
        .then(result => {
            if (result) {
                showToast('Success', 'Financial profile has been updated', 'success');
                // refresh the data from the org
                if (this.debug) console.log('saveFinancialProfile result:', result);
                this.finProfile = { ...this.finProfile, ...result }; // result DOES NOT include Co_Client_Contact__r, so we must merge
                if (this.debug) console.log('this.finProfile:', JSON.parse(JSON.stringify(this.finProfile)));
            } else {
                showToast('Error updating financial profile', 'changes not saved', 'error');
                this.getPersonalInfo();
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating financial profile', error.body.message, 'error');
            this.getPersonalInfo();
        });
    }

    /**
     * call backend method to update co-client data
     * @param {*} data  - data object
     */
    updateFinProfileCoClient(data) {
        if (this.debug) console.log('updateFinProfileCoClient data:',JSON.parse(JSON.stringify(data)));
        // reorganize the data using Contact field names
        const newData = {
            Id: data.Id,
            FirstName: data.First_Name__c,
            MiddleName: data.Middle_Initial__c,
            LastName: data.Last_Name__c,
            Suffix: data.Suffix__c,
            Birthdate: data.Date_of_Birth__c,
            
            MailingStreet: data.Street__c,
            MailingCity: data.City__c,
            MailingState: data.State__c,
            MailingPostalCode: data.PostalCode__c,

            WEG_Business_Email__c: data.Business_Email__c,
            WEGP1_PersonalEmail__c: data.Personal_Email__c,
            WEGP1_OtherEmail__c: data.Other_Email__c,

            Phone: data.Phone__c, // mobile
            HomePhone: data.Home_Phone__c,
            AssistantPhone: data.Work_Phone__c,
        };
        this.finProfile.Co_Client_Contact__r = { ...this.finProfile.Co_Client_Contact__r, ...newData };
        saveFinancialProfileCoClient({ coClient: newData })
        .then(result => {
            if (result) {
                if (this.debug) console.log('saveFinancialProfileCoClient result:', result);
                showToast('Success', 'Co-client has been updated', 'success');
                // refresh the data from the org
                this.finProfile.Co_Client_Contact__r = { ...this.finProfile.Co_Client_Contact__r, ...result };
                this.finProfile.Co_Client_Contact__c = result.Id;
                if (this.debug) console.log('this.finProfile:', JSON.parse(JSON.stringify(this.finProfile)));
            } else {
                showToast('Error updating co-client', 'changes not saved', 'error');
                this.getPersonalInfo(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating co-client', error.body.message, 'error');
            this.getPersonalInfo(); // refresh current data from org
        });
}

    /**
     * trigger backend method to update Financial Profile Dependent
     * @param {*} data - array of data objects
     */
    updateFinProfileDependents(data) {
        this.finProfileDependents = [...data];
        saveFinancialProfileDependents({ dependents: JSON.stringify(data) }) // BED was returning errors when the array wasn't stringified -- martin.blase
        .then(result => {
            if (result) {
                showToast('Success', 'Dependents have been updated', 'success');
                // refresh the data from the org
                this.finProfileDependents = [...result];
            } else {
                showToast('Error updating dependents', error.body.message, 'error');
                this.getDependents(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating dependents', 'changes not saved', 'error');
            this.getDependents(); // refresh current data from org
        });
    }

    /**
     * trigger backend method to update Financial Profile Employement
     * @param {*} data - array of data objects
     */
    updateFinProfileEmployers(data) {
        if (data[0] && this.finProfile.Co_Client_Contact__c===data[0].Owner__c) {
            this.finProfileCoClientEmployers = [...data];
        } else {
            this.finProfileEmployers = [...data];
        }
        //const dataCombined = [...this.finProfileEmployers, ...this.finProfileCoClientEmployers];
        // save the combined data1
        saveFinancialProfileEmployments({ employments: JSON.stringify(data) })
        .then(result => {
            if (result) {
                showToast('Success', 'Employers have been updated', 'success');
                // refresh the data from the org
                if (result[0] && this.finProfile.Co_Client_Contact__c===result[0].Owner__c) {
                    this.finProfileCoClientEmployers = [...result];
                } else {
                    this.finProfileEmployers = [...result];
                }
            } else {
                showToast('Error updating employers', error.body.message, 'error');
                this.getEmployments(); // refresh current data from org
                this.getEmploymentsForCoClient();
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating employers', error.body.message, 'error');
            this.getEmployments(); // refresh current data from org
            this.getEmploymentsForCoClient();
        });
    }

    /**
     * trigger backend method to update Financial Profile Dependent
     * @param {*} data - array of data objects
     */
    updateFinProfileGoals(data) {
        this.finProfileGoals = [...data];
        saveFinancialProfileGoals({ goals: JSON.stringify(data) })
        .then(result => {
            if (result) {
                showToast('Success', 'Goals have been updated', 'success');
                // refresh the data from the org
                this.finProfileGoals = [...result];
            } else {
                showToast('Error updating goals', error.body.message, 'error');
                this.getGoals(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating goals', 'changes not saved', 'error');
            this.getGoals(); // refresh current data from org
        });
    }

    /**
     * trigger backend method to update Financial Profile Income/Expenses
     * @param {*} data - array of data objects
     */
     updateFinProfileIncomeExpenses(data) {
        const dataType = this.tempIncomeExpenseType; // additional parameter needed for BED method
        this.setFinProfileIncomeExpenses(dataType,data);
        saveFinancialProfileIncomeExpenses({ incomeExpenses: JSON.stringify(data), type: dataType })
        .then(result => {
            if (result) {
                showToast('Success', 'Income/expenses have been updated', 'success');
                // refresh the data from the org
                this.setFinProfileIncomeExpenses(dataType,result);
                //this.finProfileIncomeExpenses = [...result];
            } else {
                showToast('Error updating income/expenses', error.body.message, 'error');
                this.getIncomeExpenses(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating income/expenses', 'changes not saved', 'error');
            this.getIncomeExpenses(); // refresh current data from org
        });
    }

    /**
     * trigger backend method to update Financial Profile Financial Accounts
     * @param {*} data - array of data objects
     */
     updateFinProfileFinancialAccounts(data) {
        const dataType = this.tempFinancialAccountsType; // additional parameter needed for BED method
        this.setFinProfileFinancialAccounts(dataType,data);
        saveFinancialProfileFinancialAccounts({ financialAccounts: JSON.stringify(data), type: dataType })
        .then(result => {
            if (result) {
                showToast('Success', 'Financial accounts have been updated', 'success');
                // refresh the data from the org
                this.setFinProfileFinancialAccounts(dataType,result);
            } else {
                showToast('Error updating financial accounts', error.body.message, 'error');
                this.getFinancialAccounts(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating financial accounts', 'changes not saved', 'error');
            this.getFinancialAccounts(); // refresh current data from org
        });
    }

    /**
     * trigger backend method to update Financial Profile Assets
     * @param {*} data - array of data objects
     */
     updateFinProfileAssets(data) {
        const dataType = this.tempAssetsType; // additional parameter needed for BED method
        this.setFinProfileAssets(dataType,data);
        saveFinancialProfileAssets({ assets: JSON.stringify(data), type: dataType })
        .then(result => {
            if (result) {
                showToast('Success', 'Assets/liabilities have been updated', 'success');
                // refresh the data from the org
                this.setFinProfileAssets(dataType,result);
            } else {
                showToast('Error updating assets/liabilities', error.body.message, 'error');
                this.getAssets(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating assets/liabilities', 'changes not saved', 'error');
            this.getAssets(); // refresh current data from org
        });
    }

    /**
     * trigger backend method to update Financial Profile Insurance
     * @param {*} data - array of data objects
     */
     updateFinProfileInsurance(data) {
        const dataType = this.tempInsuranceType; // additional parameter needed for BED method
        this.setFinProfileInsurance(dataType,data);
        saveFinancialProfileInsurancePolicies({ insurances: JSON.stringify(data), type: dataType })
        .then(result => {
            if (result) {
                showToast('Success', 'Insurance have been updated', 'success');
                // refresh the data from the org
                this.setFinProfileInsurance(dataType,result);
            } else {
                showToast('Error updating insurance', error.body.message, 'error');
                this.getInsurance(); // refresh current data from org
            }
        })
        .catch(error => {
            console.error(error);
            showToast('Error updating insurance', 'changes not saved', 'error');
            this.getInsurance(); // refresh current data from org
        });
    }
}