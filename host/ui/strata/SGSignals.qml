import QtQuick 2.0

/*
  Global container for emitting signals in Javascript
*/
Item {
    /*
      Authentication signals
    */
    signal loginResult(bool result)
    // [TODO][prasanth]: jwt should be created/stored in the HCS.
    // For now, jwt will be obtained in the UI and then sent to HCS.
    signal loginJWT(string jwt_string)
}
