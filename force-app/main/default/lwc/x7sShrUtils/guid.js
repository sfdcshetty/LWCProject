/**
 * Copyright (c) 2020.  7Summits Inc. All rights reserved.
 * Source: https://github.com/salesforce/base-components-recipes/blob/master/force-app/main/default/lwc/utilsPrivate/guid.js
 */

export function guid() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }

    return (
        s4() +
        s4() +
        '-' +
        s4() +
        '-' +
        s4() +
        '-' +
        s4() +
        '-' +
        s4() +
        s4() +
        s4()
    );
}