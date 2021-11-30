/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import {LightningElement, api} from 'lwc';

import uploadUserPhoto from '@salesforce/apex/x7sOnboardingController.uploadUserPhoto';
import updateUserNames from '@salesforce/apex/x7sOnboardingController.updateUserNames';
import getUserRecord from '@salesforce/apex/x7sOnboardingController.getUserRecord';

export default class X7sOnboardingProfile extends LightningElement {
	
	@api recordId;
	@api regionList;
	@api industryList;
	@api profileHeader;
	@api profileMessage;
	@api profileAction;
	@api user;
	@api error;
	@api buttonColor = "#ff8201";
	@api showFirstName;
	@api showLastName;
	@api firstNameLabel;
	@api lastNameLabel;
	@api showTitle;
	@api titleLabel;
	@api showCompany;
	@api companyLabel;
	@api showEmail;
	@api emailLabel;
	@api showMobile;
	@api mobileLabel;
	@api showNickname;
	@api nicknameLabel;
	@api dropFileLabel;
	
	/* TODO: Dynamic query builder for custom fields
		@api showRegion;
		@api showIndustry;
	*/
	
	@api showAboutMe;
	@api aboutMeLabel;
	@api showAvatarUpload;
	@api acceptableAvatarFileTypes;
	@api nextButtonLabel;
	@api backButtonLabel;
	
	get avatar() {
		return (this.showAvatarUpload || this.acceptableAvatarFileTypes);
	}
	
	connectedCallback() {
		this.getUpdatedUserRecord();
	}
	
	handleUploadFinished(evt) {
		let uploadedFiles = evt.detail.files;
		//console.log('DD: JSON>> ', JSON.stringify(uploadedFiles[0]));
		
		let documentId = uploadedFiles[0].documentId;
		let fileName = uploadedFiles[0].name;
		
		this.setPhoto(documentId, fileName);
	}
	
	goToNext() {
		this.updateName();
		
		if ((this.user.FirstName === null || this.user.FirstName === '') ||
			(this.user.LastName === null || this.user.LastName === '')) {
			this.error = 'Values are required for First Name, Last Name';
		} else if (this.user.Email === null || this.user.Email === '') {
			this.error = 'Values are required for Email';
		} else {
			const profileClick = new CustomEvent('profileclick', {
				detail: {
					message: '3',
					slide: 'Profile'
				}
			});
			this.dispatchEvent(profileClick);
		}
	}
	
	goBack() {
		const profileBackClick = new CustomEvent('profilebackclick', {
			detail: {
				message: '1',
				slide: ''
			}
		});
		this.dispatchEvent(profileBackClick);
		
	}
	
	onFirstNameCommit(event) {
		this.user.FirstName = event.target.value;
	}
	
	onLastNameCommit(event) {
		this.user.LastName = event.target.value;
	}
	
	onTitleCommit(event) {
		this.user.Title = event.target.value;
	}
	
	onCompanyNameCommit(event) {
		this.user.CompanyName = event.target.value;
	}
	
	onEmailCommit(event) {
		this.user.Email = event.target.value;
	}
	
	onMobilePhoneCommit(event) {
		this.user.MobilePhone = event.target.value;
	}
	
	onCommunityNicknameCommit(event) {
		this.user.CommunityNickname = event.target.value;
	}
	
	onAboutMeCommit(event) {
		this.user.AboutMe = event.target.value;
	}
	
	setPhoto(documentId, fileName) {
		uploadUserPhoto({
			documentId: documentId,
			filename: fileName
		})
			.then(result => {
				console.log('success - setPhoto' + result);
			})
			.catch(error => {
				console.error('setPhoto Failed : ' + JSON.stringify(error));
			});
	}
	
	updateName() {
		updateUserNames({currentUser: this.user})
			.then(result => {
				console.log('Success - updateName');
			})
			.catch(error => {
				console.error('updateName Failed : ' + JSON.stringify(error));
			});
	}
	
	getUpdatedUserRecord() {
		getUserRecord()
			.then(result => {
				this.user = result;
				this.recordId = result.Id;
			})
			.catch(error => {
				console.error('getUpdatedUserRecord Failed : ' + JSON.stringify(error));
			});
	}
}