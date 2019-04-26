## OverhangPanelSetScene Markup

**Node Class References:** **OverhangPanelSetScene**, **Panel**, **ListPanel**, **GridPanel**

We can conclude this section of the tutorial by showing a sliding panel example using the **OverhangPanelSetScene** node class, a special **Scene** node that integrates an **Overhang** node and a **PanelSet** node. The advantage of the **OverhangPanelSetScene** node class is the ability to configure the panels in your panel set to target sections of the **Overhang** node with custom appearance for each panel.

This example is almost identical to `PanelSetExample.zip` in [https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels). The three panel nodes in the **PanelSet** node are the same, except for some special fields that specifically target the integrated **Overhang** node.

The first difference you'll see in `overhangpanelsetscene.xml` is that there is no need to create a **PanelSet** node object, because the **PanelSet** node is integrated into the **OverhangPanelSetScene** node. So when you add panel nodes to the panel set, you just refer to the integrated **PanelSet** node using the `panelSet` field:

```
m.listpanel = m.top.panelSet.createChild("ListPanelExample")
...
m.panel = m.top.panelSet.createChild("PanelExample")
```

This is how you add or perform all other operations on the panel nodes in the integrated **PanelSet** node. This is also true of the integrated **Overhang** node; you refer to the **Overhang** node fields using the `Overhang` field:

```
m.top.Overhang.showOptions = true
```

This causes the **Options** message in the **Overhang** node to be displayed. Likewise, we can change the title of the **Overhang** node, and the appearance of the **Options** message, as each panel slides into view, by setting special fields in the panel nodes.

In this example, we wanted the **Options** message to be dimmed, to indicate that pressing the **Options** remote key would not provide a list of options to the user at this time. We also wanted to show a specific title, **SceneGraph Examples**:

![img](https://sdkdocs.roku.com/download/attachments/4262988/overhangpanelsetdoc.jpg?version=2&modificationDate=1472838792697&api=v2)

To do this, we set two special fields in the `listpanel.xml` component file **init()** function:

```
m.top.optionsAvailable = false
m.top.overhangTitle = "SceneGraph Examples"
```

These `optionsAvailable` and `overhangTitle` fields target the **Overhang** node `optionsAvailable` and `title` fields when the **ListPanel** node is visible on the screen. Likewise, we change the appearance of the **Overhang** node when the **GridPanel** node is visible, by setting the same fields to different values in the `gridpanel.xml` component file:

```
m.top.optionsAvailable = false
...
m.top.overhangTitle = m.top.overhangtext
```

The `overhangtext` field is set in the **GridPanel** node **<interface>** element, along with the `gridcontenturi` field:

```
<interface >
  <field id = "overhangtext" type = "string" />
  <field id = "gridcontenturi" type = "uri" onChange = "readpostergrid" />
</interface>
```

As the **OverhangPanelSetScene** node sets these fields for each focused item in the **ListPanel** node list, the **GridPanel** node and the **Overhang** node are configured as soon as the user selects the list item and the new panel slides into view:

![img](https://sdkdocs.roku.com/download/attachments/4262988/gridpanelopsdoc.jpg?version=2&modificationDate=1472838855164&api=v2)

Note that the **Overhang** node title has changed to **Renderable Node Markup**, if a user selects the **Renderable Nodes** item from the **ListPanel** node list.