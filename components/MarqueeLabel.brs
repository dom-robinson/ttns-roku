sub init()
    m.lab = m.top.findNode("lab")
    m.anim = m.top.findNode("anim")
    m.interp = m.top.findNode("interp")
    applyClip()
end sub

sub applyClip()
    w = m.top.clipW
    h = m.top.clipH
    m.top.clippingRect = [0, 0, w, h]
    m.lab.height = h
    if m.top.bold = true
        m.lab.font = "font:SmallBoldSystemFont"
    else
        m.lab.font = "font:SmallestSystemFont"
    end if
end sub

sub onColor()
    m.lab.color = m.top.labelColor
end sub

sub onText()
    applyClip()
    m.lab.text = m.top.text
    m.lab.translation = [0, 0]
    stopMarquee()
    if m.top.active = true then startMarquee()
end sub

sub onActive()
    applyClip()
    if m.top.active = true
        startMarquee()
    else
        stopMarquee()
    end if
end sub

sub stopMarquee()
    m.anim.control = "stop"
    m.lab.translation = [0, 0]
    clipW = m.top.clipW
    m.lab.width = clipW
end sub

sub startMarquee()
    text = m.top.text
    clipW = m.top.clipW
    width = TextPixelWidth(text, m.top.fontSize, m.top.bold)
    if width <= clipW
        m.lab.width = clipW
        m.lab.translation = [0, 0]
        m.anim.control = "stop"
        return
    end if
    extra = width - clipW + 48
    m.lab.width = width + 24
    startPt = [0, 0]
    endX = 0 - extra
    endPt = [endX, 0]
    m.interp.keyValue = [startPt, endPt]
    seconds = 4 + (extra / 70)
    if seconds > 16 then seconds = 16
    m.anim.duration = seconds
    m.anim.control = "start"
end sub
