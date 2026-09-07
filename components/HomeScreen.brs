sub init()
    m.top.focusable = true
    m.b0 = m.top.findNode("b0")
    m.b1 = m.top.findNode("b1")
    m.b2 = m.top.findNode("b2")
    m.b3 = m.top.findNode("b3")
    m.b4 = m.top.findNode("b4")
    m.f0 = m.top.findNode("f0")
    m.f1 = m.top.findNode("f1")
    m.f2 = m.top.findNode("f2")
    m.f3 = m.top.findNode("f3")
    m.f4 = m.top.findNode("f4")
    m.t0 = m.top.findNode("t0")
    m.t1 = m.top.findNode("t1")
    m.t2 = m.top.findNode("t2")
    m.t3 = m.top.findNode("t3")
    m.t4 = m.top.findNode("t4")
    m.stationLabel = m.top.findNode("stationLabel")
    m.nowPlayingLabel = m.top.findNode("nowPlayingLabel")
    m.index = 0
    reloadStation()
    paintTiles()
end sub

sub reloadStation()
    station = GetSelectedStation()
    if m.stationLabel <> invalid then m.stationLabel.text = station.name
    line = ""
    if m.global <> invalid then line = TrimText(m.global.nowPlayingTitle)
    if line <> "" and line <> "TTNS FM"
        m.nowPlayingLabel.text = "Now playing  -  " + line
    else
        m.nowPlayingLabel.text = ""
    end if
end sub

function reloadHome() as Boolean
    reloadStation()
    paintTiles()
    return true
end function

function takeFocus() as Boolean
    m.top.setFocus(true)
    reloadStation()
    paintTiles()
    return true
end function

sub paintTiles()
    m.b0.color = "0x2A2A2AFF"
    m.b1.color = "0x2A2A2AFF"
    m.b2.color = "0x2A2A2AFF"
    m.b3.color = "0x2A2A2AFF"
    m.b4.color = "0x2A2A2AFF"
    m.f0.color = "0x161616FF"
    m.f1.color = "0x161616FF"
    m.f2.color = "0x161616FF"
    m.f3.color = "0x161616FF"
    m.f4.color = "0x161616FF"
    m.t0.color = "0xF6F7F4FF"
    m.t1.color = "0xF6F7F4FF"
    m.t2.color = "0xF6F7F4FF"
    m.t3.color = "0xF6F7F4FF"
    m.t4.color = "0xF6F7F4FF"
    if m.index = 0
        m.b0.color = "0x00FF00FF"
        m.f0.color = "0x1C2A16FF"
        m.t0.color = "0x00FF00FF"
    else if m.index = 1
        m.b1.color = "0x00FF00FF"
        m.f1.color = "0x1C2A16FF"
        m.t1.color = "0x00FF00FF"
    else if m.index = 2
        m.b2.color = "0x00FF00FF"
        m.f2.color = "0x1C2A16FF"
        m.t2.color = "0x00FF00FF"
    else if m.index = 3
        m.b3.color = "0x00FF00FF"
        m.f3.color = "0x1C2A16FF"
        m.t3.color = "0x00FF00FF"
    else
        m.b4.color = "0x00FF00FF"
        m.f4.color = "0x1C2A16FF"
        m.t4.color = "0x00FF00FF"
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "right"
        if m.index = 0
            m.index = 1
        else if m.index = 1
            m.index = 2
        else if m.index = 3
            m.index = 4
        end if
        paintTiles()
        return true
    else if key = "left"
        if m.index = 2
            m.index = 1
        else if m.index = 1
            m.index = 0
        else if m.index = 4
            m.index = 3
        end if
        paintTiles()
        return true
    else if key = "down"
        if m.index = 0
            m.index = 3
        else if m.index = 1
            m.index = 4
        else if m.index = 2
            m.index = 4
        end if
        paintTiles()
        return true
    else if key = "up"
        if m.index = 3
            m.index = 0
        else if m.index = 4
            m.index = 1
        end if
        paintTiles()
        return true
    else if key = "OK" or key = "play"
        if m.index = 0
            m.top.action = "listen"
        else if m.index = 1
            m.top.action = "gigs"
        else if m.index = 2
            m.top.action = "community"
        else if m.index = 3
            m.top.action = "plans"
        else
            m.top.action = "web"
        end if
        return true
    else if key = "back"
        m.top.action = "exit"
        return true
    end if
    return false
end function
