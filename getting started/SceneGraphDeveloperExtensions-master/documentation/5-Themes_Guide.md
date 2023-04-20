# Theme attributes for views

SceneGraph Developer Extensions (SGDEX) support customizing elements in
the views.

## Using the theme attributes

  - Set theme attributes at the start of a channel in
    the Show(args) function.

  - Do not set global theme attributes before opening each view.

  - To change one attribute, use the updateTheme field to specify only
    the attribute that needs to be changed.

  - Set theme attributes and update attributes as one block so that
    multiple theme updates are not triggered.

  - Theme attributes are only used by SGDEX views, and not by any other
    RSG nodes.

There are three ways to customize the appearance of a view:

### Global theme parameters

Setting the theme attribute to all the SGDEX views:

~~~~
scene.theme = {
    global: {
        textColor: "FF0000FF"
        backgroundColor: "00FF00FF"
    }
}
~~~~

The code above sets the text color to RED for all the supported text in
the views. The background color for the views is set to GREEN.

### View type-specific attributes

To set the background of all the views a specific color but have the
background of the grid set to another color, use:

~~~~
scene.theme = {
    global: {
       backgroundColor: "00FF00FF"
    }
    gridView: {
       backgroundColor: "FF0000FF"
    }
}
~~~~

Here, the views have a GREEN background, and the grids have a RED
background.

### Instance-specific attributes

Since each view has its own theme field, to set view specific attributes
using the theme field.

**Note:** Only set fields that are different from the ones set in the
scene.

For all the views to have the same background with only one details
screen having a different background color, use:

~~~~
scene.theme = {
    global: {
        backgroundColor: "00FF00FF"
    }
}
view = CreateObject("roSgNode", "DetailsView")
view.theme = {
    backgroundColor: "FFFFFFFF"
}
~~~~

Here, all the views have a GREEN background except one details screen
which has a WHITE background.

## Updating theme attributes

The channel might need to update their branding on the current view or
next view when a user takes an action. For example, when a user logs in
to the channel, the logo might be changed. In such cases, the best
approach is to update just one field; baseScene and SGDEX
views have updateTheme field for such instances. The developer can use
it to change/set any theme attribute.

UpdateTheme has the same syntax as theme.

For instance, if the overhang logo needs to be changed for the all
channels after login, use the code below:

~~~~
sub OnLoginSuccess()
    scene = m.top.getScene()
    scene.updateTheme = {
 
        global: {
            OverhangLogoUri: "new logo url"
        }
    }
end sub 
~~~~

## Theme attributes Index

### Common theme attributes

<table>
<thead>
<tr class="header">
<th><strong>Attribute</strong></th>
<th><strong>Use</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>textColor </td>
<td>Sets the text color for all supported labels</td>
</tr>
<tr class="even">
<td>focusRingColor</td>
<td>Sets focus on the ring color</td>
</tr>
<tr class="odd">
<td>progressBarColor </td>
<td>Sets color to the progress bars</td>
</tr>
<tr class="even">
<td>backgroundImageURI </td>
<td>Sets a URL for a background image</td>
</tr>
<tr class="odd">
<td>backgroundColor</td>
<td>Sets background color</td>
</tr>
<tr class="even">
<td>OverhangTitle</td>
<td>Sets the text displayed in the overhang title</td>
</tr>
<tr class="odd">
<td>OverhangTitleColor</td>
<td>Sets the color of the overhang title</td>
</tr>
<tr class="even">
<td>OverhangShowClock</td>
<td>Sets the toggle showing the overhang clock</td>
</tr>
<tr class="odd">
<td>OverhangShowOptions</td>
<td>Shows the options in the overhang</td>
</tr>
<tr class="even">
<td>OverhangOptionsAvailable</td>
<td><p>Indicates if options are available in the overhang</p>
<p> <strong>Note:</strong> This is a visual field only </p></td>
</tr>
<tr class="odd">
<td>OverhangVisible</td>
<td>Sets if the overhang should be visible   </td>
</tr>
<tr class="even">
<td>OverhangLogoUri </td>
<td>Sets the URL for the overhang logo</td>
</tr>
<tr class="odd">
<td>OverhangBackgroundColor</td>
<td>Sets the overhang background color</td>
</tr>
<tr class="even">
<td>OverhangBackgroundUri</td>
<td>Sets the overhang background URL</td>
</tr>
<tr class="odd">
<td>OverhangOptionsText</td>
<td>Sets the text that is displayed in options</td>
</tr>
<tr class="even">
<td>OverhangHeight</td>
<td>Sets the height of the overhang</td>
</tr>
</tbody>
</table>

###   
GridView theme attributes

| **Attribute**       | **Use**                                                  |
| ------------------- | -------------------------------------------------------- |
| textColor           | Sets the color of all the text elements in the view      |
| focusRingColor      | Sets the color of the focus ring                         |
| focusFootprintColor | Sets the color of the focus ring when it is unfocused    |
| rowLabelColor       | Sets the color of the row title                          |
| itemTextColorLine1  | Sets the color of the first row in the item description  |
| itemTextColorLine2  | Sets the color of the second row in the item description |
| titleColor          | Sets the color of the title                              |
| descriptionColor    | Sets the color of the description text                   |
| descriptionmaxWidth | Sets the maximum width for the description               |
| descriptionMaxLines | Sets the maximum lines allowed for the description       |

###   
DetailsView theme attributes

| **Attribute**                  | **Use**                                               |
| ------------------------------ | ----------------------------------------------------- |
| textColor                      | Sets the color of all the text elements in the view   |
| focusRingColor                 | Sets the color of the focus ring                      |
| focusFootprintColor            | Sets the color of the focus ring when it is unfocused |
| rowLabelColor                  | Sets the color of the row title                       |
| descriptionColor               | Sets the color of the descriptionLabel                |
| actorsColor                    | Sets the color of the actorsLabel                     |
| ReleaseDateColor               | Sets the color of the ReleaseDate label               |
| RatingAndCategoriesColor       | Sets the color of categories                          |
| buttonsFocusedColor            | Sets the color of the focused buttons                 |
| buttonsUnFocusedColor          | Sets the color of the unfocused buttons               |
| buttonsFocusRingColor          | Set the color of the button in focus                  |
| buttonsSectionDividerTextColor | Sets the color of the section divider                 |

###   
CategoryListView theme attributes

| **Attribute**           | **Use**                                                              |
| ----------------------- | -------------------------------------------------------------------- |
| TextColor               | Changes the color of all the text fields in the category list        |
| focusRingColor          | Changes the color of the focus rings for both category and item list |
| categoryFocusedColor    | Sets a focused text color for category                               |
| categoryUnFocusedColor  | Sets an unfocused text color for category                            |
| itemTitleColor          | Sets the item title color                                            |
| itemDescriptionColor    | Sets the item description color                                      |
| categoryfocusRingColor  | Sets the color for the category list focus ring                      |
| itemsListfocusRingColor | Sets the color for the item list focus ring                          |

### VideoView theme attributes

#### **General fields**

| **Attribute**              | **Use**                                                             |
| -------------------------- | ------------------------------------------------------------------- |
| TextColor                  | Sets the text color of all the texts on the video and endcard views |
| progressBarColor           | Sets the color of the progress bar                                  |
| focusRingColor             | Sets the color of the focus ring in the endcard view                |
| backgroundColor            | Sets the background color of the endcard views                      |
| backgroundImageURI         | Sets the background image URL of the endcard views                  |
| endcardGridBackgroundColor | Sets the background color of the grid of the endcard items          |

####   
**Video player fields**

| **Attribute**                           | **Use**                                                                                                                                                                                                                                                                                                                  |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| trickPlayBarTextColor                   | Sets the color of the text next to the trickPlayBar node, indicating the time elapsed/remaining                                                                                                                                                                                                                          |
| trickPlayBarTrackImageUri               | Returns a 9-patch or an ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This is blended with the color specified by the trackBlendColor field if not set to a default value                                                                                                    |
| trickPlayBarTrackBlendColor             | Sets the color to be blended with the graphical image specified by the trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                                               |
| trickPlayBarThumbBlendColor             | Sets the blend color of the square image in the trickPlayBar node that shows the current position of the bar, with the current direction arrows or the pause icon on top. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place |
| trickPlayBarFilledBarImageUri           | Returns a 9-patch or an ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This is blended with the color specified by the filledBarBlendColor field if set to a non-default value               |
| trickPlayBarFilledBarBlendColor         | Sets the color to be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                                           |
| trickPlayBarCurrentTimeMarkerBlendColor | Sets the color to be blended with the marker for the current playback position. This is typically a small vertical bar displayed in the TrickPlayBar node when the user is fast-forwarding or rewinding a video                                                                                                          |

####   
**Buffering Bar customization**

| **Attribute**                   | **Use**                                                                                                                                                                                                                                                                                                   |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| bufferingTextColor              | Sets the color of the text displayed near the buffering bar defined by the bufferingBar field when the buffering bar is visible. If this value is 0, the system default color is used. To set a custom color, set this field to a value other than 0x0                                                    |
| bufferingBarEmptyBarImageUri    | Displays a 9-patch or an ordinary PNG of the bar presenting the remaining work to be done. This is typically displayed on the right side of the track and is blended with the color specified in the emptyBarBlendColor field if set to a non-default value                                               |
| bufferingBarFilledBarImageUri   | Displays a 9-patch or an ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. It is blended with the color specified by the filledBarBlendColor field if set to a non-default value |
| bufferingBarTrackImageUri       | Displays a 9-patch or an ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This is blended with the color specified by the trackBlendColor field if set to a non-default value                                                                                    |
| bufferingBarTrackBlendColor     | Sets the color to be blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                                    |
| bufferingBarEmptyBarBlendColor  | Sets the color to be blended with the graphical image specified in the emptyBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                             |
| bufferingBarFilledBarBlendColor | Sets the color to be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                            |

####   
**Retrieving Bar customization**

| **Attribute**                    | **Use**                                                                                                                                                                                                                                                                                                   |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| retrievingTextColor              | Sets the color of the text displayed near the buffering bar defined by the retrievingBar field when the buffering bar is visible. If this value is 0, the system default color is used. To set a custom color, set this field to a value other than 0x0                                                   |
| retrievingBarEmptyBarImageUri    | Displays a 9-patch or an ordinary PNG of the bar presenting the remaining work to be done. This is typically displayed on the right side of the track and is blended with the color specified in the emptyBarBlendColor field if set to a non-default value                                               |
| retrievingBarFilledBarImageUri   | Displays a 9-patch or an ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. It is blended with the color specified by the filledBarBlendColor field if set to a non-default value |
| retrievingBarTrackImageUri       | Displays a 9-patch or an ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This is blended with the color specified by the trackBlendColor field if set to a non-default value                                                                                    |
| retrievingBarTrackBlendColor     | Sets the color to be blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                                    |
| retrievingBarEmptyBarBlendColor  | Sets the color to be blended with the graphical image specified in the emptyBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                             |
| retrievingBarFilledBarBlendColor | Sets the color to be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If the default value is not changed, no blending takes place                                                            |

### Endcard theme attributes 

#### **View attributes**

| **Attribute**         | **Use**                                            |
| --------------------- | -------------------------------------------------- |
| buttonsFocusedColor   | Sets the text color of the focused repeat button   |
| buttonsUnFocusedColor | Sets the text color of the unfocused repeat button |
| buttonsfocusRingColor | Sets the background color of the repeat button     |

####   
**Grid attributes**

| **Attribute**            | **Use**                                                 |
| ------------------------ | ------------------------------------------------------- |
| rowLabelColor            | Sets the color of the grid row title                    |
| focusRingColor           | Sets the color of the grid focus ring                   |
| focusFootprintBlendColor | Sets the color of the grid unfocused focus ring         |
| itemTextColorLine1       | Sets the text color for the 1st row in the endcard item |
| itemTextColorLine2       | Sets the text color for the 2nd row in the endcard item |
| timerLabelColor          | Sets the color of the timer for the remaining time      |

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
