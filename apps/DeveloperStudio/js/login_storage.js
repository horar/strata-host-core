/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

// @f populateModelFromSaved
// convert saved JSON array of names to QML::ListModel
//
function populateSavedUsernames(model, saved_logins) {
    model.clear()
    var user_names = JSON.parse(saved_logins)
    user_names.forEach( function(v) {
        if( checkValid(v) ) {
            model.append({"name":v})
        }
    });
}

// @f saveSessionLogins
// @b merge current session and saved logins into a single
//   JSON string to be saved
// returns
//
function saveSessionUsernames(model, saved_logins) {

    // flatten session logins from {"name":""} to array of ["name1","name2" ... ]
    var session_logins = modelToJSON(model)
    var session_logins_flat = [];
    session_logins.forEach(function(v) {
        if( checkValid(v.name) ) {
            session_logins_flat.push(v.name);
        }
    });

    // Note: saved_logins is already in flat array format
    var saved_logins_JSON = JSON.parse(saved_logins)

    // concat saved with current session
    var combined_logins_flat = session_logins_flat.concat(saved_logins_JSON);

    // remove duplicates now that it is a flat array eg: ["name1", "name2", "name3"]
    var unique_logins = combined_logins_flat.filter( function(v, i, a) {
        if( a.indexOf(v) === i && checkValid(v) ) {
            return true;
        }
        return false;
    });

    return JSON.stringify(unique_logins)
}

// @f modelToJSON()
// convert QML::ListModel{ListElement} object to JSON object
//
function modelToJSON( model )
{
    var json = [];
    for (var i = 0; i < model.count; ++i) {
        json.push(model.get(i));
    }
    return json;
}

function checkValid( value )
{
    return value !== "" && typeof value !== "undefined" && value !== null;
}
