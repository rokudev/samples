' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 

' Brightscript entry points: main or RunUserInterface
' - the argsAA parameter is an associative array used to pass arguments to the script
' - see complete list of argsAA fields here:
'   https://sdkdocs.roku.com/display/sdkdoc/Development+Environment+Overview#DevelopmentEnvironmentOverview-EntryPoints

Sub main(argsAA as Object)
	? "[Entry point] main"
	' Print channel arguments to the Brightscript console (telnet port 8085)
	' source is the path that channel was launched, eg "homescreen", "ad", "partner-button", etc.
	? "source= ", argsAA.source
	' lastExitOrTerminationReason is the exit code (actually a string) with exit info
	' the last time this channel was executed
	? "lastExitOrTerminationReason= ", argsAA.lastExitOrTerminationReason
	' mediaType and contentID are used for deep linking
	? "mediaType= ", argsAA.mediaType
	? "contentID= ", argsAA.contentID

    ' Create the Scenegraph screen (roSGScreen) and scene
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")

	' Create the message port, it is where messages/events are sent
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

	' Finally, show the scene
    screen.Show()    
    while true
	    ' Wait for events
        msg = wait(0, port)
        print "------------------"
	    ' Display the message received
        print "msg = "; msg
		
        msgType = type(msg)
		' Listen for events, see if screen is closed
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if

    end while
    
End Sub
