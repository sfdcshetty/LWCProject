/**
 * Created by karolbrennan on 4/14/21.
 */

import { LightningElement, api, track } from "lwc";

export default class X7SDocumentUploader extends LightningElement {

  @track pendingFiles = [];

  handleFilesChange(event){
    let pendingFiles = event.target.files;
    console.log("Files changed: ", pendingFiles);
    if(pendingFiles.length > 0) {
      for(let i = 0; i < pendingFiles.length; i++){
        this.pendingFiles.push(pendingFiles[i]);
      }
    }
  }

  get showPendingFiles() {
    return this.pendingFiles.length > 0;
  }

  get fileInputClasses(){
    return this.showPendingFiles ? 'slds-m-bottom_large short-dropper' : 'slds-m-bottom_large long-dropper';
  }

  get ulPoints() {
    let points = [];
    if (UL_POINT1) {
      points.push({key: 'point1', point: UL_POINT1});
    }
    if (UL_POINT2) {
      points.push({key: 'point2', point: UL_POINT2});
    }
    if (UL_POINT3) {
      points.push({key: 'point3', point: UL_POINT3});
    }
    if (UL_POINT4) {
      points.push({key: 'point4', point: UL_POINT4});
    }
    if (UL_POINT5) {
      points.push({key: 'point5', point: UL_POINT5});
    }
    if (UL_POINT6) {
      points.push({key: 'point6', point: UL_POINT6});
    }
    return points;
  }
}