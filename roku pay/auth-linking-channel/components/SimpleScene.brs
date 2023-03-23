' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' 1st function that runs for the scene component on channel startup
sub init()
  print "init scene"
  m.Button     = m.top.findNode("Button")
  m.Token      = m.top.findNode("Token")
  m.HowTo      = m.top.findNode("HowTo")
  m.Login      = m.top.findNode("Login")
  m.RegTask    = m.top.findNode("RegistryTask")
  m.LoginTimer = m.top.findNode("LoginTimer")
  m.Token.font.size = 90
  m.Login.font.size = 110

  deviceInfo   = createObject("roDeviceInfo")
  m.model      = deviceInfo.getModel()
  clock        = createObject("roDateTime")
  m.seconds    = clock.asSeconds().toStr()
  m.linked     = false

  m.rokuDeviceID = "UNIQUE_ID_HERE" + m.model
  m.RegTask.read = m.rokuDeviceID

  m.gen = "http://rokuleow.pythonanywhere.com/generate?token=" + m.rokuDeviceID
  m.auth = "http://rokuleow.pythonanywhere.com/authenticate?token=" + m.rokuDeviceID
  m.dis = "http://rokuleow.pythonanywhere.com/disconnect?token=" + m.rokuDeviceID

  m.UriHandler  = createObject("roSGNode","UriHandler")
  m.UriHandler.observeField("linked","onLinked")
  m.UriHandler.observeField("disconnect","onDisconnect")
  m.UriHandler.observeField("response","onNewToken")
  m.LoginTimer.observeField("fire","onCheckAuth")

  m.RegTask.observeField("result","onReadFinished")
  m.Button.observeField("buttonSelected", "onButtonPress")
  m.Button.setFocus(true)
end sub

sub onReadFinished(event as object)
  print "onReadFinished"
  if m.RegTask.result = "none"
    makeRequest({}, m.gen, "GET", 0)
    m.LoginTimer.repeat = true
    m.LoginTimer.control = "start"
  else
    'm.HowTo.translation = [600, 540]
    m.HowTo.text = "You are already linked. To run this demo again, either press 'Unlink Device' or rerun the channel using a different ID string (replace UNIQUE_ID_HERE) to simulate another device."
    m.Token.text = ""
    m.Button.text = "Unlink The Device"
  end if
end sub

sub onLinked(event as object)
  if m.UriHandler.linked
    m.linked = true
    m.HowTo.text = "Your account was successfully linked! To run this demo again, either press 'Unlink Device' or rerun the channel using a different ID string (replace UNIQUE_ID_HERE) to simulate another device."
    m.Token.text = ""
    m.Button.text = "Unlink The Device"
    m.LoginTimer.repeat = false
    m.LoginTimer.control = "stop"
    m.regTask.write = {
      deviceID: m.rokuDeviceID,
      oauth_token: m.urihandler.oauth_token
    }
  else
    print "Not linked yet"
  end if
end sub

sub onDisconnect(event as object)
  if m.UriHandler.disconnect
    m.HowTo.text = "Go to 'http://rokuleow.pythonanywhere.com/activate' on a web browser and enter the following code to connect:"
    m.Button.text = "Generate A New Code"
    m.linked = false
    makeRequest({}, m.gen, "GET", 0)
    m.regTask.write = {
      deviceID: m.rokuDeviceID,
      oauth_token: invalid
    }
  else
    m.HowTo.text = "Error: There was no device to disconnect. Restart the channel."
  end if
end sub

sub onNewToken(event as object)
  print "onNewToken"
  m.Token.text = event.getData()
end sub

sub onCheckAuth(event as object)
  if m.linked
    m.LoginTimer.repeat = false
    m.LoginTimer.control = "stop"
  else
    makeRequest({}, m.auth, "GET", 1)
  end if
end sub

'Generates a new token
sub onButtonPress(event as object)
  print "onButtonPress"
  if m.button.text <> "Unlink The Device"
    makeRequest({}, m.gen, "GET", 0)
    m.LoginTimer.repeat = true
    m.LoginTimer.control = "start"
  else
    makeRequest({}, m.dis, "GET", 2)
    m.LoginTimer.repeat = true
    m.LoginTimer.control = "start"
  end if
end sub

sub makeRequest(headers as object, url as String, method as String, num as Integer)
  print "[makeRequest]"
  context = createObject("roSGNode", "Node")
  params = {
    headers: headers,
    uri: url,
    method: method
  }
  context.addFields({
    parameters: params,
    num: num,
    response: {}
  })
  m.UriHandler.request = { context: context }
end sub
