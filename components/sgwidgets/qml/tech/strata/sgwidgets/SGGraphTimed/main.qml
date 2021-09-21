/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGGraph Example")

    SGGraphTimed {
        // ChartView needs to be run in a QApplication, not the default QGuiApplication
        // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
        id: graph

        anchors {
            fill: parent                // Set custom anchors for responsive sizing
        }

        inputData: graphData.stream          // Set the graph's data source here

        // Optional graph settings:
        title: "Graph"                  // Default: empty
        xAxisTitle: "Seconds"           // Default: empty
        yAxisTitle: "why axis"          // Default: empty
        showYGrids: true                // Default: false
        // showXGrids: false               // Default: false
        reverseDirection: true          // Default: false - Reverses the direction of graph motion
        autoAdjustMaxMin: true          // Default: false - If inputData is greater than maxYValue or less than minYValue, these limits are adjusted to encompass that point.
        maxYValue: 20                   // Default: 10
        // minYValue: 0                    // Default: 0
        // maxXValue: 5                    // Default: 5
        // minXValue: 0                    // Default: 0
        // dataLineColor: "white"          // Default: #000000 (black)
        // axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
        // gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
        // underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
        // backgroundColor: "black"        // Default: #ffffff (white)
        // textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
        // xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
        // yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
        // throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (false NOT RECOMMENDED)
        // repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current time with the last input value
                                           //          *by default matches visibility of graph, so it doesn't waste resources in the background.
        // pointCount: 50                  // Default: 50 - Approximate number of graphed points when throttled -- If you don't need 50 data points over your time range, lower this for better performance.
    }

    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 20
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*3+10;
        }
    }

//    PerformanceTest {}  // Runs 8 graphs concurrently for perfomance testing
}
