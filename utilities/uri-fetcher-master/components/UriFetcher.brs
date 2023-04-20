function init()
	m.port = createObject("roMessagePort")
	m.top.observeField("request", m.port)
	m.top.observeField("jobsByIdField", "onJobsByIdChanged")
	m.top.observeField("urlTransferPoolField", "onTransferPoolChanged")
	m.top.functionName = "go"
	m.top.control = "RUN"
    m.urlTransferPool = [
                          createObject( "roUrlTransfer" )
                          createObject( "roUrlTransfer" )
                          createObject( "roUrlTransfer" )
                          createObject( "roUrlTransfer" )
                          createObject( "roUrlTransfer" )
                        ]
    m.transferPoolIndex = 0
    m.ret = true
end function

function go() as Void
	m.jobsById = {}
	m.top.setField("urlTransferPoolField", m.urlTransferPool.count())
	while true
		msg = wait(0, m.port)
		mt = type(msg)
		if mt="roSGNodeEvent"
			if msg.getField()="request"
				m.ret = addRequest(msg.getData())
			else
				print "UriFetcher: unrecognized field '"; msg.getField(); "'"
			end if
		else if mt="roUrlEvent"
			processResponse(msg)
		else
			print "UriFetcher: unrecognized event type '"; mt; "'"
		end if
        if m.ret = false
            ? "too many requests"
        end if
	end while
end function

function addRequest(request as Object) as Boolean
	if type(request) = "roAssociativeArray"
        context = request.context
        if type(context)="roSGNode"
            parameters = context.parameters
            if type(parameters)="roAssociativeArray"
		        uri = parameters.uri
		        if type(uri) = "roString"
			        m.urlTransferPool.Peek().setUrl(uri)
			        m.urlTransferPool.Peek().setPort(m.port)
			        ' should transfer more stuff from parameters to urlXfer
			        idKey = stri(m.urlTransferPool.Peek().getIdentity()).trim()
                    ok = m.urlTransferPool.Peek().AsyncGetToString()
                    if not ok
                        m.transferPoolIndex++
                        if m.urlTransferPool.Count() > m.transferPoolIndex

                            print "Failed due to: " + m.urlTransferPool.Peek().GetFailureReason()
                            print "Using next urlTransfer object in pool"
                            m.nextFreeObject = m.urlTransferPool.Count()-1 - m.transferPoolIndex
                            m.urlTransferPool.GetEntry( m.nextFreeObject ).setUrl( uri )
                            m.urlTransferPool.GetEntry( m.nextFreeObject ).setPort( m.port )
                            idKey = stri( m.urlTransferPool.GetEntry( m.nextFreeObject ).getIdentity()).trim()
                            ok = m.urlTransferPool.GetEntry( m.nextFreeObject ).AsyncGetToString()
                        else
                            print "urlTransferPool is fully used"
                            if not ok
                                return false
                            end if
                        endif
                        print "Resued object in urlTransferPool slot: " + str( m.nextFreeObject )
                    endif
			        if ok
                        m.jobsById[idKey] = {context: context, xfer: m.urlTransferPool}
												? "jobsbyID: "; m.jobsbyID.count()
				        print "UriFetcher: initiating transfer '"; idkey; "' for URI '"; uri; "'"; " succeeded: "; ok
												m.top.setField("JobsByIdField", m.jobsById.count())
										else
                        print "UriFetcher: invalid uri: "; uri
                    endif
		        end if
            end if
	    end if
	end if
    return true
end function

function onJobsByIdChanged() as Void
		transferPoolValue = m.top.getParent().findNode("transferPoolValue")
		transferPoolValue.text = m.top.getField("jobsByIdField")
end function

function onTransferPoolChanged() as Void
	if m.top.getParent() <> invalid
	poolIndexValue = m.top.getParent().findNode("poolIndexValue")
	poolIndexValue.text = m.top.getField("urlTransferPoolField")
end if
end function

function processResponse(msg as Object)
	idKey = stri(msg.GetSourceIdentity()).trim()
	job = m.jobsById[idKey]

    print "Number of jobs in queue: "; m.jobsById.count()
    print "Number of urlXfer objects in pool: " m.urlTransferPool.count()

    if job<>invalid
        m.transferPoolIndex = 0
        m.ret = true
        context = job.context
        parameters = context.parameters
        uri = parameters.uri
		print "UriFetcher: response for transfer '"; idkey; "' for URI '"; uri; "'"
		result = {code: msg.getResponseCode(), content: msg.getString()}
		' could handle various error codes, retry, etc.
		m.jobsById.delete(idKey)
		m.top.setField("JobsByIdField", m.jobsById.count())
        job.context.response = result
	else
		print "UriFetcher: event for unknown job "; idkey
	end if
end function
