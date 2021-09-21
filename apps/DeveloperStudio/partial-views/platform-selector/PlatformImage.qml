/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQml 2.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Rectangle {
    id: imageContainer
    implicitHeight: width * aspectRatio
    implicitWidth: sourceWidth

    property real sourceHeight: 120
    property real sourceWidth: 167
    property real aspectRatio: 120/167
    property alias text: title.text
    property alias textBgColor: textBg.color

    readonly property string defaultText: "CONNECTED"
    readonly property color defaultTextBg: Theme.palette.onsemiOrange

    Image {
        id: image
        sourceSize.height: imageContainer.sourceHeight
        sourceSize.width: imageContainer.sourceWidth
        width: imageContainer.width
        visible: model.image !== undefined && status == Image.Ready
        fillMode: Image.PreserveAspectFit
        asynchronous: true

        property string modelSource: model.image

        Component.onCompleted: {
            initialize()
        }

        onModelSourceChanged: {
            initialize()
        }

        function initialize() {
            if (model.image.length === 0) {
                console.error(Logger.devStudioCategory, "Platform Selector Delegate: No image source supplied by platform list")
                source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
            } else if (SGUtilsCpp.isFile(SGUtilsCpp.urlToLocalFile(model.image)) && SGUtilsCpp.isValidImage(SGUtilsCpp.urlToLocalFile(model.image))) {
                source = model.image
            } else {
                imageCheck.start()
            }
        }

        onStatusChanged: {
            if (image.status === Image.Error){
                console.error(Logger.devStudioCategory, "Platform Selector Delegate: Image failed to load - corrupt or does not exist:", model.image)
                source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
            }
        }

        Timer {
            id: imageCheck
            interval: 1000
            running: false
            repeat: false

            onTriggered: {
                interval += interval
                if (interval < 32000) {
                    if (SGUtilsCpp.isFile(SGUtilsCpp.urlToLocalFile(model.image)) && SGUtilsCpp.isValidImage(SGUtilsCpp.urlToLocalFile(model.image))){
                        image.source = model.image
                        return
                    }
                    imageCheck.start()
                } else {
                    // stop trying to load after 31 seconds (interval doubles every triggered)
                    console.error(Logger.devStudioCategory, "Platform Selector Delegate: Image loading timed out:", model.image)
                    image.source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
                }
            }
        }

        Image {
            id: comingSoon
            sourceSize.height: image.sourceSize.height
            height: parent.paintedHeight
            fillMode: Image.PreserveAspectFit
            source: visible ? "images/platform-images/comingsoon.png" : ""
            visible: model.coming_soon
        }

        Image {
            id: recentlyReleased
            sourceSize.height: image.sourceSize.height
            height: parent.paintedHeight
            fillMode: Image.PreserveAspectFit
            source: visible ? "images/platform-images/recentlyReleased.png" : ""
            visible: model.recently_released
        }
    }

    AnimatedImage {
        id: loaderImage
        height: 40
        width: 40
        anchors {
            centerIn: imageContainer
            verticalCenterOffset: -15
        }
        playing: image.status !== Image.Ready
        visible: playing
        source: "qrc:/images/loading.gif"
        opacity: .25
    }

    Text {
        id: loadingText
        anchors {
            top: loaderImage.bottom
            topMargin: 10
            horizontalCenter: loaderImage.horizontalCenter
        }
        visible: loaderImage.visible
        color: "lightgrey"
        text: "Loading..."
        font.family: Fonts.franklinGothicBold
    }

    Rectangle {
        id: textBg
        color: defaultTextBg
        width: imageContainer.width
        anchors {
            bottom: imageContainer.bottom
        }
        height: 25
        visible: model.connected
        clip: true

        SGText {
            id: title
            color: "white"
            anchors {
                centerIn: parent
            }
            text: defaultText
            font.bold: true
            fontSizeMultiplier: 1.4
        }
    }
}

