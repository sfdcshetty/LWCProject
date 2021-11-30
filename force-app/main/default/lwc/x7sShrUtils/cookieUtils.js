/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * Cookie getter
 * @param cookieKey
 * @returns {string}
 */
export function getCookie(cookieKey) {
    let cookieName = `${cookieKey}=`;
    let cookieArray = document.cookie.split(';');

    for (let cookie of cookieArray) {
        while (cookie.charAt(0) === ' ') {
            cookie = cookie.substring(1, cookie.length);
        }
        if (cookie.indexOf(cookieName) === 0) {
            return cookie.substring(cookieName.length, cookie.length);
        }
    }
}

/**
 * Cookie setter
 * @param cookieKey
 * @param cookieValue
 * @param expirationDays
 */
export function setCookie(cookieKey, cookieValue, expirationDays) {
    let expiryDate = '';

    if (expirationDays) {
        const date = new Date();
        date.setDate(date.getDate() + expirationDays);
        expiryDate = `; expires=" ${date.toUTCString()}`;
    }

    document.cookie = `${cookieKey}=${cookieValue || ''}${expiryDate}; path=/`;
}