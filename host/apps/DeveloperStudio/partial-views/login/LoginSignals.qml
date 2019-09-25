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
    signal loginResult(string result)
    // [TODO][prasanth]: jwt should be created/stored in the HCS.
    // For now, jwt will be obtained in the UI and then sent to HCS.
    signal loginJWT(string jwt_string)

    /*
      Registration signals
    */
    signal registrationResult(string result)

    /*
      Password reset signals
    */
    signal resetResult(string result)
}
