function init() as void
    m.top.backgroundUri=""
	m.top.backgroundColor="0x000000ff"
    spinner = m.top.FindNode("spinner")
	spinner.poster.uri="pkg:/images/loader.png"
end function