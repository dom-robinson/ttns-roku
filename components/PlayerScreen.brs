sub init()
    m.top.focusable = true
    m.artwork = m.top.findNode("artwork")
    m.playLabel = m.top.findNode("playLabel")
    m.liveBorder = m.top.findNode("liveBorder")
    m.feedTimer = m.top.findNode("feedTimer")
    m.chatResume = m.top.findNode("chatResume")
    m.onAir = m.top.findNode("onAir")
    m.onAirAnim = m.top.findNode("onAirAnim")
    m.chatList = m.top.findNode("chatList")
    m.zone = "player"
    m.chatFollow = true
    m.chatSig = ""
    m.canvasLoaded = false
    m.emojiMap = {}
    m.artwork.uri = BrandLogoUrl()
    m.top.trackTitle = "TTNS FM"
    clearChat("Loading the room...")
    m.feedTimer.observeField("fire", "onFeedTick")
    m.chatResume.observeField("fire", "onChatResume")
    m.chatList.observeField("itemFocused", "onChatItemFocused")
    m.top.observeField("visible", "onVisible")
    if m.global <> invalid
        m.global.observeField("chatLeaveTick", "onLeaveChat")
        m.global.observeField("chatToggleTick", "onChatToggle")
    end if
end sub

function takeFocus() as Boolean
    m.top.visible = true
    m.zone = "player"
    m.top.setFocus(true)
    startLiveFeeds()
    return true
end function

function startLiveFeeds() as Boolean
    fetchEmojis()
    fetchNowPlaying()
    fetchCanvas()
    fetchChat()
    m.feedTimer.control = "start"
    return true
end function

function stopLiveFeeds() as Boolean
    m.feedTimer.control = "stop"
    m.onAirAnim.control = "stop"
    m.chatResume.control = "stop"
    return true
end function

sub onVisible()
    if m.top.visible = true
        startLiveFeeds()
    else
        stopLiveFeeds()
    end if
end sub

sub onArtworkUrl()
    url = SafeHttpUrl(m.top.artworkUrl)
    if url = ""
        m.canvasLoaded = false
        m.artwork.uri = BrandLogoUrl()
    else
        m.canvasLoaded = true
        m.artwork.uri = url
    end if
    updateLiveBorder()
end sub

sub updateLiveBorder()
    if m.top.isPlaying = true and m.canvasLoaded = true
        m.liveBorder.color = "0x00FF00FF"
    else
        m.liveBorder.color = "0x2A2A2AFF"
    end if
end sub

sub onPlaying()
    if m.top.isPlaying = true
        m.playLabel.text = "PAUSE"
        m.onAir.text = "ON AIR"
        m.onAir.color = "0x00FF00FF"
        m.onAir.opacity = 1
        m.onAirAnim.control = "start"
    else
        m.playLabel.text = "PLAY"
        m.onAir.text = "PAUSED"
        m.onAir.color = "0x888888FF"
        m.onAir.opacity = 1
        m.onAirAnim.control = "stop"
    end if
    updateLiveBorder()
end sub

sub onFeedTick()
    fetchNowPlaying()
    fetchCanvas()
    fetchChat()
end sub

sub fetchEmojis()
    if m.emojiTask <> invalid then return
    task = CreateObject("roSGNode", "HttpTask")
    task.url = ChatEmojisUrl()
    task.observeField("ready", "onEmojisReady")
    m.emojiTask = task
    task.control = "RUN"
end sub

sub fetchNowPlaying()
    task = CreateObject("roSGNode", "HttpTask")
    task.url = NowPlayingUrl()
    task.observeField("ready", "onNowPlayingReady")
    m.npTask = task
    task.control = "RUN"
end sub

sub fetchCanvas()
    task = CreateObject("roSGNode", "HttpTask")
    task.url = CanvasStateUrl()
    task.observeField("ready", "onCanvasReady")
    m.canvasTask = task
    task.control = "RUN"
end sub

sub fetchChat()
    task = CreateObject("roSGNode", "HttpTask")
    task.url = ChatMessagesUrl()
    task.observeField("ready", "onChatReady")
    m.chatTask = task
    task.control = "RUN"
end sub

sub onEmojisReady()
    task = m.emojiTask
    if task = invalid then return
    if task.ready <> true then return
    if task.error <> "" then return
    parsed = ParseJson(task.response)
    if parsed = invalid then return
    emojis = parsed.emojis
    if emojis = invalid then return
    map = {}
    unicodeIdx = 0
    for each emoji in emojis
        name = TrimText(emoji.name)
        if name <> ""
            if emoji.unicode = true
                url = TwemojiUrlForIndex(unicodeIdx)
                unicodeIdx = unicodeIdx + 1
                if url <> "" then map[name] = url
            else
                url = SafeHttpUrl(TrimText(emoji.url))
                if url <> ""
                    map[name] = url
                    map[":" + name + ":"] = url
                end if
            end if
        end if
    end for
    m.emojiMap = map
    m.chatSig = ""
    fetchChat()
end sub

sub onNowPlayingReady()
    task = m.npTask
    if task = invalid then return
    if task.ready <> true then return
    if task.error <> "" then return
    parsed = ParseJson(task.response)
    if parsed = invalid then return
    track = FirstNonEmpty([parsed.track, parsed.streamTrack, "TTNS FM"])
    stream = TrimText(parsed.streamTrack)
    m.top.trackTitle = track
    m.top.streamLine = stream
    if m.global <> invalid then m.global.nowPlayingTitle = track
end sub

sub onCanvasReady()
    task = m.canvasTask
    if task = invalid then return
    if task.ready <> true then return
    if task.error <> "" then return
    parsed = ParseJson(task.response)
    if parsed = invalid then return
    state = parsed.state
    if state = invalid then return
    canvas = state.canvas
    if canvas = invalid then return
    url = SafeHttpUrl(TrimText(canvas.url))
    if url <> "" then m.top.artworkUrl = url
end sub

sub onChatReady()
    task = m.chatTask
    if task = invalid then return
    if task.ready <> true then return
    if task.error <> ""
        clearChat("Chat is quiet just now. Open chatbot.ttns.uk on your phone to join in.")
        return
    end if
    parsed = ParseJson(task.response)
    if parsed = invalid then return
    messages = parsed.messages
    if messages = invalid then messages = []
    newestFirst = []
    for each raw in messages
        row = MakeChatRow(raw)
        if row <> invalid then newestFirst.Push(row)
    end for
    if newestFirst.Count() = 0
        clearChat("Chat is quiet just now. Open chatbot.ttns.uk on your phone to join in.")
        return
    end if
    display = []
    i = newestFirst.Count() - 1
    while i >= 0
        display.Push(newestFirst[i])
        i = i - 1
    end while
    paintChat(display)
end sub

function MakeChatRow(raw as Object) as Object
    if raw = invalid then return invalid
    name = "Guest"
    color = "0x00FF00FF"
    author = raw.author
    if author <> invalid
        name = FirstNonEmpty([author.display_name, author.username, "Guest"])
        color = CssToRokuColor(TrimText(author.role_color))
    end if
    rawText = TrimText(raw.content)
    text = StripMappedEmojiText(DiscordDisplayText(rawText), m.emojiMap)
    photo = FirstAttachmentUrl(raw)
    emojis = CollectChatEmojiUrls(rawText, m.emojiMap)
    if text = "" and photo = "" and emojis.Count() = 0 then return invalid
    e1 = ""
    e2 = ""
    e3 = ""
    e4 = ""
    if emojis.Count() > 0 then e1 = emojis[0]
    if emojis.Count() > 1 then e2 = emojis[1]
    if emojis.Count() > 2 then e3 = emojis[2]
    if emojis.Count() > 3 then e4 = emojis[3]
    return {
        name: name,
        color: color,
        text: text,
        photo: photo,
        emoji1: e1,
        emoji2: e2,
        emoji3: e3,
        emoji4: e4
    }
end function

sub clearChat(message as String)
    m.chatSig = "empty:" + message
    root = CreateObject("roSGNode", "ContentNode")
    node = root.createChild("ContentNode")
    node.title = ""
    node.description = message
    node.ShortDescriptionLine1 = "0xA8A8A8FF"
    node.addFields({ emoji1: "", emoji2: "", emoji3: "", emoji4: "", chatIndex: 0 })
    m.chatList.content = root
end sub

sub paintChat(rows as Object)
    sig = ""
    for each item in rows
        sig = sig + item.name + "|" + item.text + "|" + item.photo + "|" + item.emoji1
    end for
    if sig = m.chatSig then return
    m.chatSig = sig
    root = CreateObject("roSGNode", "ContentNode")
    i = 0
    for each item in rows
        node = root.createChild("ContentNode")
        node.title = item.name
        node.description = item.text
        node.ShortDescriptionLine1 = item.color
        if item.photo <> "" then node.HDPosterUrl = item.photo
        node.addFields({
            emoji1: item.emoji1,
            emoji2: item.emoji2,
            emoji3: item.emoji3,
            emoji4: item.emoji4,
            chatIndex: i
        })
        i = i + 1
    end for
    m.chatList.content = root
    if m.chatFollow = true and rows.Count() > 0
        lastIdx = rows.Count() - 1
        m.chatList.jumpToItem = lastIdx
    end if
end sub

function chatCount() as Integer
    content = m.chatList.content
    if content = invalid then return 0
    return content.getChildCount()
end function

sub onChatItemFocused()
    count = chatCount()
    if count < 1 then return
    lastIdx = count - 1
    if m.chatList.itemFocused >= lastIdx
        m.chatFollow = true
        m.chatResume.control = "stop"
    else
        m.chatFollow = false
        m.chatResume.control = "stop"
        m.chatResume.control = "start"
    end if
end sub

sub onChatResume()
    count = chatCount()
    if count < 1 then return
    m.chatFollow = true
    lastIdx = count - 1
    m.chatList.jumpToItem = lastIdx
end sub

sub focusChat()
    m.zone = "chat"
    count = chatCount()
    if m.chatFollow = true and count > 0
        lastIdx = count - 1
        m.chatList.jumpToItem = lastIdx
    end if
    m.chatList.setFocus(true)
end sub

sub leaveChat()
    m.zone = "player"
    m.top.setFocus(true)
end sub

sub onLeaveChat()
    if m.top.visible = true then leaveChat()
end sub

sub onChatToggle()
    if m.top.visible = true then m.top.action = "toggle"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" or key = "play"
        m.top.action = "toggle"
        return true
    else if key = "down"
        if m.zone <> "chat"
            focusChat()
            return true
        end if
    else if key = "up"
        if m.zone = "chat"
            leaveChat()
            return true
        end if
    else if key = "left"
        if m.zone = "chat" then return true
        m.top.action = "prevStation"
        return true
    else if key = "right"
        if m.zone = "chat" then return true
        m.top.action = "nextStation"
        return true
    else if key = "back"
        if m.zone = "chat"
            leaveChat()
            return true
        end if
        m.top.action = "home"
        return true
    end if
    return false
end function
