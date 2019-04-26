## ListPanel Markup

**Node Class References: ListPanel, PanelSet**

A **ListPanel** node adds support for a **LabelList** node (or other list node class) to be added and configured within a **Panel** node. It also adds important support for creating new panels automatically based on the user focus or selection of a list item.

We add a child **ListPanel** node to a **PanelSet** node exactly the same way as in [**Panel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels), so there is no particular reason to look at `panelsetscene.xml` in `ListPanelExample.zip`. And `listpanel.xml` is quite similar to the `panel.xml` in **Panel Markup**:

**ListPanel Node Configuration Example**

```
<component name = "ListPanelExample" extends = "ListPanel" >
  <script type = "text/brightscript" 
    <![CDATA[
    sub init()
      m.top.panelSize = "medium"
      m.top.focusable = true
      m.top.hasNextPanel = false
      m.top.leftOnly = true
      m.top.list = m.top.findNode("exampleLabelList")
    end sub
    ]]>
  </script>
  
  <children>
    <LabelList id = "exampleLabelList" >
      <ContentNode role = "content" >
        <ContentNode title = "Renderable Nodes" />
        <ContentNode title = "Z-Order/Parent-Child" />
        <ContentNode title = "Animations" />
        <ContentNode title = "Events and Observers" />
      </ContentNode>
    </LabelList>
  </children>
</component>
```

Again we set the size of the list panel node to medium, but now some of the other panel node fields are more important. We'll want to set the `focusable` field to true, so the user will be able to use the list. Since we only add the one child **ListPanel** node to the **PanelSet** node, we still set the `hasNextPanel` field to false...but for a **PanelSet** node that includes a dynamic and varying number of child panel nodes, this is one of several fields that becomes very important, like the `leftOnly` field (which has no function in this example).

But the biggest difference is adding a **LabelList** node to the **ListPanel** node. In the example, a simple **LabelList** node is configured in the **<children>** element. Then we add the **LabelList** node in the **<script>** element by setting the **ListPanel**node `m.top.list` field to the **LabelList** node object:

```
m.top.list = m.top.findNode("exampleLabelList")
```

And the result is like **Panel Markup**, except with the list integrated into the panel node in the default **PanelSet** node left position:

![img](https://sdkdocs.roku.com/download/attachments/4262988/listpaneldoc.jpg?version=3&modificationDate=1472838418460&api=v2)

Note that the **LabelList** node is automatically sized and placed into the **ListPanel** node, one of several automatic operations that are part of the **ListPanel** node.