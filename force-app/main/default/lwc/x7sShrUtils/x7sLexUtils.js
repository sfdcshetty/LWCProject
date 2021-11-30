/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

 // `inLexMode` is deprecated and /s/ will be removed from Community URLs in the future. Use `inLex` instead
const inLexMode = () => {
	let lexMode = new RegExp('.*?\/lightning\/', 'g').exec(window.location.href) != null;
	return lexMode;
};

// `inLex` expects the currentPageReference object to be passed in as a param, using the following import in your component:
// import { CurrentPageReference } from "lightning/navigation";
const inLex = (currentPageReference) => {
	//return currentPageReference.type && currentPageReference.type.indexOf('standard__') !== -1;
	// TODO : temporary bypass as page reference is not reliable for our applications.
	return inLexMode();
}

export {
	inLexMode,
	inLex
};