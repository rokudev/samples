## Keyboard Markup

**Node Class Reference: Keyboard**

The **Keyboard** node class allows full case-sensitive alphanumeric string user input, including punctuation and special characters.

Like the example **MiniKeyboard** node, the **Keyboard** node is created in the **<children>** element in `keyboardscene.xml` with no custom field settings:

```
<children >
  <Keyboard id = "exampleKeyboard" />
</children>
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/4262928/keyboarddoc.jpg?version=3&modificationDate=1472837915754&api=v2)

In a real application, you would probably want to group the **Keyboard** node with a **Button** node (or possibly a **ButtonGroup** node) to allow the user to inform the application that the string entry is complete (or possibly canceled). Ideally you should write a callback function to perform the operation that requires the string, triggered by an observer on the **Button** node `buttonSelected` field.

> You can also use the **KeyboardDialog** node to show a modal dialog with an internal **Keyboard** node. The **KeyboardDialog** node lets you add buttons to the dialog to allow the user to inform the application that the string entry is complete (and possibly to cancel the entry), and can display a message explaining the string entry to the user. See [**KeyboardDialog Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs) for an example of the **KeyboardDialog** node.