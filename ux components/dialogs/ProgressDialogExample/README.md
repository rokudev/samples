## ProgressDialog Markup

**Example Application:** [ProgressDialogExample.zip](https://sdkdocs.roku.com/download/attachments/4262970/ProgressDialogExample.zip?version=2&modificationDate=1471022356351&api=v2)
**Node Class Reference:** [**ProgressDialog**](https://sdkdocs.roku.com/display/sdkdoc/ProgressDialog), **BusySpinner**

The **ProgressDialog** node class shows a dialog with an internal **BusySpinner** node. The obvious use for a **ProgressDialog** node is when you want to inform a user that the application is taking some time to process information, maybe if a large download of data is occurring. When this condition occurs in your application, call something like `showdialog()` in `progressdialogscene.xml`:

```
sub showdialog()
  progressdialog = createObject("roSGNode", "ProgressDialog")
  progressdialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
  progressdialog.title = "Example Progress Dialog"
  m.top.dialog = progressdialog
  ...
end sub
```

The `showdialog()` function above configures the **ProgressDialog** node dialog to appear as follows:

![img](https://sdkdocs.roku.com/download/attachments/4262970/progressdialogdoc.jpg?version=2&modificationDate=1472838318411&api=v2) 

In an actual application, you'd want to call something like `showdialog()` before a time-consuming process is started in your application, then when the operation is complete, call a typical `dismissdialog()` function that sets the dialog object `close` field to true:

```
sub dismissdialog()
  m.top.dialog.close = true
end sub
```

Ideally, you'd want the `dismissdialog()` function to be a callback function triggered by an observed field change when the time-consuming process completes. For the example, we've simulated this using a **Timer** node, configured to run for three seconds before changing the `fire` field, which is observed to trigger the `dismissdialog()` callback function.

You can also configure aspects of the internal **BusySpinner** node by referring to the dialog object `busySpinner` field.