'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

'*
'*
'*
function createEpisodesScreen(xml as Object) as Object

    print "createEpisodesScreen()"

    if xml.episodes = invalid then
        print "no episodes"
    end if
    if xml.episode = invalid then
        print "no episode"
    end if

    episodes = xml.GetChildElements()
    print "number of episodes: " + Stri(episodes.Count())

    root = init_homescreen_item("", "MythTV")

    for each rec in episodes
    	rec = init_homescreen_item(rec@title, rec@title, "pkg:/images/mythtv.png")
        root.AddKid(rec)
    next

    print "xml parsed"

    return root

end function

'*
'*
'*
function showEpisodeScreen(title as String, file as String)

    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("flat-episodic")

    xml=CreateObject("roXMLElement")
    ep = getEpisodes(file)
    if not xml.Parse(ep) then
        print "Can't parse feed"
        return invalid
    end if
    episodes = xml.GetChildElements()

    m.episodes = createEpisodesScreen(xml)

    screen.SetContentList(m.episodes.Kids)
    screen.SetFocusedListItem(0)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "item selected | index = "; msg.GetIndex()
		item = episodes[msg.GetIndex()]
                print item@file
		showVideoScreen(item)
            else if msg.isScreenClosed() then
                return -1
	    end if
	end if
    end while

end function

'*
'*
'*
function getEpisodes(file as String) as Object

    print "getEpisodes()"

    conn = CreateObject("roAssociativeArray")

    server = getServerName()
    portnum = getPortNum()

    prefix = "http://" + server + ":" + portnum
    url = prefix + file

    print "URL: " + url

    conn.Timer = CreateObject("roTimespan")
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()

    print "XML loaded"

    return rsp

end function
