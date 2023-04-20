# Using ViewStack 


Views are full-screen SceneGraph Developer Extension components that can
be used as a template to build a view instead of building one from
scratch. SceneGraph Developer Extensions (SGDEX) supports out of the box
stacking of the views. This means that you can add as many views to a
stack and SGDEX will handle back button closing of the view and will add
support for events when the view is:

  - Opened

  - Closed

  - Hidden because next view is displayed

  - Manually closed

The component ViewStack is designed to work with any RSG component or a
SGDEX view.

## Focus Handling

View stack handles basic focus when the view is opened or restores focus
when it's closed.

According to Roku best practices, a view should handle focus by
itself. ViewStack sets focus to view
by implementing view.setFocus(true).

The view implements focus handling as follows:

~~~~
sub init()
    m.viewThatHasFocus = m.top.findNode("viewThatHasFocus")
    m.top.observeField("focusedChild","OnFocusChildChange")
end sub
sub OnFocusChildChange()
 
    if m.top.isInFocusChain() and not m.viewThatHasFocus.hasFocus() then
       m.viewThatHasFocus.setFocus(true)
    end if
end sub
~~~~

Don't set focus to the view before adding it to ViewStack as it will set
focus to a previous view.

**Note:** Dialogs are not supported by ViewStack, use scene.dialog field
instead.

## Samples

### Opening a new view

To add (open) a new view to the stack, use:

~~~~
sub Show(args)
 
    homeGrid = CreateObject("roSGNode", "GridView")
    homeGrid.content = GetContentNodeForHome() ' implemented by user
 
    'This will add your view to stack
 
    m.top.ComponentController.callFunc("show", {
        view: homeGrid
    })
end sub
~~~~

### Receiving an event when the view is closed

If you want to be notified when the view is closed either manually or
when the user has pressed back (observeFieldÂ wasClosed), use the
following:

~~~~
sub onShowLoginPage()
 
    loginView = CreateObject("roSGNode", "MyLoginView")
    loginView.observeField("wasClosed", "onLoginFinished")
 
    'This will add your view to stack
 
    m.top.ComponentController.callFunc("show", {
        view: loginView
    })
end sub
 
sub onLoginFinished(event as Object)
    loginView = event.getRosgNode()
    if loginView.isSuccess then
       ShowVideoPlayer()
    else
        'do your logic
    end if
end sub
~~~~

### Closing a view manually

To close a view manually, use the close field of view. This is useful
when the channel needs to show the login flow after a successful login. 

**Note:** Close field is added by ViewStack.

The developer can close any view in the stack, even if it is not on the
top.

~~~~
sub onShowLoginPage()
 
    banner = CreateObject("roSGNode", "MyBannerView")
    banner.observeField("wasClosed", "onBannerClosed")
 
    m.timer = CreateObject("roSGNode", "Timer")
    'if user doesn't perform anything close the view
 
    m.timer.duration = 20
    m.timer.control = "start"
    m.timer.observeField("fire", "closeBanner")
 
    'This will add your view to stack
 
    m.top.ComponentController.callFunc("show", {
        view: banner
    })
    m.banner = banner
end sub
 
sub closeBanner()
    m.banner.close = true
end sub
 
sub onBannerClosed()
    'Show next view
end sub
~~~~

## Component Controller

Using the component controller assists with implementing as well as
managing the view stack. It essentially implements the basic default
view management. Component Controller has fields to enable view
development for building a channel using SceneGraph Developer
Extensions. Refer to [ComponentController
Component](https://confluence.portal.roku.com:8443/display/DR/SceneGraph+Developer+Extensions+Components#SceneGraphDeveloperExtensionsComponents-ComponentController) for
more details. 

### Component Controller Fields

  - currentView - Links to the view that is currently shown
    by ViewStack (This view represents the view that is shown by
    ViewStack. If another view without using ViewStack is shown, it
    wouldn't be reflected here)

  - allowCloseChannelOnLastView - If true, the channel closes when the
    back button is pressed or if the previous view set the view's close
    field to true

  - allowCloseLastViewOnBack - If true, the current view is closed,
    and the user can open another view through the new
    view's wasClosed callback
    
###### Copyright (c) 2018 Roku, Inc. All rights reserved.
