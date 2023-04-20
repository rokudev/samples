' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[HomeScreen] Init"

	setupHomeScreen()
End Function

Function setupHomeScreen()
	m.title = m.top.findNode("title")
	m.title.text = "Home screen"

	m.description = m.top.findNode("description")
	m.description.text = "This is the home screen of the sample channel. The home screen is the only screen in the home scene and contains two labels: the title (above) and this description. It also has a rectangle, the posters are part of the scene."

    setupHomeRowlist()
End Function

' The channel will need to retrieve content for the rowlist that will
' populate the samples in the rowlist. The channel will also have custom
' behavior on focusing and selecting items within the rowlist.
Function setupHomeRowlist()
    m.rowlist = m.top.findNode("myRowList")
    m.rowlist.content = createObject("roSGNode", "SampleContent")
    m.rowlist.observeField("rowItemFocused", "onChangeItemFocus")
    m.rowlist.observeField("rowItemSelected", "onItemSelect")
    m.rowlist.setFocus(true)
end Function

' When focusing on an item in the rowlist, the channel will change the title
' label and the description to match what row (e.g. category) is being focused.
Function onChangeItemFocus()
    update = false

    if m.currentRow = invalid
        m.currentRow = m.rowlist.rowItemFocused[0]
        update = true
    else if not (m.currentRow = m.rowlist.rowItemFocused[0])
        m.currentRow = m.rowlist.rowItemFocused[0]
        update = true
    end if

    if update
        item = m.rowlist.content.getChild(m.currentRow)
        m.title.text = item.title
        m.description.text = item.description
    end if
end Function

' When selecting an example from the rowlist, the channel will attempt
' to create the sample and display it on screen. At the same time, the
' channel will hide the title, description, and rowlist items to not
' interfere with the sample being displayed. If the sample could not be
' created, an error message will display in the brightscript debug console
' stating that the example was not implemented.
'
' The exception is for Dialog items, as those are related to setting the
' dialog field of the scene to one of the built-in Dialog nodes.
Function onItemSelect()
    m.currentRow = m.rowlist.rowItemSelected[0]
    m.currentColumn = m.rowlist.rowItemSelected[1]
    item = m.rowlist.content.getChild(m.currentRow).getChild(m.currentColumn)

    if item.id = "DialogExample"
        dialogExample = createObject("roSGNode", "Dialog")
        dialogExample.title = "Example Dialog"
        dialogExample.optionsDialog = true
        dialogExample.message = "Press back or * button to dismiss"

        m.top.getScene().dialog = dialogExample
    else if item.id = "PinDialogExample"
        pinDialogExample = createObject("roSGNode", "PinDialog")
        pinDialogExample.title = "Example PinDialog"

        m.top.getScene().dialog = pinDialogExample
    else if item.id = "KeyboardDialogExample"
        keyboardDialogExample = createObject("roSGNode", "KeyboardDialog")
        keyboardDialogExample.title = "Example KeyboardDialog"

        m.top.getScene().dialog = keyboardDialogExample
    else if item.id = "ProgressDialogExample"
        progressDialogExample = createObject("roSGNode", "ProgressDialog")
        progressDialogExample.title = "Example ProgressDialog (wait 5 seconds)"

        m.timer = createObject("roSGNode", "Timer")
        m.timer.duration = 5
        m.timer.observeField("fire", "closeDialog")
        m.timer.control = "start"

        m.top.getScene().dialog = progressDialogExample
    else
        m.example = createObject("roSGNode", item.id)

        ' There is another exception to the rule listed above this function,
        ' which is for the Panel, ListPanel, and GridPanel examples. They need
        ' a PanelSet component in order to contain the panels for the examples,
        ' so we create a PanelSet component and append the example to the Panelset
        ' component. These examples are extended from their respective components
        ' that will be exampled (can see this in their example files).
        if m.example <> invalid
            if item.id = "PanelExample" or item.id = "ListPanelExample" or item.id = "GridPanelExample"
                m.panelSet = m.top.createChild("PanelSet")
                m.example.id = item.id
                m.panelSet.appendChild(m.example)
            else
                ' For the Overhang example, in order to see the items in the Overhang
                ' component, we need to get the scene's posters and make them not visible
                ' in order for the Overhang example to be clearly visible.
                if item.id = "OverhangExample"
                    m.example.id = item.id
                    m.top.getScene().findNode("RokuLogoPoster").visible = false
                    m.top.getScene().findNode("RokuDevPoster").visible = false
                end if
                m.top.appendChild(m.example)
            end if

            m.rowlist.visible = false
            m.title.visible = false
            m.description.visible = false

            m.example.visible = true
            m.example.setFocus(true)
        else
            ? "ERROR: example not implemented!"
        end if
    end if
end Function

' There are two cases that we are concerned in HomeScreen:
'
'    1) If the user presses the "back" button when a sample is displayed,
'       the channel will remove the sample from the HomeScreen object,
'       delete the sample (set m.example to "invalid"), and display the
'       title, description, and rowlist. This will bring the user back
'       to the home screen.
'
'    2) If the user presses the "back" button when the home screen is
'       displayed (no sample is shown), pass the event back up to the
'       scene. This is done by returning "false".
Function onKeyEvent(key as String, press as Boolean)
    handled = false

    if press
        if key = "back"
            if m.example <> invalid and not m.rowlist.hasFocus()
                ? "Removing example from screen..."
                ' For the Panel, ListPanel, and GridPanel examples, we need to remove
                ' the example from the PanelSet container created in onItemSelect() and
                ' then remove/invalidate the PanelSet component.
                if m.example.id = "PanelExample" or m.example.id = "ListPanelExample" or m.example.id = "GridPanelExample"
                    m.panelSet.removeChild(m.example)
                    m.panelSet = invalid
                else
                    ' For the Overhang example, we need to make the scene's posters visible
                    ' (made not visible in onItemSelect()).
                    if m.example.id = "OverhangExample"
                        m.top.getScene().findNode("RokuLogoPoster").visible = true
                        m.top.getScene().findNode("RokuDevPoster").visible = true
                    end if
                    m.top.removeChild(m.example)
                end if
                m.example.visible = false
                m.example = invalid

                m.title.visible = true
                m.description.visible = true
                m.rowlist.visible = true
                m.rowlist.setFocus(true)

                handled = true
            end if
        end if
    end if

    return handled
end Function

' This will only get triggered on the ProgressDialog example, since
' this will close out the dialog box that displays in the scene.
Function closeDialog()
    m.timer.unobserveField("fire")
    m.timer = invalid

    m.top.getScene().dialog.close = true
end Function