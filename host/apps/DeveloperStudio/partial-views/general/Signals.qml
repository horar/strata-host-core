import QtQuick 2.0

/*
  Global container for emitting signals in Javascript
*/
Item {
    id: signals

    /*
      General connection signals
    */
    signal connectionStatus(int status)

    /*
      Authentication signals
    */
    // [TODO][prasanth]: jwt should be created/stored in the HCS.
    // For now, jwt will be obtained in the UI and then sent to HCS.
    signal loginResult(string result)

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
    signal profileUpdateResult(string result)

    /*
      Change Password Signals
    */
    signal changePasswordResult(string result)

    /*
      Get Profile Signals
    */
    signal getProfileResult(string result, var user)
    /*
      Signal for changing auth server to test auth server via debug bar
    */
    signal serverChanged()
    /*
      Feedback result signals
    */
    signal feedbackResult(string result)

}