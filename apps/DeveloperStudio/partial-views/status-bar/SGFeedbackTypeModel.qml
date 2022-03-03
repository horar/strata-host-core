/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

ListModel {
    ListElement {
        type: "Bug"
        baseColor: "#f91515"
        hoverColor: "#fb6a6a"
    }
    ListElement {
        type: "Feature"
        baseColor: "#57d645"
        hoverColor: "#a0e896"
    }
    ListElement {
        type: "Acknowledgement"
        baseColor: "#a5a5a5"
        hoverColor: "#d9d9d9"
    }
}
