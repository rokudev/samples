## Overhang Markup

**Node Class Reference: Overhang**

The **Overhang** node class is designed to be integrated into an application as part of panel set, but can be used as a stand-alone node if you want the functionality it provides, such as displaying your company logo and the time at the top of the display screen. Let's take a quick look at an example that adds an **Overhang** node to a scene.

In the `overhangscene.xml` component file, we configure an **Overhang** node as a child node of a **Scene** node in the **<children>** element:

```
<children >
  <Overhang 
    title = "SceneGraph Examples" 
    showOptions = "true" 
    optionsAvailable = "true" />
</children>
```

We've mostly used the default **Overhang** node field values for this example. We did set the `showOptions` and `optionsAvailable` fields to true to display the **Options** message in the **Overhang** node. These fields are set to false by default, to allow you to selectively set the fields at times in your application, to indicate to the user that pressing the **Options** remote key will display a list of selectable options.

Note that by not setting the `logoUri` field, the default Roku logo is displayed. You'll want to set the `logoUri` field to the URI of your company logo image, with dimensions similar to the default Roku logo, in your application.

![img](https://sdkdocs.roku.com/download/attachments/4262988/overhangdoc.jpg?version=3&modificationDate=1472838656050&api=v2