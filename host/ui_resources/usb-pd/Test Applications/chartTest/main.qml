import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtCharts 2.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    property var thePointsList: []

    ChartView {
        id:theChart
        anchors.fill: parent
        theme: ChartView.ChartThemeBrownSand
        antialiasing: true
        animationOptions: ChartView.SeriesAnimations



        LineSeries{
            id: sineWave
            name: "sine"
            axisY: ValueAxis{
                min: -1
                max: 1
            }
            axisX: ValueAxis{
                min: 0
                max: 628
            }

        }

        //load the data algorithmically
        Component.onCompleted: {

            var thePoint;

            for (var i=0; i<=628; i++){
                //sineWave.append(i, Math.sin(i/100))
                //console.log("position",i, " is ", Math.sin(i));
                thePoint = Qt.point(i, Math.sin(i/100));
                thePointsList[i] = thePoint;
                console.log("position",i, " is ", thePointsList[i]);
                sineWave.replace()
                }

        }
    }



    Timer {
        id: refreshTimer
        interval: 50 // 60 Hz
        running: true
        repeat: true

        onTriggered: {
            var firstPoint = 0;
            var nextPoint = 0;

            //save the first value to put at the end
            firstPoint = thePointsList[0];

            //rotate the values in thePointsList, putting the first value at the end
            for(var i=0;i<628;i++){
                nextPoint = thePointsList.at(i+1);
                thePointsList.replace(i, i, nextPoint.y);
                }
            thePointsList.replace(628,628,firstPoint.y);

                //replace the data shown in the chart with the new data
            sineWave.replace(thePointsList);


        }
    }

}
