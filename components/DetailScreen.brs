sub init()
    m.top.focusable = true
    m.artwork = m.top.findNode("artwork")
    m.artwork.uri = FallbackArtworkUrl()
end sub

function takeFocus() as Boolean
    m.top.visible = true
    m.top.setFocus(true)
    return true
end function

sub onArtworkUrl()
    url = SafeHttpUrl(m.top.artworkUrl)
    if url = ""
        m.artwork.uri = FallbackArtworkUrl()
    else
        m.artwork.uri = url
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" or key = "play"
        m.top.action = "web"
        return true
    else if key = "back"
        m.top.action = "back"
        return true
    end if
    return false
end function
