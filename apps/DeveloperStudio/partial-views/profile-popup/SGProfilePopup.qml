/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.signals 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

import '../'
import '../login/registration'
import "../general"
import '../login'
import 'qrc:/js/login_utilities.js' as LoginUtils
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/constants.js" as Constants

SGStrataPopup {
    id: root

    headerText: fitHeader(NavigationControl.context.first_name) + "'s Profile"
    modal: true
    visible: true
    closePolicy: Popup.CloseOnEscape
    focus: true
    horizontalPadding: 20
    bottomPadding: 20
    x: container.width/2 - root.width/2
    y: mainWindow.height/2 - root.height/2

    property string firstName: NavigationControl.context.first_name
    property string lastName: NavigationControl.context.last_name
    property string company: "N/A"
    property string jobTitle: "N/A"
    property int offset: 50
    property bool consentDataCollection: true

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
        alertRect.hideInstantly()
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
        parent.active = false
    }

    onFirstNameChanged: firstNameColumn.plainText.text = firstName
    onLastNameChanged: lastNameColumn.plainText.text = lastName
    onCompanyChanged: companyColumn.plainText.text = company
    onJobTitleChanged: jobTitleColumn.plainText.text = jobTitle


    FontMetrics {
        id: headerMetrics
    }

    contentItem: Column {
        id: wrapperContainer

        width: mainGrid.width + offset
        anchors.horizontalCenter: parent.horizontalCenter

        SGConfirmationPopup {
            id: confirmDeletePopup

            cancelButtonText: "Cancel"
            acceptButtonText: "Close Account"
            acceptButtonColor: Theme.palette.error
            acceptButtonHoverColor: Qt.darker(Theme.palette.error, 1.15)

            titleText: "Close Account"
            popupText: "Are you sure you want to close your account?"

            onPopupClosed: {
                if (closeReason === confirmDeletePopup.acceptCloseReason) {
                    var user = {
                        username: NavigationControl.context.user_id
                    }
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.close_account(user)
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

            contentItem: ConnectionStatus { id: connectionStatus }

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

            property bool guestUser: false

            Component.onCompleted: {
                if (NavigationControl.context.user_id === Constants.GUEST_USER_ID) {
                    guestUser = true
                }

                if (guestUser === false) {
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.get_profile(NavigationControl.context.user_id)
                }
            }

            SGNotificationToast {
                 id: alertRect

                 Layout.alignment: Qt.AlignHCenter
                 Layout.fillWidth: true
                 Layout.columnSpan: 3
            }

            ProfileSectionHeader {
                text: "Basic Information"
            }


            ProfileControlContainer {
                id: basicInfoControls

                errorAlertText: "Please make sure that both your first and last name are filled out."
                animationTargets: guestUser === true ? [] : [firstNameColumn, lastNameColumn]
                expandHeight: firstNameColumn.textField.height
                hideHeight: firstNameColumn.plainText.height
                onEditingChanged: {
                    if(alertRect.visible) alertRect.hide();
                }

                onSaved: {
                    let data = {
                        "firstname": firstNameColumn.textField.text,
                        "lastname": lastNameColumn.textField.text
                    };
                    spinnerDialog.open()
                    firstNameColumn.editable = false;
                    lastNameColumn.editable = false;
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.update_profile(NavigationControl.context.user_id, data)
                    resetHeight();
                }
                onCanceled: {
                    firstNameColumn.textField.text = ""
                    lastNameColumn.textField.text = ""
                }
            }

            ProfileSectionDivider {}

            SubSectionLabel {
                id: firstNameLabel
                text: "First Name"
            }

            SGTextValidationSwitch {
                id: firstNameColumn

                plainText.text: root.firstName
                placeHolderText: "First Name"
                plainText.width: root.width - firstNameLabel.width - offset

            }

            SubSectionLabel {
                id: lastNameLabel
                text: "Last Name"
            }

            SGTextValidationSwitch {
                id: lastNameColumn

                plainText.text: root.lastName
                placeHolderText: "Last Name"
                plainText.width: root.width - lastNameLabel.width - offset
            }

            ProfileSectionHeader {
                text: "Company Details"
            }

            ProfileControlContainer {
                id: companyControls

                errorAlertText: ""
                animationTargets: guestUser === true ? [] : [jobTitleColumn]
                expandHeight: companyColumn.textField.height
                hideHeight: companyColumn.plainText.height
                onEditingChanged: {
                    if(alertRect.visible) alertRect.hide();
                }

                onSaved: {
                    let data = {
                        "title": jobTitleColumn.textField.text
                    };
                    spinnerDialog.open()
                    companyColumn.editable = false
                    jobTitleColumn.editable = false
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.update_profile(NavigationControl.context.user_id, data)
                    resetHeight();
                }
                onCanceled: {
                    companyColumn.textField.text = ""
                    jobTitleColumn.textField.text = ""
                }

                function expandAnimationFinished() {
                    jobTitleColumn.textField.text = jobTitleColumn.plainText.text
                    jobTitleColumn.textField.focus = true
                    companyColumn.editable = false

                    if (mainGrid.guestUser === false) {
                        jobTitleColumn.editable = true
                    }
                }
            }

            ProfileSectionDivider {}

            SubSectionLabel {
                id: companyLabel
                text: "Company"
            }

            SGTextValidationSwitch {
                id: companyColumn

                plainText.text: root.company
                placeHolderText: "Company"
                plainText.width: root.width - companyLabel.width - offset
            }

            SubSectionLabel {
                id: occupationLabel
                text: "Occupation"
            }

            SGTextValidationSwitch {
                id: jobTitleColumn

                plainText.text: root.jobTitle
                placeHolderText: "Occupation"
                validationCheck: true
                showValidIcon: false
                plainText.width: root.width - occupationLabel.width - offset
            }

            ProfileSectionHeader {
                text: "Password"
            }

            ProfileControlContainer {
                id: passwordControls

                errorAlertText: "Please make sure that your new password meets our requirements."
                animationTargets: guestUser === true ? [] : [currentPasswordRow,newPasswordRow]
                expandHeight: passwordField.height

                onEditingChanged: {
                    if(alertRect.visible) alertRect.hide();
                }

                onSaved: {
                    let timezone = -(new Date(new Date().getFullYear(), 0, 1)).getTimezoneOffset()/60
                    // API currently accepts an int, round towards zero:
                    if (timezone < 0) {
                        timezone = Math.ceil(timezone)
                    } else {
                        timezone = Math.floor(timezone)
                    }
                    var login_info = { user: NavigationControl.context.user_id, password: currentPasswordField.text, timezone: timezone }
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.login(login_info)
                    currentPasswordRow.editable = false
                    newPasswordRow.editable = false
                    spinnerDialog.open()
                }

                onFailed: {
                    if ((passwordField.focus == false) && (confirmPasswordField.focus == false)) {
                        passwordField.forceActiveFocus()
                    }
                }

                onCanceled: {
                    passwordField.text = ""
                    confirmPasswordField.text = ""
                    currentPasswordField.text = ""
                    passwordField.focus = confirmPasswordField.focus = currentPasswordField.focus = false
                }

                function expandAnimationFinished () {
                    if (mainGrid.guestUser === false) {
                        newPasswordRow.editable = true
                        currentPasswordRow.editable = true
                    }
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
                    showIcon: false
                    passwordMode: true
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
                    if (editable === false) {
                        passReqsPopup.close()
                    }
                }

                ValidationField {
                    id: passwordField

                    width: 250

                    placeholderText: "New password"
                    showIcon: false
                    passwordMode: true
                    visible: newPasswordRow.editable

                    onPressed: {
                        passReqsPopup.openPopup()
                    }
                }

                ValidationField {
                    id: confirmPasswordField

                    anchors {
                        left: passwordField.right
                        leftMargin: 10
                    }

                    placeholderText: "Confirm password"
                    echoMode: passwordField.echoMode
                    valid: passReqs.passwordValid
                    width: 250

                    visible: newPasswordRow.editable

                    onPressed: {
                        passReqsPopup.openPopup()
                    }

                    onValidChanged: {
                        if (valid) {
                            passReqsPopup.close()
                        } else {
                            passReqsPopup.openPopup()
                        }
                    }
                }

                Popup {
                    id: passReqsPopup

                    y: passwordField.height + 5
                    width: passwordField.width + confirmPasswordField.width + 10
                    height: passReqs.height

                    padding: 0
                    background: Item {}
                    closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

                    property bool acquiredFocus: passwordField.focus || confirmPasswordField.focus

                    PasswordRequirements {
                        id: passReqs
                        width: passReqsPopup.width
                        onClicked: {
                            passReqsPopup.close()
                        }
                    }

                    onAcquiredFocusChanged: {
                        if (acquiredFocus) {
                            passReqsPopup.openPopup()
                        } else {
                            passReqsPopup.close()
                        }
                    }

                    function openPopup() {
                        if (passReqsPopup.opened === false
                                && passReqs.passwordValid === false
                                && newPasswordRow.editable)
                        {
                            passReqsPopup.open()
                        }
                    }
                }
            }

            ProfileSectionDivider {}

            RowLayout {
                spacing: 8
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 3

                SGSwitch {
                    id: dataCollectionSwitch
                    checked: !root.consentDataCollection
                    grooveFillColor: Theme.palette.onsemiOrange

                    onToggled: {
                        let data = {
                            "consent_data_collection": !checked
                        };
                        LoginUtils.update_profile(NavigationControl.context.user_id, data)
                    }
                }

                SGText {
                    id: dataCollectionText
                    text: qsTr("Opt-out Data Collection (change will take effect after logout or app close)")
                }
           }

            Rectangle {
                height: 8
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

                enabled: mainGrid.guestUser === false
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
                    color: Theme.palette.error
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
                        closeAccountBtnBg.color = Qt.darker(Theme.palette.error, 1.15)
                    }

                    onExited: {
                        closeAccountBtnBg.color = Theme.palette.error
                    }
                }
            }
            Connections {
                target: Signals

                onLoginResult: {
                    let resultObject = JSON.parse(result)

                    if (resultObject.response === "Connected") {
                        let data = {
                            "password": passwordField.text
                        };
                        connectionStatus.currentId = LoginUtils.getNextId()
                        LoginUtils.update_profile(NavigationControl.context.user_id, data)
                    } else {
                        passwordControls.expandAnimation.start()
                        passwordControls.editing = true
                        alertRect.color = Theme.palette.error
                        if (resultObject.response === "No Connection") {
                            alertRect.text = "Connection to authentication server failed. Please check your internet connection and try again.";
                        } else if (resultObject.response === "Server Error") {
                            alertRect.text = "Authentication server is unable to process your request at this time. Please try again later."
                        } else {
                            alertRect.text = "Current password is incorrect. Please try again."
                        }
                        spinnerDialog.close()
                        alertRect.show()
                    }
                }

                onChangePasswordResult: {
                    if (result === "Success") {
                        alertRect.text = "Successfully changed your password!"
                        alertRect.color = Theme.palette.success
                        resetFields()
                    } else {
                        console.error(result)
                        if (result === "No Connection") {
                            alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                        } else if (result === "Server Error") {
                            alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                        } else if (result === "Invalid Authentication") {
                            alertRect.text = "Registration server is unable to authenticate your request. Please try to log out and back in."
                        } else {
                            alertRect.text = "Unable to update password. Please try again."
                        }
                        alertRect.color = Theme.palette.error
                    }
                    spinnerDialog.close()
                    alertRect.show()
                }

                onProfileUpdateResult: {
                    if (result === "Success") {
                        // Get the user's new profile
                        for (const [key, value] of Object.entries(updatedProperties)) {
                            switch (key) {
                            case "firstname":
                                NavigationControl.context.first_name = value
                                authSettings.setValue("first_name", value)
                                root.headerText = fitHeader(value) + "'s Profile"
                                root.firstName = value
                                break;
                            case "lastname":
                                NavigationControl.context.last_name = value
                                authSettings.setValue("last_name", value)
                                root.lastName = value
                                break;
                            case "title":
                                root.jobTitle = value
                                break;
                            case "consent_data_collection":
                                root.consentDataCollection = value
                                break;
                            default:
                                break;
                            }
                        }

                        alertRect.text = "Successfully updated your account information!"
                        alertRect.color = Theme.palette.success

                        resetFields()
                    } else {
                        console.error("Unable to change profile information")
                        if (result === "No Connection") {
                            alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                        } else if (result === "Server Error") {
                            alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                        } else if (result === "Invalid Authentication") {
                            alertRect.text = "Registration server is unable to authenticate your request. Please try to log out and back in."
                        } else {
                            alertRect.text = "Unable to update profile. Please try again."
                        }
                        alertRect.color = Theme.palette.error
                    }
                    spinnerDialog.close()
                    alertRect.show()
                }

                onCloseAccountResult: {
                    if (result === "Success") {
                        let userNames = JSON.parse(userStoreSettings.userNameStore);
                        userNames = userNames.filter(username => username !== NavigationControl.context.user_id);
                        userStoreSettings.setValue("userNameStore", JSON.stringify(userNames));
                        userStoreSettings.setValue("userNameIndex", -1);

                        resetFields()
                        mainWindow.logout()
                    } else {
                        if (result === "No Connection") {
                            alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                        } else if (result === "Server Error") {
                            alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                        } else if (result === "Invalid Authentication") {
                            alertRect.text = "Registration server is unable to authenticate your request. Please try to log out and back in."
                        } else {
                            alertRect.text = "Unable to close account. Please try again later."
                        }

                        alertRect.color = Theme.palette.error
                        alertRect.show()
                    }
                    spinnerDialog.close()
                }

                onGetProfileResult: {
                    if (result === "Success") {
                        NavigationControl.context.first_name = user.firstname
                        authSettings.setValue("first_name", user.firstname)
                        root.headerText = fitHeader(user.firstname) + "'s Profile"
                        root.firstName = user.firstname

                        NavigationControl.context.last_name = user.lastname
                        authSettings.setValue("last_name", user.lastname)
                        root.lastName = user.lastname

                        root.company = user.company
                        root.jobTitle = user.title

                        root.consentDataCollection = user.consent_data_collection
                    } else {
                        if (result === "No Connection") {
                            alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                        } else if (result === "Server Error") {
                            alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                        } else if (result === "Invalid Authentication") {
                            alertRect.text = "Registration server is unable to authenticate your request. Please try to log out and back in."
                        } else {
                            alertRect.text = "Unable to aquire your profile data. Please try again later."
                        }

                        alertRect.color = Theme.palette.error
                        alertRect.show()
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
            basicInfoControls.resetHeight()
        }

        if (!companyColumn.editable) {
            companyColumn.textField.text = ""
            jobTitleColumn.textField.text = ""
            companyControls.resetHeight()
        }

        if (!currentPasswordRow.editable) {
            currentPasswordField.text = ""
        }

        if (!newPasswordRow.editable) {
            passwordField.text = ""
            confirmPasswordField.text = ""
        }
    }

    function fitHeader(firstName) {
        return headerMetrics.elidedText(firstName[0].toUpperCase() + firstName.slice(1), Qt.ElideMiddle, 100)
    }
}
