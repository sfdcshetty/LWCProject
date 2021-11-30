import { LightningElement } from 'lwc';
import grabPrefs from '@salesforce/apex/x7sPreferencesController.grabPreferences';
import savePrefs from '@salesforce/apex/x7sPreferencesController.savePreferences';
import { showToast } from 'c/x7sShrUtils';

export default class X7sWegPreferences extends LightningElement {
    debug = false;
    showSpinner = false;
    disableButtons = true;

    myOptions = [];
    myPreferences = {};

    connectedCallback(){
        this.fetchPrefs();
    }

    fetchPrefs() {
        this.showSpinner = true;
        grabPrefs()
        .then((result) => {
            this.showSpinner = false;
            let myPrefs = result;
            if (this.debug) console.log("myLoadedPrefs", myPrefs);
            this.checkBoxes(myPrefs);
        })
        .catch((error) => {
            this.showSpinner = false;
            this.error = error;
            if (this.debug) console.log('error', error);
        });
    }

    checkBoxes(prefs){
        if(prefs.newInsights){
            let targetVal = "[data-id='newsInsights']";
            let newsInsights = this.template.querySelector(targetVal);
            newsInsights.checked = prefs.newInsights;
            this.myPreferences.newInsights = prefs.newInsights;
        }
        if(prefs.profileUpdates){
            let targetVal = "[data-id='updatesToProfile']";
            let updatesToProfile = this.template.querySelector(targetVal);
            updatesToProfile.checked = prefs.profileUpdates;
            this.myPreferences.profileUpdates = prefs.profileUpdates;
        }
        if(prefs.toDos){
            let targetVal = "[data-id='toDoAssignments']";
            let toDoAssignments = this.template.querySelector(targetVal);
            toDoAssignments.checked = prefs.toDos;
            this.myPreferences.toDos = false;
        }d
    }

    selectThisPreference(event){
        this.disableButtons = false;
        /*let thisPrefIncluded = this.myOptions.includes(event.target.value);
        let target = event.target.value
        let targetVal = "[data-id='" + target + "']";
        let myCheckboxIsChecked = this.template.querySelector(targetVal);

        if(myCheckboxIsChecked.checked) {
            if(!thisPrefIncluded) {
                this.myOptions.push(event.target.value);
            }
        }else{
            let myNewPrefs = [];
                for(let i=0; i<this.myOptions.length; i++){
                    if(this.myOptions[i] !== event.target.value){
                        myNewPrefs.push(this.myOptions[i]);
                    }
                } 
            this.myOptions = myNewPrefs;
        }*/
    }

    handleCancel() {
        this.fetchPrefs();
    }

    handleSave(){
        let myUpdatedPrefs = {};
        let targetVal;
        targetVal = "[data-id='newsInsights']";
        let newsInsights = this.template.querySelector(targetVal);
        if(newsInsights.checked === true){ 
            myUpdatedPrefs.newInsights = true;
        }else{
            myUpdatedPrefs.newInsights = false;
        }

        targetVal = "[data-id='updatesToProfile']";
        let updatesToProfile = this.template.querySelector(targetVal);
        if(updatesToProfile.checked === true){ 
            myUpdatedPrefs.profileUpdates = true;
        }else{
            myUpdatedPrefs.profileUpdates = false;
        }

        targetVal = "[data-id='toDoAssignments']";
        let toDoAssignments = this.template.querySelector(targetVal);
        if(toDoAssignments.checked === true){ 
            myUpdatedPrefs.toDos = true;
        }else{
            myUpdatedPrefs.toDos = false;
        }

        this.disableButtons = true;
        this.showSpinner = true;
        console.log('prefs', myUpdatedPrefs);
        savePrefs({userNotification: myUpdatedPrefs})
        .then((result) => {
            this.showSpinner = false;
            console.log(result);
            if (this.debug) console.log('res', result);
            showToast('Success', 'Preferences saved', 'success');
        })
        .catch((error) => {
            this.showSpinner = false;
            this.error = error;
            /* if (this.debug) */ console.error('error', error);
            showToast('Error while saving', error.body ? error.body.message : JSON.stringify(error), 'error');
        });
    }
}