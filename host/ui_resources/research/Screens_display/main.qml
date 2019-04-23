import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 1000
    height: 1200
    title: qsTr("Welcome Screen")
    property string mainUserName: "David Somo"
    property var userImages: [["David Priscak","images/dave_priscak.png"] , ["David Somo","images/david_somo.png"], ["Daryl Ostrander","images/daryl_ostrander.png"], ["Paul Mascarenas","images/paul_mascarenas.png"] ]

        function getImages(user_name)
        {
            var i;
            var flag = " ";
            for(i = 0; i < userImages.length; i++) {

                if(user_name === userImages[i][0])

                {
                    console.log(userImages[i][1]);
                    return userImages[i][1];
                }
            }
        }


    SGWelcomeScreen { userName:mainUserName ;anchors.centerIn: parent; link: getImages(mainUserName) }
    SGStatusBar { userName:mainUserName }

}
