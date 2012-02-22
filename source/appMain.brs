'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

'*
'* initTheme()
'*
Sub initTheme()

    print "initTheme()"

    this = m

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"
    theme.OverhangLogoSD  = "pkg:/images/Overhang_Logo_SD.png"

theme.OverhangOffsetHD_X = "125"
theme.OverhangOffsetHD_Y = "35"
theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
theme.OverhangLogoHD  = "pkg:/images/Overhang_Logo_HD.png"

app.SetTheme(theme)

End Sub

'*
'* Main()
'*
Sub Main()

    print "cmyth starting"

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
    screen=preShowHomeScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if

    'set to go, time to get started
    showHomeScreen(screen)

End Sub

