/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 */

/**
 * Simple date formatter
 * @param date
 * @param params
 * @returns {string}
 */
export function formatDate(date, params) {
    let options = {
        weekday: 'short',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZone: 'America/Chicago',
        timeZoneName: 'short',
    };

    if( params ) {
        // options = Object.assign( options, params ); // update options with params
        options = params; // replace all options with params
    }

    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleString
    return new Date( date ).toLocaleString( 'en-US', options );
}