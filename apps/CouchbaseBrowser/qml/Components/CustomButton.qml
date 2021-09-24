/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Button {
    id: root
    width: 30
    height: 80

    text: "Submit"

    property alias radius: background.radius

    background: Rectangle {
        id: background
        radius: 8
        gradient: Gradient {
            GradientStop { position: 0 ; color: root.hovered ? "#fff" : "#eee"}
            GradientStop { position: 1 ; color: root.hovered ? "#aaa" : "#999" }
        }
    }
}
