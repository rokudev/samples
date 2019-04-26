## Dialog Markup

**Node Class Reference: Dialog**

Showing a modal dialog in a Roku SceneGraph **Scene** node is simple:

1. Create a dialog node object
2. Configure the dialog node object
3. Set the **Scene** node `dialog` field to the dialog node object

The dialog is dismissed if the user presses the **Back** remote key (or in some cases, also the **Options** key), or if the dialog object `close` field is set to true.

The **Dialog** node class is your basic message dialog. You can make this dialog appear whenever a condition exists in the application that you want to convey to the user. The dialog appears, the application screen is dimmed, and the application stops until the user dismisses the dialog.

In this example, and in the remaining dialog node class examples, we'll cause the dialog to appear when the **OK** remote key is pressed, just to simulate an initiating condition. In a real application, the condition that causes the dialog to appear could be anything you want to convey to the user. When the condition occurs, you can call a function similar to `showdialog()` in `dialogscene.xml`:

**Basic Message Dialog Example**

```
<component name = "DialogExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
      example = m.top.findNode("instructLabel")
      examplerect = example.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      example.translation = [ centerx, centery ]
      m.top.setFocus(true)
    end sub
 
    sub showdialog()
      dialog = createObject("roSGNode", "Dialog")
      dialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
      dialog.title = "Example Dialog"
      dialog.optionsDialog = true
      dialog.message = "Press * To Dismiss"
      m.top.dialog = dialog
    end sub
 
    function onKeyEvent(key as String, press as Boolean) as Boolean
      if press then
        if key = "OK"
          showdialog()
          return true
        end if
      end if
      return false
    end function
    ]]>
  </script>
  <children >
    <Label
      id = "instructLabel"
      text = "Press OK For Dialog" />
  </children>
</component>
```

Note that most of the code in the component is there just to create and center a **Label** node with an instruction to press the **OK** remote key to show the dialog. Then we use an **onKeyEvent()** function to call `showdialog()` when the **OK** key is pressed:

```
sub showdialog()`
`  dialog = createObject("roSGNode", "Dialog")`
`  dialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"`
`  dialog.title = "Example Dialog"`
`  dialog.optionsDialog = true`
`  dialog.message = "Press * To Dismiss"`
`  m.top.dialog = dialog`
`end sub
```

Again, the first step to show a dialog is to create a dialog node object, in this case, creating a **Dialog** node class object. The next step is configure the dialog node object. In this example, we set a custom background for the dialog, by setting the `backgroundUri` field to the location of a custom 9-patch PNG graphic image. Then we configure the dialog title by setting the string to be used as the value of the `title` field. We want users to be able to dismiss this dialog by pressing the **Options** remote key in addition to the default **Back** key, so we set the `optionsDialog` field value to true. And finally, we add the message we want to convey to users by setting the `message` field value to the string to be used (this example does not have much of a message, just a reminder that the **Options** remote key can be used to dismiss the dialog).

So if you press the **OK** remote key as instructed, this is the dialog that is shown:

![img](https://sdkdocs.roku.com/download/attachments/4262970/dialogdoc.jpg?version=2&modificationDate=1472838198183&api=v2)