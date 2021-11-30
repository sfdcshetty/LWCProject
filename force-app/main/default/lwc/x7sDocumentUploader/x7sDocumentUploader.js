/**
 * Created by karolbrennan on 4/14/21.
 */

import { LightningElement, api, track } from "lwc";
import ICONS from '@salesforce/resourceUrl/wegIcons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {fireEvent} from 'c/pubsub';

export default class X7SDocumentUploader extends LightningElement {
  // tracked variables for pending file list, generated IDs used for ensuring unique randomized IDs
  // loader and showing success message
  @track pendingFiles = [];
  @track generatedIDs = [];
  @track isLoading = false;
  @track messageValue = '';
  @track hideSuccessMessage = false;
  @track errorMessage = '';
  @track trigger = false;
  @api maxFileSize = (1048576 * 25); // default to 25MB
  // 1MB = 1048576
  @api faqLink;
  @api inModal = false;
  @api successIcon = ICONS + '/icon_document-upload-success.svg';
  @api failIcon = ICONS + '/icon_document-upload-error.svg';
  @api warningIcon = ICONS + '/icon_document-upload-warning.svg';

  // Temporary hard coded document types. @todo these will come from the back end
  @api documentTypes = [
    { label: "Account Statements", value: "Account Statements" },
    { label: "Tax Returns", value: "Tax Returns" },
    { label: "Estate Documents", value: "Estate Documents" },
    { label: "Other", value: "Other" },
  ];

  /**
   * Generates a random file id used to identify pending files to be uploaded for the UX
   * of renaming and deleting files
   * @returns {string}
   */
  generateRandomId() {
    console.log('generateRandomID...');
    let id;
    do {
      id = "file" + Math.floor(Math.random() * 10000).toString();
    } while (this.generatedIDs.includes(id));
    this.generatedIDs.push(id);
    return id;
  }

  formatBytes(bytes, decimals = 2) {
    console.log('formatBytes...');
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }

  /**
   * Returns the file icon that is associated with the given filetype
   * @param fileType
   * @returns {string}
   */
  getFileIcon(fileType) {
    console.log('getFileIcon...');
    let icon;
    switch (fileType) {
      case "application/x-msdownload":
        icon = "doctype:exe";
        break;
      case "application/pdf":
        icon = "doctype:pdf";
        break;
      case "image/jpeg":
        icon = "doctype:image";
        break;
      case "application/msword":
      default:
        icon = "doctype:word";
        break;
    }
    return icon;
  }

  /**
   * Handles the file input, this will format the file for use in the UI
   * and send it to a list of files that will be uploaded to the server
   * when the user clicks on the upload button
   * @param event
   */
  handleFilesChange(event) {
    console.log('handleFilesChange...');
    this.errorMessage = '';
    Array.from(event.target.files).forEach((file) => {
      
      if(this.checkFileType(file.name) === false){
        // check if file type is allowed
        if(event.target.files.length > 1) {
          this.errorMessage = 'One or more of your files are of an unaccepted type and will not be uploaded.'
        } else {
          this.errorMessage = 'Sorry, the selected file type is not allowed and will not be uploaded.';
        }
      } else if(file.size > this.maxFileSize) {
        // check if file size exceeds max size
        if(event.target.files.length > 1) {
          this.errorMessage = 'One or more of your exceeds the maximum allowed file size, please ensure your file is under ' + this.formatBytes(this.maxFileSize)
        } else {
          this.errorMessage = 'Your file exceeds the maximum allowed file size, please ensure your file is under ' + this.formatBytes(this.maxFileSize);
        }
      } else {
        
        // configure fileData
        let fileData = {
          id: this.generateRandomId(),
          editing: false,
          name: file.name,
          icon: this.getFileIcon(file.type)
        };
        fileData.file = file;
        //fileData.file = new File([file], file.name);
        this.pendingFiles.push(fileData);
      }
    });
  }

  checkFileType(file){
    console.log('checkFileType...');
    let allowed = false;
    let allowedTypes = ['.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.pdf', '.txt', '.csv', '.jpg', '.jpeg', '.gif', '.epub'];
    allowedTypes.forEach(type => {
      if(file.endsWith(type)){
        allowed = true;
      }
    })
    return allowed;
  }

  /**
   * Handler for the Upload button on the bottom right of the UI
   * @param event
   */
  handleFileUpload(event) {
    console.log('handleFileUpload....');
    if(this.pendingFiles){
      console.log('this.pendingFiles Janavi log', this.pendingFiles.length);
      if(this.pendingFiles.length > 10){
        this.dispatchToastEvent('Fail', 'You can upload only 10 files at a time.!', 'error');
      }
      else{
        const uploadEvent = new CustomEvent ('uploadfiles', {
          detail: {
            files : this.pendingFiles,
            message: this.messageValue
          }
        });
        console.log ('Dispatch from LWC');
        this.dispatchEvent(uploadEvent);
      }
    }
  }

  @api handleUpdateVault(){
    console.log('handleUpdateVault...');
    fireEvent('updatevault', 'updatevault');
  }

  /**
   * Handles the message field
   * @param event
   */
  handleMessageChange(event){
    console.log('handleMessageChange...');
    this.messageValue = event.target.value;
  }

  /**
   * Handles changing the file name that will be uploaded
   * @param event
   */
  handleFileNameChange(event) {
    console.log('handleFileNameChange...');
    let fileId = event.target.dataset.id;
    this.changeFileValue(fileId, "name", event.target.value);
  }

  /**
   * Blur event to close the editable view of the file name
   * @param event
   */
  handleFinalizeNameChange(event) {
    console.log('handleFinalizeNameChanget...');
    let fileId = event.target.dataset.id;
    this.changeFileValue(fileId, "editing", false);
  }

  /**
   * Handles the file type drop down
   * @param event
   */
  handleFileTypeChange(event) {
    console.log('handleFileTypeCHange...');
    let fileId = event.target.dataset.id;
    this.changeFileValue(fileId, "type", event.target.value);
  }

  /**
   * Makes the associated line editable (currently just makes the name editable)
   * @param event
   */
  handleMakeEditable(event) {
    console.log('handleMakeEditable...');
    let fileId = event.target.dataset.id;
    this.changeFileValue(fileId, "editing", true);
  }

  /**
   * Handles removing of the specified file from the pending file list
   * @param event
   */
  handleRemoveFile(event) {
    console.log('handleRemoveFile...');
    let fileId = event.target.dataset.id;
    let newFileList = [];
    JSON.parse(JSON.stringify(this.pendingFiles)).forEach((file) => {
      if (file.id !== fileId) {
        let fileData = file;
        // Recreate the blob on every file to ensure it stays in place
        fileData.file = new File([file.file], file.name);
        newFileList.push(file);
      } else {
        let generatedIdIndex = this.generatedIDs.indexOf(fileId);
        this.generatedIDs.splice(generatedIdIndex, 1);
      }
    });
    this.pendingFiles = newFileList;
  }

  /**
   * Changes the value of the file data in the pending file list
   * @param fileId  id of the file you wish to change
   * @param property  property you wish to change
   * @param newValue  new value to be assigned to property
   */
  changeFileValue(fileId, property, newValue) {
    console.log('changeFileValue....');
    let newFileList = [];
    let fileDetails = this.pendingFiles;
    for (var i = 0; i < fileDetails.length; i++) {
       console.log (fileDetails[i].file);
       let fileData = fileDetails[i];
       if (fileDetails[i].id === fileId) {
         fileData[property] = newValue;
       }
       let newfileName = property === 'name' ? newValue : fileDetails[i].name;
       const newFile = new File([fileDetails[i].file], newfileName, {type: fileDetails[i].type});
       fileData.file = newFile; //fileDetails[i].file;
       newFileList.push(fileData);
    }

    /*JSON.parse(JSON.stringify(this.pendingFiles)).forEach((file) => {
      let fileData = file;
      if (file.id === fileId) {
        file[property] = newValue;
      }
      // Recreate the blob on every file to ensure it stays in place
      fileData.file = new File([file.file], property === 'name' ? newValue : file.name);
      newFileList.push(fileData);
    });
    */
    console.log (newFileList);
    this.pendingFiles = newFileList;
  }

  /**
   * Resets the upload form and hides the success message
   */
  handleUploadMore() {
    console.log('handleUploadMore....');
    this.errorMessage = '';
    this.pendingFiles = [];
    this.generatedIDs = [];
    this.messageValue = '';
    // Reset parent component
    const compResetEvent = new CustomEvent ('compreset', {
      detail: {}
    });
    this.dispatchEvent(compResetEvent);
  }

  /**
   * Formats a date to show the associated time in HH:MM:AMPM format
   * @param date
   * @returns {string}
   */
  formatAMPM(date) {
    console.log('formatAMPM...');
    let hours = date.getHours();
    let minutes = date.getMinutes();
    let ampm = hours >= 12 ? "PM" : "AM";
    hours = hours % 12;
    hours = hours ? hours : 12; // the hour '0' should be '12'
    minutes = minutes < 10 ? "0" + minutes : minutes;
    return hours + ":" + minutes + " " + ampm;
  }

  /**
   * Returns the day of the week
   * @param date
   * @returns {string}
   */
  getDayString(date) {
    console.log('getDayString....');
    let days = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];
    return days[date];
  }

  /**
   * Returns the month in string format
   * @param date
   * @returns {string}
   */
  getMonthString(date) {
    console.log('getMonthString....');
    let months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[date];
  }

  /** ---------- Getters / Setters ---------- **/
  // Upload status is used to show messages on the front end
  // and show pending files from the aura wrapper component
  @api
  get uploadStatus(){
    return this.status;
  };
  set uploadStatus(value){
    this.status = value;
    this.trigger = !this.trigger;
    if(value.uploading === false){
      fireEvent('updatevault', value);
    }
  }

  /**
   * Determines if the pending file list should display or not
   * @returns {boolean}
   */
  get showPendingFiles() {
    console.log('showPendingFiles....');
    return this.pendingFiles.length > 0;
  }

  /**
   * Returns the class that should be associated with the droppable zone to change its height
   * @returns {string}
   */
  get fileInputClasses() {
    console.log('fileInputClasses....');
    return this.showPendingFiles ? "short-dropper" : "long-dropper";
  }

  /**
   * Gets the current date/time string that is shown upon successful upload.
   * @returns {string}
   */
  get currentDateTime() {
    console.log('currentDateTime...');
    let dateTimeString = "";
    let date = new Date();
    dateTimeString +=
      this.formatAMPM(date) +
      " " +
      this.getDayString(date.getDay()) +
      ", " +
      this.getMonthString(date.getMonth()) +
      " " +
      date.getDate() +
      ", " +
      date.getFullYear();
    return dateTimeString;
  }

  get showSuccessMessage(){
    console.log('showSuccessMessage....');
    console.log('this.uploadStatus.uploading='+this.uploadStatus.uploading);
    console.log('this.uploadStatus.progress='+this.uploadStatus.progress);
    return (this.uploadStatus.uploading === false && this.uploadStatus.progress === 100);
  }

  get allFilesFailed(){
    console.log('allFilesFailed...');
    return this.successFiles.length === 0;
  }

  get hasFailedFiles() {
    console.log('hasFailedFiles....');
    return this.failedFiles.length > 0;
  }

  get failedFiles(){
    console.log('failedFiles....');
    let failedFiles = [];
    if(this.uploadStatus.files.length > 0){
      this.uploadStatus.files.forEach(file => {
        if(file.success === false){
          failedFiles.push(file);
        }
      })
    }
    return failedFiles;
  }

  get successFiles(){
    console.log('successFiles...');
    let successFiles = [];
    if(this.uploadStatus.files.length > 0){
      this.uploadStatus.files.forEach(file => {
        if(file.success === true){
          successFiles.push(file);
        }
      })
    }
    return successFiles;
  }

  get hasError(){
    return this.errorMessage !== '';
  }

  get uploadDisabled(){
    if (this.uploadStatus.uploading) return true;

    console.log('uploadDisabled....');
    let returnValue = false;

    // If the pending files list doesn't have any files, return true
    if(this.pendingFiles.length === 0){
      returnValue = true;
    }

    if(this.pendingFiles.length > 0) {
      // If any of the pending files is missing the file type, disable the button
      this.pendingFiles.forEach(file => {
        // if the file name, or type is missing, disable the button.
        if((file.name === undefined || !file.name) || (file.type === undefined || !file.type)) {
          returnValue = true;
        }
      });
    }

    return returnValue;
  }

  get primaryClasses(){
    return this.inModal === true ? 'x7sFileUploader slds-is-relative inModal' : 'x7sFileUploader' +
        ' slds-is-relative slds-p-vertical_large';
  }

  get masterColumnsMedSizes() {
    let returnValue = {
      left: 4,
      right: 8
    }
    if(this.inModal === true){
      returnValue.right = 12;
      returnValue.left = 12;
    }
    return returnValue;
  }

  get pendingFilesToDisplay(){
    let pendingFiles = [];
    this.pendingFiles.forEach(file => {
      if(file.name === undefined || !file.name) {
        file.nameClassList = 'slds-has-error';
      } else {
        file.nameClassList = '';
      }
      if (file.type === undefined || !file.type) {
        file.typeClassList = 'slds-has-error';
      } else {
        file.typeClassList = '';
      }
      pendingFiles.push(file);
    })
    return pendingFiles;
  }


  dispatchToastEvent(title, message, variant) {
    console.log('dispatchToastEvent...');
    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }),
    );
  }
}