function init()
	print "UriFetcherTestScene: init()"
	m.uriFetcher = createObject("roSGNode", "UriFetcher")
	updateCounter()
end function

function makeRequest(parameters as Object, callback as String)
    context = createObject("RoSGNode","Node")
    if type(parameters)="roAssociativeArray"
        context.addFields({parameters: parameters, response: {}})
        context.observeField("response","uriResult") ' response callback is request-specific
        m.uriFetcher.request = {context: context}
    end if
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
	if press
		if key="OK"
			uri = getUri(m.counter_label.text)
			print "UriFetcherTestScene: requesting '"; uri; "'"
            makeRequest({uri: uri}, "uriResult")
			return true
		else if key="down"
			return updateCounter(-1)
		else if key="up"
			return updateCounter(+1)
		else
			print "UriFetcherTestScene: unhandled key '"; key; "' pressed"
		end if
	end if
	return false
end function

function getUri(discriminator as String) as String
	' edit for local testing
    ' using free HTTP or HTTPS test endpoints provided through http://httpbin.org
	return "http://httpbin.org/delay/" + m.counter.toStr()
end function

function updateCounter(delta = 0 as Integer) as Boolean
	if m.counter = invalid then m.counter = 0
	m.counter = m.counter + delta
	if m.counter<0 then m.counter = 0
	if m.counter_label = invalid then m.counter_label = m.top.findNode("counter")
	m.counter_label.text = stri(m.counter).trim()
    return true
end function

function uriResult(msg as Object)
	mt = type(msg)
	if mt="roSGNodeEvent"
		print "UriFetcherTestScene: results obtained"
        context = msg.getRoSGNode()
        response = msg.getData()
        rt = type(response)
        if rt ="roAssociativeArray"
            parameters = context.parameters
		    print "  uri: "; parameters.uri
		    print "  response: "; response
        else
            print "UriFetcherTestScene: unknown response type '"; rt; "'"
        end if
	else
		print "UriFetcherTestScene: unknown msg type '"; mt; "'"
	end if
end function
