import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: appWindow

    width: 800
    minimumWidth: 640
    height: 600
    minimumHeight: 480
    visible: true

    title: qsTr("Strata Developer Studio - update RS")

    signal qmlSignal(string msg)
    signal qmlSignalReload()
    signal qmlSignalRccReload()

    Rectangle {
        anchors.fill: parent
        color: "blue"

        ColumnLayout {
            id: buttonLayout
            anchors.centerIn: parent

            Button {
                id: buttonReloadPlugin
                text: qsTr("Reload [plugin]")
                Layout.alignment: Qt.AlignCenter

                onClicked: {
                    appWindow.qmlSignalReload()
                    swWidgetsLoader_bob.reload()
                    swWidgetsLoader_alice.reload()
                }
            }
            Button {
                id: buttonReloadResource
                text: qsTr("Reload [rcc]")
                Layout.alignment: Qt.AlignCenter

                onClicked: {
                    appWindow.qmlSignalRccReload()
                    swWidgetsLoaderResource_bob.reload()
                    swWidgetsLoaderResource_alice.reload()
                }
            }

            Button {
                id: buttonReloadComponent
                enabled: false
                text: qsTr("Reload [cmp]")
                Layout.alignment: Qt.AlignCenter

                onClicked: {
                    appWindow.qmlSignalReload()
                    swWidgetsComponentLoader.reload()
                }
            }

            Button {
                id: buttonNotifyCpp
                text: qsTr("Notify C++ from u-plugin")
                Layout.alignment: Qt.AlignCenter

                onClicked: appWindow.qmlSignal("huhu")
            }

            Button {
                id: buttonRestart
                text: qsTr("Restart Engine")
                Layout.alignment: Qt.AlignCenter

                onClicked: Qt.exit(123)
            }

            Button {
                id: buttonQuit
                text: qsTr("Quit")
                Layout.alignment: Qt.AlignCenter

                onClicked: Qt.exit(0)
            }

            RowLayout {
                id: testData

                GroupBox {
                    title: "Plugin"

                    ColumnLayout {
                        Loader {
                            id: swWidgetsLoader_bob
                            Layout.alignment: Qt.AlignCenter

                            function reload() {
                                source = "";
                                $QmlEngine.clearCache();
                                source = "qrc:/OnSemiQuick/Bob.qml";
                            }
                            width: buttonQuit.width
                            height: buttonQuit.height

                            source: ""
                        }

                        Loader {
                            id: swWidgetsLoader_alice

                            function reload() {
                                source = "";
                                $QmlEngine.clearCache();
                                source = "qrc:/OnSemiQuick/Alice.qml";
                            }

                            source: ""
                        }
                    }
                }

                GroupBox {
                    title: "Resources"

                    ColumnLayout {
                        Loader {
                            id: swWidgetsLoaderResource_bob
                            Layout.alignment: Qt.AlignCenter

                            function reload() {
                                source = "";
                                $QmlEngine.clearCache();
                                source = "qrc:/OnSemiQuick2/Bob.qml";
                            }
                            width: buttonQuit.width
                            height: buttonQuit.height

                            source: ""
                        }
                        Loader {
                            id: swWidgetsLoaderResource_alice

                            function reload() {
                                source = "";
                                $QmlEngine.clearCache();
                                source = "qrc:/OnSemiQuick2/Alice.qml";
                            }

                            source: ""
                        }
                    }
                }
            }



            //            Component {
            //                id: swWidgetsComponent

            //                Alice {
            //                    width: buttonQuit.width
            //                    height: buttonQuit.height
            //                }
            //            }

            //            Loader {
            //                id: swWidgetsComponentLoader

            //                function reload() {
            //                    sourceComponent = undefined
            //                    $QmlEngine.clearCache();
            //                    sourceComponent = asdf//swWidgetsComponent;
            //                }
            //                width: buttonQuit.width
            //                height: buttonQuit.height

            ////                sourceComponent: swWidgetsComponent
            //            }
        }
    }
}
