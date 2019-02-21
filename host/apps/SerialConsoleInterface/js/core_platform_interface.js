
function newBoardConnected(connection_id, verboseName) {

    // If there is no entry for this platform, it is connecting for the first time and needs init
    if(!platformInterface.platformList[connection_id]) {

        var tabNum = platformInterface.tabList.nextTabToConnect

        // If new platform, and new tab not yet existing, create tab
        if (platformInterface.tabList.tabCount === platformInterface.tabList.nextTabToConnect) {
            tabNum = addTabView()
        }

        platformInterface.platformList[connection_id] = { "connected": "true", "name": verboseName, "tabNumber": tabNum }
        platformInterface.tabList.tabs[tabNum].content.boardId = connection_id
        platformInterface.tabList.tabs[tabNum].tab.boardId = connection_id
        platformInterface.tabList.nextTabToConnect++

        //available platform commands
//TODO:        CorePlatformInterface.insertPlatformCommands(platformCommands,platformInterface.tabList.tabs[connectingTab].content.historyList)

    } else {

        platformInterface.platformList[connection_id].connected = true
    }

    var tabNumber = platformInterface.platformList[connection_id].tabNumber
    CorePlatformInterface.addColorizedRow(platformInterface.tabList.tabs[tabNumber].content.logBoxList,"Platform "+ verboseName +" connected","black")

    platformInterface.statusImageUpdate()  // Hack solution to update the tab status light
}

function boardDisconnected(connection_id) {

    var tabNumber = platformInterface.platformList[connection_id].tabNumber
    platformInterface.platformList[connection_id].connected = false

    //TODO add if statement when the tab was closed.
    CorePlatformInterface.addColorizedRow(platformInterface.tabList.tabs[tabNumber].content.logBoxList, "Platform " + platformInterface.platformList[connection_id].name + " disconnected","black")

    platformInterface.statusImageUpdate()  // Hack solution to update the tab status light
}

function boardMessage(connection_id, message) {
    if(!platformInterface.platformList[connection_id]) {
        return
    }

    var tabNumber = platformInterface.platformList[connection_id].tabNumber
    platformInterface.tabList.tabs[tabNumber].content.logBoxList.append({ "status" : message})
}

function sendCommand(connection_id, command) {

    boardsMgr.sendCommand(connection_id, command)

    CorePlatformInterface.addColorizedRow(logBoxList, command, "black")
    cmdHistoryList.insert(0, { "status" : command , type : "previous"})
}

function notificationHandler (notification, platformID) {
    var tabNumber = platformInterface.platformList[platformID].tabNumber
    platformInterface.tabList.tabs[tabNumber].content.logBoxList.append({ "status" : notification})
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

    return number
}

function checkCommand(command) {
    try {
        JSON.parse(command)
    } catch(e) {
        var currentRowColor = "red"
        CorePlatformInterface.addColorizedRow(logBoxList, "Invalid JSON Format:", currentRowColor)
        CorePlatformInterface.addColorizedRow(logBoxList, command, currentRowColor)

        return false
    }
    return true
}

function insertPlatformCommands(inputlist,outputlist) {
    console.log("PLATFORM COMMANDS\n====================================\n\n"+inputlist.length)

    for( var i=0; i < inputlist.length ; ++i )
    {
        console.log("test"+inputlist[i])
        outputlist.insert(i,{ "status" : inputlist[i], type : "platform"})
    }

}
