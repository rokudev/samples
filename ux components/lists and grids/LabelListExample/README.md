## [LabelList Markup]
**Node Class Reference: LabelList**

The **LabelList** node class shows a list of selectable string items arranged vertically, with several formatting and display options. The strings for the **LabelList** node must be set in a **ContentNode** node, with the string for each item set as [**Content Meta-Data**](https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md) `title` attribute in a child **ContentNode** node. The **ContentNode** node object is set as the value of the **LabelList** node `content` field to configure and display the list. Each item can be focused by pressing the **Up** and **Down** remote keys, and an item can be selected by pressing the **OK**key.

`LabelListExample.zip` shows the simplest default configuration possible. The **LabelList** node is created in the **<children>** element of the `labellistscene.xml` file as seen in the following example:

```
<children >
  <LabelList id = "exampleLabelList" >
    <ContentNode role = "content" >
      <ContentNode title = "Renderable Nodes" />
      <ContentNode title = "Z-Order/Parent-Child" />
      <ContentNode title = "Animations" />
      <ContentNode title = "Events and Observers" />
    </ContentNode>
  </LabelList>
</children>
```

The example uses the XML `role` attribute of the **ContentNode** node defined as a child of the **LabelList** node, to assign the **ContentNode** node to the `content` field of the **LabelList**node. The result is as follows, with the currently-focused item identified by a focus indicator graphic under the item string in an inverse font color:

![img](https://sdkdocs.roku.com/download/attachments/4266149/labellistdoc.jpg?version=1&modificationDate=1498664216124&api=v2)

In most cases, the **ContentNode** node for the **LabelList** node will be downloaded as **Content Meta-Data** attributes for the list items from an XML or JSON (or equivalent) file from your server, then converted to a **ContentNode** node by your application. Note that you can include as many **Content Meta-Data** attributes in the **ContentNode** node for your **LabelList** node as you have available on your server and database, but only the `title` attribute is actually used for configuration of the list. The extra attributes can be used in other parts of your application as described later in this tutorial, for additional information to allow the user to select an item, and for media playback configuration for video-on-demand applications. The purpose of the **LabelList** node is to allow user to focus and select an item, and then have the application be able to use all the **Content Meta-Data** attributes for the item.

In a complete application, you will set observers on the **LabelList** node `itemFocused` and `itemSelected` fields, to trigger callback functions that perform operations related to the item focus and select events. You'll see how to do this later in this tutorial.

The **LabelList** node has several appearance and configuration options available.