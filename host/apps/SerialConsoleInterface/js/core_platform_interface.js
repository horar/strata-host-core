function notificationHandler (notification, platformID) {
    var tabNumber = platformInterface.platformList[platformID].tabNumber
    platformInterface.tabList.tabs[tabNumber].content.logBoxList.append({ "status" : notification})
}

function platformConnectionChanged (payload) {
    try {
        var notification = JSON.parse(payload)
//        console.log("payload: ", payload)

        var platformID = notification.platformID
        var connected = notification.connected
        var verboseName = notification.verboseName
        var platformCommands = notification.platformCommands


        var thisTab

        if (connected) {
            // If there is no entry for this platform, it is connecting for the first time and needs init
            if(!platformInterface.platformList[platformID]) {

                // If new platform, and new tab not yet existing, create tab
                if (platformInterface.tabList.tabCount === platformInterface.tabList.nextTabToConnect){
                    addTabView()
                }

//                console.log("Core Plat Interface: Initializing "+ verboseName)
                var connectingTab = platformInterface.tabList.nextTabToConnect
                platformInterface.platformList[platformID] = { "connected": connected, "name": verboseName, "tabNumber": connectingTab }
                platformInterface.tabList.tabs[connectingTab].content.boardId = platformID
                platformInterface.tabList.tabs[connectingTab].tab.boardId = platformID
                platformInterface.tabList.nextTabToConnect++
                //available platform commands
                CorePlatformInterface.insertPlatformCommands(platformCommands,platformInterface.tabList.tabs[connectingTab].content.historyList)

            } else {
//                console.log("Core Plat Interface: Connecting to "+ verboseName)
                platformInterface.platformList[platformID].connected = connected
            }

            thisTab = platformInterface.platformList[platformID].tabNumber
            CorePlatformInterface.addColorizedRow(platformInterface.tabList.tabs[thisTab].content.logBoxList,"Platform "+ verboseName +" connected","black")

        } else {
            thisTab = platformInterface.platformList[platformID].tabNumber
            platformInterface.platformList[platformID].connected = connected
            CorePlatformInterface.addColorizedRow(platformInterface.tabList.tabs[thisTab].content.logBoxList, "Platform " + platformInterface.platformList[platformID].name + " disconnected","black")
        }

        platformInterface.statusImageUpdate()  // Hack solution to update the tab status light
    }
    catch (e) {
        if (e instanceof SyntaxError){
            console.log("PlatformConnectionChanged JSON is invalid, ignoring")
            console.log(payload)
        }
    }
}

// -------------------------
// Helper functions
//

function applyFilter(inputList,outputList,cmd) {
    outputList.clear()
    for( var i=0; i < inputList.count ; ++i )
    {
        if(JSON.stringify(inputList.get(i)).includes(cmd))
        {
            outputList.append(inputList.get(i))
        }
    }
}

function colorizeStringInList(inputList, key, color, outputList) {
    var colorRemoved
    var colorOfString
    outputList.clear()

    for ( var i=0; i < inputList.count ; ++i ) {

        colorRemoved = false;
        var string = JSON.stringify(inputList.get(i).status)
        string = cleanJSON(string)

        if (string.includes(key)) {
//            console.log(key + " found in string: " +string)

            if (string.includes("<font color")) {
                colorOfString = string.replace(/.*color='(#?[A-Za-z0-9]*)'.*/, "$1")  // pull out original color of string
                string = string.replace(/<(?:.|\n)*?>/gm, '')  // remove html tags bounded by <>
                colorRemoved = true;
//                console.log("COLOR REMOVED:", string, colorOfString)
            }

            string = string.replaceKeys(key,"<b><u><font color='"+ color +"'>"+ key +"</font></u></b>")
//            console.log("COMMAND HIGHLIGHTED:" +string)
        }

        if (colorRemoved) {
            outputList.set(i,{"status":"<font color='"+ colorOfString +"'>"+ string +"</font>"})
        } else {
            outputList.set(i,{"status":string})
        }
    }
}

function addColorizedRow(inputList,key,color) {
    key = key.replaceKeys(key,"<font color='"+color+"'>"+key+"</font>")
    inputList.append({ "status" : key})
}

function cleanJSON(string) {
    string = string.replace(/^"(.+)"$/,'$1')  // remove beginning and ending quote marks
    string = string.replace(/\\"/g, '"')      // remove '\' escape char from quote marks
    return string
}

String.prototype.replaceKeys = function(search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};

function addTabView() {
    var number = platformInterface.tabList.tabCount
    var content = newPlatformContent.createObject( platformContentContainer,{ "tabNumber": number } )
    var tab = newPlatformTab.createObject( tabBar, { "content": content, "tabNumber": number } )
    tabBar.addItem( tab )
    platformInterface.tabList.tabs.push( { "content": content, "tab": tab, "tabNumber": number } )

    platformInterface.tabList.tabCount++
}

function saveAndSendCommand(command) {
    var currentRowColor = "black"
    try {
        JSON.parse(command)
        cmdHistoryList.insert(0, { "status" : command })
        platformController.sendCommand(command, boardId)
    } catch(e) {
        currentRowColor = "red"
        CorePlatformInterface.addColorizedRow(logBoxList, "Invalid JSON Format:", currentRowColor)
    }

    CorePlatformInterface.addColorizedRow(logBoxList, command, currentRowColor)
}

function insertPlatformCommands(inputlist,outputlist) {
    console.log("PLATFORM COMMANDS\n====================================\n\n"+inputlist.length)

    for( var i=0; i < inputlist.length ; ++i )
    {
        console.log("test"+inputlist[i])
        outputlist.insert(i,{ "status" : inputlist[i]})
    }

}
