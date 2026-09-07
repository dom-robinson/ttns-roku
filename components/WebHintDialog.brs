sub init()
    m.top.focusable = true
    m.top.visible = false
    m.top.opacity = 0
end sub

function present() as Boolean
    m.top.visible = true
    m.top.opacity = 1
    m.top.setFocus(true)
    return true
end function

function hideHint() as Boolean
    m.top.visible = false
    m.top.opacity = 0
    return true
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" or key = "back" or key = "play"
        hideHint()
        return true
    end if
    return true
end function
