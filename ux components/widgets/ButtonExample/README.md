## Button Markup

**Node Class Reference:** [**Button**]

The **Button** node class allows you to add a button to your application. The `buttonscene.xml` component file adds a button simply by creating and configuring the **Button** node object in the **<children>** element of an XML component file:

```
<children >

  <Button
    id = "exampleButton"
    text = "Example Button"
    showFocusFootprint = "true"
    minWidth = "240" />

</children>
```

This example mostly uses the default configuration for a **Button** node, with a few exceptions. The `text` field sets the string that will be used for the button, and is usually required so the user can know the operation that will occur if the button is selected by pressing the **OK** remote key. The `showFocusFootprint` is not required, but provides a visual indication as to whether the button is focused or not. And the `minWidth` field sets the minimum width of the button (which may be larger depending on the length of the string set as the value of the `text` field). For the user to use the button, the focus must be set on the **Button** node. In this example, that is done using the `initialFocus` attribute of the **<component>** element. All the remaining code in the `buttonscene.xml` component file just centers the button in the **Scene** node, resulting in the following:

![img](https://sdkdocs.roku.com/download/attachments/4262928/buttondoc.jpg?version=3&modificationDate=1472837618805&api=v2)

In a real application, you'll want to set an observer on the `buttonSelected` field, to trigger a callback function that performs the operation selected by the user.



> To add a group of several buttons to your application, see [**ButtonGroup Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/widgets).