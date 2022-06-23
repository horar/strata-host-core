/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
pragma Singleton

import QtQml 2.8
/*
  Global container for emitting signals in Javascript
*/
QtObject {

    /*
      General connection signals
    */
    signal connectionStatus(int status, int requestId)

    /*
      Authentication signals
    */
    // [TODO][prasanth]: jwt should be created/stored in the HCS.
    // For now, jwt will be obtained in the UI and then sent to HCS.
    signal loginResult(string result)
    signal logout();

    /*
      Registration signals
    */
    signal registrationResult(string result)

    /*
      Password reset signals
    */
    signal resetResult(string result)

    /*
      Token validation signals
    */
    signal validationResult(string result)

    /*
      CLose Acount Signals
    */
    signal closeAccountResult(string result)

    /*
      Update Profile Signals
    */
    signal profileUpdateResult(string result, var updatedProperties)

    /*
      Change Password Signals
    */
    signal changePasswordResult(string result)

    /*
      Get Profile Signals
    */
    signal getProfileResult(string result, var user)

    /*
      Misc Signal for CVC
    */
    signal loadCVC()

    /*
      Privacy Policy Update signal
    */
    signal privacyPolicyUpdate()
}
