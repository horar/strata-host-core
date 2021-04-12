import Qt.labs.settings 1.1

Settings {
    category: "Login";
    property bool rememberMe: false;
    property string token: '';
    property string first_name: '';
    property string last_name: '';
    property string user: '';

    function clear () {
        token = ""
        first_name = ""
        last_name = ""
        user = ""
    }
}
