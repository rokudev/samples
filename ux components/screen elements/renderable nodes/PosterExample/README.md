# Poster Markup

The **Poster** node class draws a graphic image file in a specified location on the display screen. `PosterExample.zip` draws the `videopg.jpg` graphic image file located on our SDK development server:

```
`<Poster ` `  id = "examplePoster" ` `  width = "512" ` `  height = "288" ` `  uri = "http://sdktestinglab.com/Tutorial/images/videopg.jpg" />`
```

This simple example shows close to the minimum amount of markup required to draw a graphic image file on the screen:

- Again, if we ever want to target this node with another node class or BrightScript code, we assign an ID for the node:

  id = "examplePoster"

- In this case, we set the width and height of the image to be drawn on the screen to the pixel width and height of the graphic image file itself, which is generally the best way to draw the clearest image on the screen (though the **Poster** node class does include automatic scaling for image size specifications that do not match the pixel dimensions of the graphic image file, and by default, if `width` and `height` field values are set to 0, the image is drawn to the pixel width and height of the graphic image file itself after the image is loaded):

  `width = "512" ``height = "288"`

- Of course, we need to specify the URI path to the graphic image file (this could be any valid URI including a file from the package `images` directory):

  uri = "<http://sdktestinglab.com/Tutorial/images/videopg.jpg>"

And the result on the display screen is:

![img](https://sdkdocs.roku.com/download/attachments/1606014/posterdoc.jpg?version=2&modificationDate=1472835597888&api=v2)

There are several more fields that could have been set for this image to control both the scale and the opacity of the image. But for now, we will'll just get the image on the screen, and the **Poster** node class reference has complete information on all the fields that could have been set.