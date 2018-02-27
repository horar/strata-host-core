import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0

Item {

    ColumnLayout{
        id:settingsColumn
        spacing: 0

        //-----------------------------------------------
        //  Board settings
        //-----------------------------------------------
        AdvancedBoardSettings{
            id: boardSettings
            fullHeight:350
            collapsedHeight:55
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : boardSettings.fullHeight


        }   //board settings rect

        //-----------------------------------------------
        //  Port 1 settings
        //-----------------------------------------------
        AdvancedPortSettings{
            id:port1Settings
            fullHeight:310
            collapsedHeight:60
            portName:"Port 1"
            enabledTextFieldBackgroundColor: textEditFieldBackgroundColor

            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : port1Settings.fullHeight
        }

        //--------------------------
        // port 2 settings
        //--------------------------
        AdvancedPortSettings{
            id:port2Settings
            fullHeight:310
            collapsedHeight:60
            portName:"Port 2"
            enabledTextFieldBackgroundColor: textEditFieldBackgroundColor

            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : port2Settings.fullHeight
        }


    }   //column layout
}
