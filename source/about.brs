'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

function createAboutScreen(port as Object) as Object

    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)

    screen.AddParagraph("libcmyth MythTV frontend for Roku")
    screen.AddParagraph("http://cmyth.github.com/")

    screen.AddButton(0, "Done")

    return screen

end function

function showAboutScreen()

    port = CreateObject("roMessagePort")
    screen = createAboutScreen(port)

    screen.Show()

    done = false
    while done = false
        while true
            msg = wait(0, port)
            if type(msg) = "roParagraphScreenEvent" then
                if msg.isScreenClosed() then
		    done = true
		    exit while
		else if msg.isButtonPressed() then
		    if msg.getIndex() = 0 then
		        done = true
		        exit while
		    end if
		end if
	    end if
        end while
    end while

end function
