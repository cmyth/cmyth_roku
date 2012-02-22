'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

'*
'*
'*
function GetInfo(message as String, default as Dynamic) as Dynamic

    screen = CreateObject("roKeyboardScreen")
    port = CreateObject("roMessagePort")

    screen.SetMessagePort(port)
    if default <> invalid then
        screen.SetText(default)
    end if
    screen.SetDisplayText(message)
    screen.SetMaxLength(50)
    screen.AddButton(0, "Ok")
    screen.AddButton(1, "Cancel")

    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed()
                return invalid
            else if msg.isButtonPressed() then
                if msg.GetIndex() = 0 then
		    print "set data"
                    return screen.GetText()
                else if msg.GetIndex() = 1 then
                    return invalid
                end if
            end if
        end if
    end while

end function

'*
'*
'*
function getServerName() As Dynamic

    sec = CreateObject("roRegistrySection", "Settings")
    if sec.Exists("serverName") then
        return sec.Read("serverName")
    else
        return invalid
    end if

end function

'*
'*
'*
function setServerName(server As String) As Void

    sec = CreateObject("roRegistrySection", "Settings")
    sec.Write("serverName", server)
    sec.Flush()

end function

'*
'*
'*
function getPortNum() As Dynamic

    sec = CreateObject("roRegistrySection", "Settings")
    if sec.Exists("portNum") then
        return sec.Read("portNum")
    else
        return "6801"
    end if

end function

'*
'*
'*
function setPortNum(port As String) As Void

    sec = CreateObject("roRegistrySection", "Settings")
    sec.Write("portNum", port)
    sec.Flush()

end function

