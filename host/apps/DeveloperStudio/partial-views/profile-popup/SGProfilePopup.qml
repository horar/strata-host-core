import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import 'qrc:/partial-views'
import 'qrc:/partial-views/login/registration'
import 'qrc:/partial-views/login'
import 'qrc:/js/login_utilities.js' as LoginUtil
import 'qrc:/js/navigation_control.js' as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters

SGStrataPopup {
    id: root

    headerText: NavigationControl.context.first_name[0].toUpperCase() + NavigationControl.context.first_name.slice(1) + "'s Profile"
    modal: true
    closePolicy: Popup.CloseOnEscape
    focus: true
    horizontalPadding: 20
    bottomPadding: 20

    property string firstName: NavigationControl.context.first_name
    property string lastName: NavigationControl.context.last_name
    property string company: "N/A"
    property string jobTitle: "N/A"

    onOpened: {
        basicInfoControls.editing = false
        firstNameColumn.plainText.text = firstName
        lastNameColumn.plainText.text = lastName
        companyControls.editing = false
        companyColumn.plainText.text = company
        jobTitleColumn.plainText.text = jobTitle
        passwordControls.editing = false
        passReqsPopup.close()
    }

    onClosed: {
        alertRect.Layout.preferredHeight = 0
        basicInfoControls.editing = false
        basicInfoControls.resetHeight()
        firstNameColumn.editable = false
        lastNameColumn.editable = false
        companyControls.editing = false
        companyControls.resetHeight()
        companyColumn.editable = false
        jobTitleColumn.editable = false
        passwordControls.editing = false
        passwordControls.resetHeight()
        newPasswordRow.editable = false
        currentPasswordRow.editable = false
        passReqsPopup.close()
        resetFields()
    }

    onFirstNameChanged: firstNameColumn.plainText.text = firstName
    onLastNameChanged: lastNameColumn.plainText.text = lastName
    onCompanyChanged: companyColumn.plainText.text = company
    onJobTitleChanged: jobTitleColumn.plainText.text = jobTitle

    contentItem: Column {
        id: wrapperContainer

        width: mainGrid.width + 50
        anchors.horizontalCenter: parent.horizontalCenter

        SGConfirmationPopup {
            id: confirmDeletePopup

            cancelButtonText: "Cancel"
            acceptButtonText: "Close Account"
            acceptButtonColor: "#CC0000"
            acceptButtonHoverColor: "#990000"

            titleText: "Close Account"
            popupText: "Are you sure you want to close your account?"

            Connections {
                target: confirmDeletePopup.acceptButton
                onClicked: {
                    var user = {
                        username: NavigationControl.context.user_id
                    }
                    LoginUtil.close_account(user)
                    confirmDeletePopup.close()
                    spinnerDialog.open()
                }
            }
        }

        Popup {
            id: spinnerDialog

            width: contentItem.implicitWidth + (2 * padding)
            height: contentItem.implicitHeight + (2 * padding)
            x: mainGrid.width / 2 - width / 2
            y: mainGrid.height / 2 - height / 2

            modal: true
            visible: false
            focus: true
            closePolicy: Popup.NoAutoClose

            contentItem: ConnectionStatus { }

            background: Rectangle {
                color: "white"
            }
        }

        GridLayout {
            id: mainGrid

            anchors.horizontalCenter: parent.horizontalCenter

            columns: 3
            columnSpacing: 5
            rowSpacing: 10

            Component.onCompleted: {
                LoginUtil.get_profile(NavigationControl.context.user_id)
            }

            Popup {
                id: passReqsPopup

                x: newPasswordRow.x
                y: newPasswordRow.y + passwordField.height + 5
                width: newPasswordRow.Layout.preferredWidth
                height: passReqs.height

                visible: (passwordField.focus || confirmPasswordField.focus) && !passReqs.passwordValid
                padding: 0
                background: Item {}
                closePolicy: Popup.NoAutoClose

                PasswordRequirements {
                    id: passReqs
                    width: passReqsPopup.width
                    onClicked: {
                        passwordField.focus = confirmPasswordField.focus = false
                    }
                }
            }

            Timer {
                id: closeAlertTimer

                interval: 3000
                repeat: false

                onTriggered: {
                    hideAlertAnimation.start()
                }
            }

            NumberAnimation{
                id: alertAnimation
                target: alertRect
                property: "Layout.preferredHeight"
                to: firstNameColumn.textField.height + 10
                duration: 100
                onFinished: {
                    closeAlertTimer.start()
                }
            }

            NumberAnimation{
                id: hideAlertAnimation
                target: alertRect
                property: "Layout.preferredHeight"
                to: 0
                duration: 100
                onStarted: alertText.text = ""
            }

            Rectangle {
                id: alertRect

                color: "red"
                visible: Layout.preferredHeight > 0
                clip: true

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 0
                Layout.columnSpan: 3

                SGIcon {
                    id: alertIcon

                    height: 30
                    width: 30
                    anchors {
                        left: alertRect.left
                        verticalCenter: alertRect.verticalCenter
                        leftMargin: alertRect.height/2 - height/2
                    }

                    source: Qt.colorEqual(alertRect.color, "red") ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/check-circle.svg"
                    iconColor: "white"
                }

                Text {
                    id: alertText

                    anchors {
                        left: alertIcon.right
                        right: alertRect.right
                        rightMargin: 5
                        verticalCenter: alertRect.verticalCenter
                    }

                    wrapMode: Label.WordWrap
                    horizontalAlignment:Text.AlignHCenter
                    text: ""
                    color: "white"
                    font {
                        pixelSize: 10
                        family: Fonts.franklinGothicBold
                    }

                }
            }

            ProfileSectionHeader {
                text: "Basic Information"
            }

            ProfileControlContainer {
                id: basicInfoControls

                errorAlertText: "Please make sure that both your first and last name are filled out."
                animationTargets: [firstNameColumn, lastNameColumn]
                expandHeight: firstNameColumn.textField.height
                hideHeight: firstNameColumn.plainText.height

                onSaved: {
                    let data = {
                        "firstname": firstNameColumn.textField.text,
                        "lastname": lastNameColumn.textField.text
                    };
                    spinnerDialog.open()
                    LoginUtil.update_profile(NavigationControl.context.user_id, data)
                }
                onCanceled: {
                    firstNameColumn.textField.text = ""
                    lastNameColumn.textField.text = ""
                }
            }

            ProfileSectionDivider {}

            SubSectionLabel {
                text: "First Name"
            }

            SGTextValidationSwitch {
                id: firstNameColumn

                plainText.text: root.firstName
                placeHolderText: "First Name"
            }

            SubSectionLabel {
                text: "Last Name"
            }

            SGTextValidationSwitch {
                id: lastNameColumn

                plainText.text: root.lastName
                placeHolderText: "Last Name"
            }

            ProfileSectionHeader {
                text: "Company Details"
            }

            ProfileControlContainer {
                id: companyControls

                errorAlertText: ""
                animationTargets: [jobTitleColumn]
                expandHeight: companyColumn.textField.height
                hideHeight: companyColumn.plainText.height

                onSaved: {
                    let data = {
                        "title": jobTitleColumn.textField.text
                    };
                    spinnerDialog.open()
                    LoginUtil.update_profile(NavigationControl.context.user_id, data)
                }
                onCanceled: {
                    companyColumn.textField.text = ""
                    jobTitleColumn.textField.text = ""
                }

                function expandAnimationFinished() {
                    companyColumn.editable = false
                    jobTitleColumn.textField.text = jobTitleColumn.plainText.text
                    jobTitleColumn.editable = true
                    jobTitleColumn.textField.focus = true
                }
            }

            ProfileSectionDivider {}

            SubSectionLabel {
                text: "Company"
            }

            SGTextValidationSwitch {
                id: companyColumn

                plainText.text: root.company
                placeHolderText: "Company"
            }

            SGText {
                id: titleText
                text: "Title"
                color: "grey"

                Layout.columnSpan: 1
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            SGTextValidationSwitch {
                id: jobTitleColumn

                plainText.text: root.jobTitle
                placeHolderText: "Title"
                validationCheck: true
                showValidIcon: false
            }

            ProfileSectionHeader {
                text: "Password"
            }

            ProfileControlContainer {
                id: passwordControls

                errorAlertText: "Please make sure that your password meets our requirements."
                animationTargets: [currentPasswordRow,newPasswordRow]
                expandHeight: passwordField.height

                onSaved: {
                    let timezone = -(new Date(new Date().getFullYear(), 0, 1)).getTimezoneOffset()/60
                    // API currently accepts an int, round towards zero:
                    if (timezone < 0) {
                        timezone = Math.ceil(timezone)
                    } else {
                        timezone = Math.floor(timezone)
                    }
                    var login_info = { user: NavigationControl.context.user_id, password: currentPasswordField.text, timezone: timezone }
                    LoginUtil.login(login_info)
                    spinnerDialog.open()
                }
                onCanceled: {
                    passwordField.text = ""
                    confirmPasswordField.text = ""
                    currentPasswordField.text = ""
                    passwordField.focus = confirmPasswordField.focus = currentPasswordField.focus = false
                }

                function expandAnimationFinished () {
                    newPasswordRow.editable = true
                    currentPasswordRow.editable = true
                }

                function expandAnimationStarted () {
                    return
                }

                function hideAnimationStarted () {
                    newPasswordRow.editable = false
                    currentPasswordRow.editable = false
                    passwordField.focus = confirmPasswordField.focus = currentPasswordField.focus = false
                }

                function hideAnimationFinished () {
                    return
                }

                function allFieldsValid () {
                    return passReqs.passwordValid
                }
            }

            ProfileSectionDivider {}

            SubSectionLabel {
                text: "Current Password"
            }

            Rectangle {
                id: currentPasswordRow
                property bool editable: false
                property alias textField: currentPasswordField

                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.preferredWidth: passwordField.width + confirmPasswordField.width + 30
                Layout.preferredHeight: 0

                onEditableChanged: {
                    currentPasswordField.visible = editable
                    currentPasswordField.focus = editable
                }

                ValidationField {
                    id: currentPasswordField

                    width: 250
                    placeholderText: "Current Password"
                    echoMode: TextInput.Password
                    showIcon: false
                    visible: currentPasswordRow.editable
                }
            }

            SubSectionLabel {
                text: "New Password"
            }

            Rectangle {
                id: newPasswordRow
                property bool editable: false
                property alias textField: passwordField

                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.preferredWidth: passwordField.width + confirmPasswordField.width + 30
                Layout.preferredHeight: 0

                onEditableChanged: {
                    passwordField.visible = confirmPasswordField.visible = editable
                }

                ValidationField {
                    id: passwordField

                    width: 250

                    placeholderText: "New password"
                    echoMode: TextInput.Password
                    showIcon: false
                    visible: newPasswordRow.editable

                    SGIcon {
                        id: showPasswordIcon
                        source: passwordField.echoMode === TextInput.Password ? "qrc:/sgimages/eye.svg" : "qrc:/sgimages/eye-slash.svg"
                        iconColor: showPassword.containsMouse ? "lightgrey" : "#ddd"
                        anchors {
                            verticalCenter: passwordField.verticalCenter
                            rightMargin: 5
                            right: passwordField.right
                        }
                        height: passwordField.height*.75
                        width: height

                        MouseArea {
                            id: showPassword
                            anchors.fill: showPasswordIcon
                            hoverEnabled: true
                            onClicked: {
                                if (passwordField.echoMode === TextInput.Password) {
                                    passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Normal
                                } else {
                                    passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Password
                                }
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                ValidationField {
                    id: confirmPasswordField

                    anchors {
                        left: passwordField.right
                        leftMargin: 10
                    }

                    placeholderText: "Confirm password"
                    echoMode: TextInput.Password
                    showIcon: false
                    width: 250

                    visible: newPasswordRow.editable
                }
            }

            ProfileSectionHeader {
                text: "Close Account"
            }

            ProfileSectionDivider {}

            SGText {
                text: "Closing your account will remove your account and all personal information from our records. You will not be able to recover the account after closing it."
                font.weight: Font.Bold
                Layout.columnSpan: 3
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                id: closeAccountButton
                text: "Close Account"

                Layout.columnSpan: 3

                contentItem: Text {
                    text: closeAccountButton.text
                    font.pixelSize: 12
                    font.family: Fonts.franklinGothicBook
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    id: closeAccountBtnBg
                    implicitWidth: 100
                    implicitHeight: 40
                    color: "#CC0000"
                }

                onClicked: {
                    confirmDeletePopup.open()
                }

                MouseArea {
                    id: confirmDeleteCursor

                    hoverEnabled: true
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        closeAccountBtnBg.color = "#990000"
                    }

                    onExited: {
                        closeAccountBtnBg.color = "#CC0000"
                    }
                }
            }
            Connections {
                target: LoginUtil.signals

                onLoginResult: {
                    let resultObject = JSON.parse(result)

                    if (resultObject.response === "Connected") {
                        let data = {
                            "password": passwordField.text
                        };
                        LoginUtil.update_profile(NavigationControl.context.user_id, data)
                    } else {
                        passwordControls.expandAnimation.start()
                        passwordControls.editing = true
                        alertRect.color = "red"
                        if (resultObject.response === "No Connection") {
                            alertText.text = "Connection to authentication server failed";
                        } else {
                            alertText.text = "Password is incorrect. Please try again."
                        }
                        spinnerDialog.close()
                        alertAnimation.start()
                    }
                }

                onChangePasswordResult: {
                    if (result === "Success") {
                        alertText.text = "Successfully changed your password!"
                        alertRect.color = "#57d445"
                        resetFields()
                    } else {
                        console.error(result)
                        if (result === "No connection") {
                            alertText.text = "Connection to registration server failed"
                        } else {
                            alertText.text = "Unable to update password. Please try again."
                        }
                        alertRect.color = "red"
                    }
                    spinnerDialog.close()
                    alertAnimation.start()
                }

                onProfileUpdateResult: {
                    if (result === "Success") {
                        // Get the user's new profile
                        LoginUtil.get_profile(NavigationControl.context.user_id)

                        alertText.text = "Successfully updated your account information!"
                        alertRect.color = "#57d445"

                        resetFields()
                    } else {
                        console.error("Unable to change profile information")
                        alertText.text = "Unable to update profile. Try again later."
                        alertRect.color = "red"
                    }
                    spinnerDialog.close()
                    alertAnimation.start()
                }

                onCloseAccountResult: {
                    if (result === "Success") {
                        let userNames = JSON.parse(userStoreSettings.userNameStore);
                        userNames = userNames.filter(username => username !== NavigationControl.context.user_id);
                        userStoreSettings.setValue("userNameStore", JSON.stringify(userNames));
                        userStoreSettings.setValue("userNameIndex", -1);
                        spinnerDialog.close()

                        resetFields()

                        PlatformFilters.clearActiveFilters()
                        LoginUtil.logout()
                        PlatformSelection.logout()
                        sdsModel.coreInterface.unregisterClient()
                        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                    } else {
                        if (result === "No connection") {
                            alertText.text = "Connection to registration server failed"
                        } else if (result === "Invalid authentication token") {
                            alertText.text = "Unable to close account. Please try to log out and back in."
                        } else {
                            alertText.text = "Unable to close account. Please try again later."
                        }

                        alertRect.color = "red"
                    }
                    spinnerDialog.close()
                    alertAnimation.start()
                }

                onGetProfileResult: {
                    if (result === "Success") {
                        NavigationControl.context.first_name = user.firstname
                        authSettings.setValue("first_name", user.firstname)
                        root.headerText = user.firstname[0].toUpperCase() + user.firstname.slice(1) + "'s Profile"
                        root.firstName = user.firstname

                        NavigationControl.context.last_name = user.lastname
                        authSettings.setValue("last_name", user.lastname)
                        root.lastName = user.lastname

                        root.company = user.company
                        root.jobTitle = user.title
                    }
                    spinnerDialog.close()

                }
            }

            Settings {
                id: userStoreSettings

                category: "Usernames"
                property string userNameStore: "[]"
                property int userNameIndex: -1
            }

            Settings {
                id: authSettings

                category: "Login"
                property string token: ""
                property string first_name: ""
                property string last_name: ""
                property string user: ""
            }
        }
    }

    // Function to reset all fields if they are not open for edit
    function resetFields () {
        if (!firstNameColumn.editable) {
            firstNameColumn.textField.text = ""
            lastNameColumn.textField.text = ""
        }

        if (!companyColumn.editable) {
            companyColumn.textField.text = ""
            jobTitleColumn.textField.text = ""
        }

        if (!currentPasswordRow.editable) {
            currentPasswordField.text = ""
        }

        if (!newPasswordRow.editable) {
            passwordField.text = ""
            confirmPasswordField.text = ""
        }
    }
}