## ButtonGroup Markup

**Node Class Reference:** **ButtonGroup**

The **ButtonGroup** node class allows to quickly create and configure a group  of several buttons that appear and operate in the same way as [**Button**](https://github.com/rokudev/samples/tree/master/ux%20components/widgets) node buttons.

The `buttongroupscene.xml` component file creates two buttons by simply setting the `buttons` field of a **ButtonGroup** node object created in the **<children>** element with the strings that appear on the buttons:

```
buttongroup.buttons = [ "OK", "Cancel" ]
```
The required focus on the **ButtonGroup** node is set using the `initialFocus` attribute of the **<component>** element. With the focus set on the **ButtonGroup** node, the buttons appear as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262981/buttongroupdoc.jpg?version=3&modificationDate=1472838052461&api=v2)

Note that the focus on each button is controlled by **Up** and **Down** remote keys as in a list node. And the index numbers of the buttons focused and selected also work like list nodes, with the top-most button being index 0 in the **ButtonGroup**node, the next button down is 1, and so forth (see [**Creating Lists and Grids**](https://developer.roku.com/docs/references/api-index/scenegraph/list-and-grid-nodes/overview.md) and [**Lists and Grids Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/lists%20and%20grids)). So you can set observers on the `buttonFocused` and `buttonSelected` **ButtonGroup** node fields, and handle those events in callback functions in much the same way you would with a list node.