import getwrapperInfo from "@salesforce/apex/x7s_EstatePlanningController.getHouseholdWithEstateInformation";
import saveEstateUpdates from "@salesforce/apex/x7s_EstatePlanningController.saveEstateInformation";

import { wire, api, track, LightningElement } from "lwc";
import { showToast } from "c/x7sShrUtils";

export default class X7sWegEstatePlanningSelection extends LightningElement {
  debug = true;
  showSaving = false;
  debounceTimer;
  editEstatePlanningChecklist = "Save";
  cancelEstatePlanningChecklist = "Cancel"
  disableButtons = true;
  showSpinner = false;

  @api debounceTime = 2500;
  @api customHeader = "Estate Planning";
  @api editEstatePlanningChecklist = "Save";
  @api cancelEstatePlanningChecklist = "Cancel";

  @api willExists = {
    fieldPath: "WillExists",
    fieldLabel: "Do you have a will?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api trustExists = {
    fieldPath: "TrustExists",
    fieldLabel: "Do you have a trust?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api revocableTrustExists = {
    fieldPath: "TrustExists",
    fieldLabel: "Do you have a revocable trust?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api irrevocableTrustExists = {
    fieldPath: "TrustExists",
    fieldLabel: "Do you have an irrevocable trust?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api powerOfAttorney = {
    fieldPath: "PowerOfAttorney",
    fieldLabel: "Do you have a durable power of attorney?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api livingWillExists = {
    fieldPath: "LivingWill",
    fieldLabel: "Do you have a living will/health care directive?",
    primaryValue: undefined,
    secondaryValue: undefined
  };

  @api altQuestion1 = "";
  @api altQuestion2 = "";
  @api altQuestion3 = "";
  @api altQuestion4 = "";
  @api altQuestion5 = "";
  @api altQuestion6 = "";
  @api altQuestion7 = "";
  @api altQuestion8 = "";

  @track finProfile = {};
  @track wrapper = {};

  /*trustOptions = [{label: 'None', value: 'None'},
        {label: 'Revocable', value: 'Revocable'},
        {label: 'Irrevocable', value: 'Irrevocable'}
        ];*/
  /*get revocableTrustOptions(){
        return[
        {label: 'Yes', value: 'Yes'},
        {label: 'No', value: 'No'},
    ]}
    get irrevocableTrustOptions(){
        return [
        {label: 'Yes', value: 'Yes'},
        {label: 'No', value: 'No'},
    ]}*/

  connectedCallback() {
    // this.getPersonalInfo(); // retrieve the user's current data from the org
    this.getHouseholdInfo();
  }

  /**
   * get first name of the co-client, if there is one
   */
  get primaryName() {
    // if (this.finProfile && this.finProfile.Co_Client_Contact__r)
    //     return this.finProfile.Co_Client_Contact__r.FirstName;
    if (this.wrapper) {
      return this.wrapper.primaryName;
    }
  }

  /**
   * get first name of the co-client, if there is one
   */
  get secondaryName() {
    // if (this.finProfile && this.finProfile.Co_Client_Contact__r)
    //     return this.finProfile.Co_Client_Contact__r.FirstName;
    if (this.wrapper) {
      return this.wrapper.secondaryName;
    }
    return;
  }

  getHouseholdInfo() {
    getwrapperInfo()
      .then((result) => {
        if (this.debug) console.log("Household info:", result);
        this.wrapper = { ...result };
        this.willExists.primaryValue = this.wrapper.primaryWillExists;
        this.willExists.secondaryValue = this.wrapper.secondaryWillExists;

        this.trustExists.primaryValue = this.wrapper.primaryTrustExists;

        /*this.revocableTrustExists.primaryValue = this.wrapper.primaryRevocableTrustExists ? 'Yes':'No';
                this.irrevocableTrustExists.primaryValue = this.wrapper.primaryIrrevocableTrustExists ? 'Yes':'No';
                this.revocableTrustExists.secondaryValue = this.wrapper.secondaryRevocableTrustExists ? 'Yes':'No';
                this.irrevocableTrustExists.secondaryValue = this.wrapper.secondaryIrrevocableTrustExists ? 'Yes':'No';*/

        this.revocableTrustExists.primaryValue =
          this.wrapper.primaryRevocableTrustExists;
        this.irrevocableTrustExists.primaryValue =
          this.wrapper.primaryIrrevocableTrustExists;
        this.revocableTrustExists.secondaryValue =
          this.wrapper.secondaryRevocableTrustExists;
        this.irrevocableTrustExists.secondaryValue =
          this.wrapper.secondaryIrrevocableTrustExists;

        this.trustExists.secondaryValue = this.wrapper.secondaryTrustExists;

        this.powerOfAttorney.primaryValue = this.wrapper.primaryPowerOfAttorney;
        this.powerOfAttorney.secondaryValue =
          this.wrapper.secondaryPowerOfAttorney;
        this.livingWillExists.primaryValue =
          this.wrapper.primaryLivingWillExists;
        this.livingWillExists.secondaryValue =
          this.wrapper.secondaryLivingWillExists;
      })
      .catch((error) => {
        console.error(error);
      });
  }

  /*handleChangePicklist(event) {
    let fieldName = event.currentTarget.name;
    console.log(event.detail.value);
    if (fieldName === "primaryTrustExists") {
      this.wrapper.primaryTrustExists = event.detail.value;
    } else if (fieldName === "secondaryTrustExists") {
      this.wrapper.secondaryTrustExists = event.detail.value;
    }
    this.debounceSaveData();
  }*/

  handleChangeCheckbox(event) {
    let fieldName = event.target.dataset.id;
    if (fieldName === "primaryWillExists") {
      this.wrapper.primaryWillExists = event.detail.checked;
    } else if (fieldName === "secondaryWillExists") {
      this.wrapper.secondaryWillExists = event.detail.checked;
    } else if (fieldName === "primaryLivingWillExists") {
      this.wrapper.primaryLivingWillExists = event.detail.checked;
    } else if (fieldName === "secondaryLivingWillExists") {
      this.wrapper.secondaryLivingWillExists = event.detail.checked;
    } else if (fieldName === "primaryPowerOfAttorney") {
      this.wrapper.primaryPowerOfAttorney = event.detail.checked;
    } else if (fieldName === "secondaryPowerOfAttorney") {
      this.wrapper.secondaryPowerOfAttorney = event.detail.checked;
    } else if (fieldName === "primaryRevocableTrustExists") {
      this.wrapper.primaryRevocableTrustExists = event.detail.checked;
    } else if (fieldName === "secondaryRevocableTrustExists") {
      this.wrapper.secondaryRevocableTrustExists = event.detail.checked;
    } else if (fieldName === "primaryIrrevocableTrustExists") {
      this.wrapper.primaryIrrevocableTrustExists = event.detail.checked;
    } else if (fieldName === "secondaryIrrevocableTrustExists") {
      this.wrapper.secondaryIrrevocableTrustExists = event.detail.checked;
    }
    this.disableButtons = false;
    //this.debounceSaveData();
  }

  /*handleRadioChange(event) {
    let fieldName = event.target.dataset.id;
    let radioValue = event.detail.value;
    let trustValue = false;

    if (radioValue == "Yes") {
      trustValue = true;
    } else if (radioValue == "No") {
      trustValue = false;
    }
    console.log("test", fieldName);
    if (fieldName === "primaryRevocableTrustExists") {
      this.wrapper.primaryRevocableTrustExists = trustValue;
    } else if (fieldName === "secondaryRevocableTrustExists") {
      this.wrapper.secondaryRevocableTrustExists = trustValue;
    } else if (fieldName === "primaryIrrevocableTrustExists") {
      this.wrapper.primaryIrrevocableTrustExists = trustValue;
    } else if (fieldName === "secondaryIrrevocableTrustExists") {
      this.wrapper.secondaryIrrevocableTrustExists = trustValue;
    }
    //console.log(event.target.dataset.id, event.detail.value);
    console.log(fieldName, trustValue);
    this.debounceSaveData();
  }*/
  /**
   * automatically save the data to the org after a short amount of time
   * @param {Number} timeout - number of milliseconds to debounce, defaults to 300
   */
  /*debounceSaveData(timeout = 600) {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.saveData();
    }, timeout);
  }*/
  fetchPrefs() {
    this.showSpinner = true;
    getwrapperInfo()
    .then((result) => {
        this.showSpinner = false;
        let myPrefs = result;
        if (this.debug) console.log("myLoadedPrefs", myPrefs);
        this.wrapper = { ...result };
        this.willExists.primaryValue = this.wrapper.primaryWillExists;
        this.willExists.secondaryValue = this.wrapper.secondaryWillExists;

        this.trustExists.primaryValue = this.wrapper.primaryTrustExists;

        /*this.revocableTrustExists.primaryValue = this.wrapper.primaryRevocableTrustExists ? 'Yes':'No';
                this.irrevocableTrustExists.primaryValue = this.wrapper.primaryIrrevocableTrustExists ? 'Yes':'No';
                this.revocableTrustExists.secondaryValue = this.wrapper.secondaryRevocableTrustExists ? 'Yes':'No';
                this.irrevocableTrustExists.secondaryValue = this.wrapper.secondaryIrrevocableTrustExists ? 'Yes':'No';*/

        this.revocableTrustExists.primaryValue =
          this.wrapper.primaryRevocableTrustExists;
        this.irrevocableTrustExists.primaryValue =
          this.wrapper.primaryIrrevocableTrustExists;
        this.revocableTrustExists.secondaryValue =
          this.wrapper.secondaryRevocableTrustExists;
        this.irrevocableTrustExists.secondaryValue =
          this.wrapper.secondaryIrrevocableTrustExists;

        this.trustExists.secondaryValue = this.wrapper.secondaryTrustExists;

        this.powerOfAttorney.primaryValue = this.wrapper.primaryPowerOfAttorney;
        this.powerOfAttorney.secondaryValue =
          this.wrapper.secondaryPowerOfAttorney;
        this.livingWillExists.primaryValue =
          this.wrapper.primaryLivingWillExists;
        this.livingWillExists.secondaryValue =
          this.wrapper.secondaryLivingWillExists;
      })
    .catch((error) => {
        this.showSpinner = false;
        this.error = error;
        if (this.debug) console.log('error', error);
    });
    } 

    handleCancel() {
      this.fetchPrefs();
    }

  /**
   * save data up to the org
   * @param {*} str - informational text, not saved to org
   */
  saveData() {
    if (this.debug) console.log("saving data");
    this.showSpinner = true;
    var parsedWrapper = { ...this.wrapper };
    this.disableButtons = true;
    console.log("WRAPPER-save", JSON.stringify(parsedWrapper));
    this.showSpinner = true;
    saveEstateUpdates({ stringifiedWrapper: JSON.stringify(parsedWrapper) })
      .then((result) => {
        if (this.debug) console.log("Household info:", result);
        this.showSpinner = false;
        showToast(
          "Success",
          "Estate Planning selections have been saved",
          "success"
        );
      })
      .catch((error) => {
        console.error(error);
        showToast(
          "Error updating Estate Planning selections",
          "changes not saved",
          "error"
        );
      });
  }
}