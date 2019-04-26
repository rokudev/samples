## BusySpinner Markup

**Node Class Reference: BusySpinner**

Roku SceneGraph provides indicators in many of the built-in node classes that a time-consuming operation is occurring in the application; for example, the internal **ProgressBar** nodes in the [**Video**](https://github.com/rokudev/samples/tree/master/media) node class to let the user know that a little time is required to download enough of the video file to begin streaming playback. But in some cases you may need a progress indicator for a custom markup component operation.

The **BusySpinner** node class lets you add such a progress indicator anywhere in your application. But positioning the busy spinner in a scene or other component requires that the graphic image you use for the spinner be downloaded first, so the size of the spinner is known.

This is shown in the `busyspinnerscene.xml` component file, where we use an observer on the internal **Poster** node `loadStatus` field to trigger a callback function that positions the **BusySpinner** node: 

**BusySpinner Node Example**

```
<component name = "BusySpinnerExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      m.busyspinner = m.top.findNode("exampleBusySpinner")
      m.busyspinner.poster.observeField("loadStatus", "showspinner")
      m.busyspinner.poster.uri = "pkg:/images/busyspinner.png"
 
      m.top.setFocus(true)
    end sub
 
 
    sub showspinner()
      if(m.busyspinner.poster.loadStatus = "ready")
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapWidth) / 2
        m.busyspinner.translation = [ centerx, centery ]
 
        m.busyspinner.visible = true
      end if
    end sub
 
    ]]>
 
  </script>
 
  <children >
 
    <BusySpinner
      id = "exampleBusySpinner"
      visible = "false" />
 
  </children>
 
</component>
```

We create the **BusySpinner** node in the **<children>** element of the XML component file, but don't perform any important configuration there, except we do make the spinner initially invisible by setting the `visible` field to false. The important configuration takes place in the **init()** function in the **<script>** element, where we set the location of the graphic image to be used for the busy spinner as the value of the `uri` field of the internal **Poster** node. We set an observer on the `loadStatus` field of the internal **Poster** node to trigger the `showspinner()` callback function if any changes occur in the field.

The `showspinner()` function waits until the `loadStatus` field value is `ready`, then positions the spinner in the **Scene** node, finally setting the value of the **BusySpinner** node `visible` field to true. The result is as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262928/busyspinnerdoc.jpg?version=3&modificationDate=1472837660588&api=v2)

In a real application, you'd want to create and position a **BusySpinner** node component before beginning a time-consuming operation, and remove the spinner when the time-consuming operation has completed, ideally in a callback function triggered by an observed field set by the operation when complete.

> You can also use the [**ProgressDialog**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs) node for many of the same purposes as the **BusySpinner** node. The **ProgressDialog** node shows a modal dialog that includes an internal **BusySpinner** node, and can display a message explaining the time-consuming operation to the user. See [**ProgressDialog Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/dialogs) for an example of the **ProgressDialog** node.