/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Rectangle {
    id: passwordInfo
    height: requirementsGrid.height + 20
    border.color: "#cccccc"
    color: "#eee"

    signal clicked()

    property alias passwordValid: requirementsGrid.passwordValid

    GridLayout {
        id: requirementsGrid
        width: parent.width - 20
        anchors.centerIn: parent
        columns: 4
        columnSpacing: 10
        rowSpacing: 10

        property bool passwordValid: passwordsMatch && hasCapital && hasLower && hasNumber && lengthValid
        property bool passwordsMatch: passwordField.text === confirmPasswordField.text
        property bool hasCapital: passwordField.text.match(/(?:[A-Z])/)
        property bool hasLower: passwordField.text.match(/(?:[a-z])/)
        property bool hasNumber: passwordField.text.match(/(?:\d)/)
        property bool lengthValid: passwordField.text.match(/.{8,256}/)
        // based on https://www.w3resource.com/javascript/form/password-validation.php

        SGIcon {
            source: requirementsGrid.passwordsMatch ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
            iconColor: requirementsGrid.passwordsMatch ? "#30c235" : "#cccccc"
            height: 20
            width: height
        }

        Text {
            text: "Passwords match"
            Layout.fillWidth: true
        }

        SGIcon {
            source: requirementsGrid.hasCapital ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
            iconColor: requirementsGrid.hasCapital ? "#30c235" : "#cccccc"
            height: 20
            width: height
        }

        Text {
            text: "Contains capital letter"
            Layout.fillWidth: true
        }

        SGIcon {
            source: requirementsGrid.hasLower ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
            iconColor: requirementsGrid.hasLower ? "#30c235" : "#cccccc"
            height: 20
            width: height
        }

        Text {
            text: "Contains lowercase letter"
            Layout.fillWidth: true
        }

        SGIcon {
            source: requirementsGrid.hasNumber ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
            iconColor: requirementsGrid.hasNumber ? "#30c235" : "#cccccc"
            height: 20
            width: height
        }

        Text {
            text: "Contains number"
            Layout.fillWidth: true
        }

        SGIcon {
            source: requirementsGrid.lengthValid ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
            iconColor: requirementsGrid.lengthValid ? "#30c235" : "#cccccc"
            height: 20
            width: height
        }

        Text {
            text: "Between 8 and 256 characters"
            Layout.fillWidth: true
        }

    }

    MouseArea {
        anchors {
            fill: parent
        }
        onClicked: {
            passwordInfo.clicked()
        }
    }
}
