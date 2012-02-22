'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

'*
'*
'*
Function preShowHomeScreen(breadA=invalid, breadB=invalid) As Object

    print "preShowHomeScreen()"

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)

    screen.SetListStyle("flat-category")
    screen.setAdDisplayMode("scale-to-fit")
    return screen

End Function

'*
'*
'*
Function showHomeScreen(screen) As Integer

    print "showHomeScreen()"

    initHomeList()
    screen.SetContentList(m.categories.Kids)
    screen.SetFocusedListItem(1)
    screen.Show()

    if getServerName() <> invalid and getPortNum() <> invalid then
        print "settings are valid"
    else
        print "settings are invalid"
        showSettingsScreen()
    end if

    while true
        print "showHomeScreen() wait for input"
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "item selected | index = "; msg.GetIndex(); " | category = "; m.curCategory
		if msg.GetIndex() = 0 then
		    showSettingsScreen()
		else if msg.GetIndex() = 1 then
		    print "mythtv..."
		    showMythtvScreen()
		else if msg.GetIndex() = 2 then
		    showAboutScreen()
		endif
            else if msg.isScreenClosed() then
                return -1
            end if
        end if
    end while

    return 0

End Function

'*
'*
'*
Function initHomeList() As Void

    print "initHomeList()"

    m.categories = CreateObject("roArray", 100, true)

    m.categories.Push("Settings")
    m.categories.Push("Recordings")
    m.categories.Push("About")

    root = init_homescreen_item("", "Settings")

    settings = init_homescreen_item("Settings", "Edit Settings", "pkg:/images/settings.png")
    recordings = init_homescreen_item("Recordings", "MythTV Recordings", "pkg:/images/mythtv.png")
    about = init_homescreen_item("About", "About cmyth", "pkg:/images/about.png")

    root.AddKid(settings)
    root.AddKid(recordings)
    root.AddKid(about)

    m.categories = root

End Function

Function init_homescreen_item(title, description, image=invalid) As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = title
    o.ShortDescriptionLine1       = description
    o.Type        = "normal"
    o.Description = description
    o.Kids        = CreateObject("roArray", 100, true)
    o.Parent      = invalid
    o.Feed        = ""
    o.IsLeaf      = cn_is_leaf
    o.AddKid      = cn_add_kid
    if not image = invalid then
        o.SDPosterURL = image
        o.HDPosterURL = image
    endif
    return o
End Function

Function cn_is_leaf() As Boolean
    if m.Kids.Count() > 0 return true
    if m.Feed <> "" return false
    return true
End Function

Sub cn_add_kid(kid As Object)
    if kid = invalid then
        print "skipping: attempt to add invalid kid failed"
        return
    endif

    kid.Parent = m
    m.Kids.Push(kid)
End Sub
