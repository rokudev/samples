## PinPad Markup

**Node Class Reference: PinPad**

The **PinPad** node class supplies a widget that lets users enter a numeric personal identification or other type of verification number.

This example creates a **PinPad** node object in the **<children>** element of the `pinpadscene.xml` component file. The **PinPad** node uses default values, except for the number of digits in the verification number, which is set to 6 rather than the default value of 4 in the `pinLength` field:

```
<children >
  <PinPad
    id = "examplePinPad"
    pinLength = "6" />
</children>
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/4262928/pinpaddoc.jpg?version=3&modificationDate=1472837814976&api=v2)

In a real application, you would want to group the **PinPad** node with a button to allow the user to inform the application that the verification number entry is complete. Ideally, you should write a callback function to perform the application operations related to the verification number entry, triggered by an observer on the **Button** node `buttonSelected` field.

> You can also use the [**PinDialog**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs) node to show a modal dialog with an internal **PinPad** node. The **PinDialog** node lets you add buttons to the dialog to allow the user to inform the application that the verification number entry is complete (and possibly to cancel the number entry), and can display a message explaining the verification number entry to the user. See [**PinDialog Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs) for an example of the **PinDialog** node.