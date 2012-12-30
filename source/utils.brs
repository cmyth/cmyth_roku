'*
'* Utility Functions
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*
'* This program is free software; you can redistribute it and/or modify
'* it under the terms of the GNU General Public License as published by
'* the Free Software Foundation; either version 2 of the License, or
'* (at your option) any later version.
'*
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
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

function getURLPrefix() As Dynamic

    prefix = "http://" + getServerName() + ":" + getPortNum()

    return prefix

end function
