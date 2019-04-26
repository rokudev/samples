#Rectangle Markup

The **Rectangle** node class is the simplest node to define using XML markup. A **Rectangle** node just draws a rectangular shape of a certain size on the display screen at a particular location. Because it is so simple, it's a great node class example to show how Roku SceneGraph XML markup is done.

In the `components/rectanglescene.xml` component file, we create and show a simple rectangular shape:

The following are the important parts of this example that apply to all SceneGraph component XML markup:

- Per standard XML practice, the XML declaration prolog is placed at the top:

  ```
  <?xml version = "1.0" encoding = "utf-8" ?>
  ```

- The *component* to be defined and created in the XML file is named, and the class name the component is to be derived from is specified, in the **<component>** XML element:

```
<component name = "component_name" extends = "node_class_name" >
  <XML_element >
    element_definition
  </XML_element>
 
  <children>
 
    <Scene_Graph_node_1  
      node_1_field_1 = "field_1_definition"
             ... />
    <Scene_Graph_node_2 
      node_2_field_1 = "field_1_definition"
      ... />
 
    ...
 
  </children>

```

In the above example, the component to be created is named `RectangleExample` (`component name = "RectangleExample`"), which is extended from the **Scene** node class (`extends = "Scene"`). The example also includes a **<script>** element to include BrightScript code that:

- sets a background image for the component display screen
- centers the example in the display screen
- sets the remote control focus on a node or component in the component

```
</component>
<script type = "text/brightscript" >
  <![CDATA[
  sub init()
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    example = m.top.findNode("exampleRectangle")
    examplerect = example.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    example.translation = [ centerx, centery ]
    m.top.setFocus(true)
  end sub
  ]]>
</script>
```

In this case, all of the BrightScript code is included in the **init()** function, which is used to set initial values for a component. This is typical practice for most SceneGraph XML markup. See [**SceneGraph XML Reference**](https://developer.roku.com/docs/references/scenegraph/core-concepts.md), specifically **<script>**, and [**init()**](https://developer.roku.com/docs/references/api-index/scenegraph/component-functions/init.md), for more information.

Next, there is a **<children>** element. This is added to make XML schema validation (if used) work using an XSD file. XSD validation requires that the order of elements be deterministic, and thus for validation to work, SceneGraph node elements need to be wrapped in an element themselves.

Finally, the **Rectangle** node itself is defined as follows:

- The rectangle is given an ID of `exampleRectangle`, to allow the node to be targeted by non-renderable nodes (such as **Animation** node classes) and BrightScript code:

**id = "exampleRectangle"**

- The width of the rectangle is set to 512 pixels, which is designed to occupy a certain portion of an HD (1280x720) UI resolution display space:

**width = "512"**

- Likewise, the height of the rectangle is set to 288, for a certain size in an HD display space (if the application is running in a FHD (1920x1080) UI resolution, the rectangle will be automatically scaled 1.5 times to occupy the same relative screen space):

**height = "288"**

- The color of the rectangle is set to blue:

**color = "0x1010EBFF"**

And the result on the display screen is:

![img](https://sdkdocs.roku.com/download/attachments/1606014/rectangledoc.jpg?version=2&modificationDate=1472835365414&api=v2)