## PinDialog Markup

**Node Class Reference:** **PinDialog**, **PinPad**

The **PinDialog** node class shows a dialog with an internal **PinPad** node. The obvious use for a **PinDialog** node is when you need a user to enter a personal identification number (or some other numeric verification number) in the application. When this condition occurs in your application, call something like `showdialog()` in `pindialogscene.xml`:

```
sub showdialog()
  pindialog = createObject("roSGNode", "PinDialog")
  pindialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
  pindialog.title = "Example PinPad Dialog"
  m.top.dialog = pindialog
end sub
```

The `showdialog()` function above configures the **PinDialog** node dialog to appear as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262970/pindialogdoc.jpg?version=3&modificationDate=1472838246126&api=v2)

For this example, we just set a custom background and a title for the **PinDialog** node object. In a typical application, you would want to add a button to the dialog to allow the user to inform the application that the number is complete, and have the application dismiss the dialog and get the entered number, when the button is pressed. The best way to do this is to set an observer on the **Button** node `buttonSelected` field to trigger a callback function that dismisses the dialog by setting the dialog object `close` field to true:

```
sub dismissdialog()
  m.userpin = m.top.dialog.pin 
  m.top.dialog.close = true
end sub
```

You can also configure aspects of the internal **PinPad** node by referring to the dialog object `pinPad` field. For example, to set the PIN length to six digits rather than the default four digits:

```
pindialog.pinPad.pinLength = 6
```

> For the **PinDialog** node, the **Options** remote key toggles a privacy setting that hides the number focused in the PIN pad, and there is a message about this included by default in the dialog. You should *not* override this default behavior to ensure maximum security for your users.