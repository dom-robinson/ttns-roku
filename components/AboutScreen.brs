sub init()
    m.top.focusable = true
end sub

function takeFocus() as Boolean
    m.top.visible = true
    m.top.setFocus(true)
    return true
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" or key = "OK"
        m.top.action = "home"
        return true
    end if
    return false
end function
