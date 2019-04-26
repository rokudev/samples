## KeyboardDialog Markup

**Node Class Reference: Keyboard**

The **KeyboardDialog** node class shows a dialog with an internal **Keyboard** node. The obvious use for a **KeyboardDialog** node is when you need a user to enter some type of alphanumeric information in the application. When this condition occurs in your application, call something like `showdialog()` in `keyboarddialogscene.xml`:

```
sub showdialog()
  keyboarddialog = createObject("roSGNode", "KeyboardDialog")
  keyboarddialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
  keyboarddialog.title = "Example Keyboard Dialog"
  m.top.dialog = keyboarddialog
end sub
```

The `showdialog()` function above configures the **KeyboardDialog** node dialog to appear as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262970/keyboarddialogdoc.jpg?version=2&modificationDate=1472838275003&api=v2)

For this example, we just set a custom background and a title for the **KeyboardDialog** node object. In a typical application, you might want to add a button to the dialog to allow the user to inform the application that the alphanumeric text entry is complete, and have the application dismiss the dialog and get the entered alphanumeric string when the button is pressed, as described in [**PinDialog Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs). You can also configure aspects of the internal **Keyboard** node by referring to the dialog object `keyboard` field.

Also note that the internal **Keyboard** node uses the **Options** remote key to toggle a "caps lock" operation to make entering mixed-case strings easier.