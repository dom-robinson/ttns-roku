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
    m.chatHint = m.top.findNode("chatHint")
    m.chatEndBar = m.top.findNode("chatEndBar")
    m.helpLabel = m.top.findNode("helpLabel")
    m.photoModal = m.top.findNode("photoModal")
    m.photoModalImg = m.top.findNode("photoModalImg")
    m.chatSnap = m.top.findNode("chatSnap")
    m.photoModal.focusable = true
    m.zone = "player"
    m.chatFollow = true
    m.chatIgnoreFocus = false
    m.chatFocusIdx = 0
    m.chatScrollY = 0
    m.chatClipH = 628
    m.chatContentH = 0
    m.chatGap = 6
    m.photoJustOpened = false
    m.chatSig = ""
    m.canvasLoaded = false
    m.emojiMap = {}
    m.artwork.uri = BrandLogoUrl()
    m.top.trackTitle = "TTNS FM"
    clearChat("Loading the room...")
    paintChatHint()
    m.feedTimer.observeField("fire", "onFeedTick")
    m.chatResume.observeField("fire", "onChatResume")
    m.chatSnap.observeField("fire", "onChatSnap")
    m.top.observeField("visible", "onVisible")
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
    m.chatSnap.control = "stop"
    closePhotoModal()
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
    avatar = DefaultDiscordAvatar("")
    author = raw.author
    if author <> invalid
        name = FirstNonEmpty([author.display_name, author.username, "Guest"])
        color = CssToRokuColor(TrimText(author.role_color))
        avatar = DiscordAvatarUrl(author)
    end if
    rawText = TrimText(raw.content)
    text = StripMappedEmojiText(DiscordDisplayText(rawText), m.emojiMap)
    photo = FirstAttachmentUrl(raw)
    emojis = CollectChatEmojiUrls(rawText, raw, m.emojiMap)
    if text = "" and photo = "" and emojis.Count() = 0 then return invalid
    return {
        name: name,
        color: color,
        text: text,
        photo: photo,
        avatar: avatar,
        emojiLine: JoinStrings(emojis, "|")
    }
end function

sub clearChat(message as String)
    m.chatSig = "empty:" + message
    node = CreateObject("roSGNode", "ContentNode")
    node.title = ""
    node.description = message
    node.ShortDescriptionLine1 = "0xA8A8A8FF"
    node.addFields({ emojiLine: "", chatIndex: 0, photoUrl: "", avatarUrl: "" })
    replaceChatRows([node])
    m.chatFocusIdx = 0
    layoutChatRows()
    setChatScroll(0)
end sub

sub paintChat(rows as Object)
    sig = ""
    for each item in rows
        sig = sig + item.name + "|" + item.text + "|" + item.photo + "|" + item.emojiLine
    end for
    shouldFollow = m.chatFollow
    if sig = m.chatSig
        if shouldFollow = true then queueChatSnap()
        return
    end if
    m.chatSig = sig
    nodes = []
    i = 0
    for each item in rows
        node = CreateObject("roSGNode", "ContentNode")
        node.title = item.name
        node.description = item.text
        node.ShortDescriptionLine1 = item.color
        if item.photo <> "" then node.HDPosterUrl = item.photo
        node.addFields({
            emojiLine: item.emojiLine,
            chatIndex: i,
            photoUrl: item.photo,
            avatarUrl: item.avatar
        })
        nodes.Push(node)
        i = i + 1
    end for
    replaceChatRows(nodes)
    layoutChatRows()
    lastIdx = nodes.Count() - 1
    if m.chatFocusIdx > lastIdx then m.chatFocusIdx = lastIdx
    if m.chatFocusIdx < 0 then m.chatFocusIdx = 0
    if shouldFollow = true then m.chatFollow = true
    queueChatSnap()
end sub

sub replaceChatRows(nodes as Object)
    while m.chatList.getChildCount() > 0
        m.chatList.removeChildIndex(0)
    end while
    for each node in nodes
        row = m.chatList.createChild("ChatRow")
        row.itemContent = node
    end for
end sub

sub layoutChatRows()
    y = 0
    n = m.chatList.getChildCount()
    i = 0
    while i < n
        row = m.chatList.getChild(i)
        row.translation = [0, y]
        h = row.rowHeight
        if h < 152 then h = 152
        y = y + h + m.chatGap
        i = i + 1
    end while
    if y > 0 then y = y - m.chatGap
    m.chatContentH = y
end sub

sub setChatScroll(y as Integer)
    maxY = m.chatContentH - m.chatClipH
    if maxY < 0 then maxY = 0
    if y < 0 then y = 0
    if y > maxY then y = maxY
    m.chatScrollY = y
    m.chatList.translation = [0, 0 - y]
end sub

function chatRowHeight(idx as Integer) as Integer
    row = m.chatList.getChild(idx)
    if row = invalid then return 152
    h = row.rowHeight
    if h < 152 then return 152
    return h
end function

function chatRowTop(idx as Integer) as Integer
    y = 0
    i = 0
    while i < idx
        y = y + chatRowHeight(i) + m.chatGap
        i = i + 1
    end while
    return y
end function

function chatFollowStart() as Integer
    count = chatCount()
    if count < 1 then return 0
    lastIdx = count - 1
    used = 0
    i = lastIdx
    while i >= 0
        used = used + chatRowHeight(i)
        if i < lastIdx then used = used + m.chatGap
        if used > m.chatClipH
            start = i + 1
            if start > lastIdx then start = lastIdx
            return start
        end if
        i = i - 1
    end while
    return 0
end function

sub ensureChatVisible(idx as Integer)
    count = chatCount()
    if count < 1 then return
    if idx < 0 then idx = 0
    lastIdx = count - 1
    if idx > lastIdx then idx = lastIdx
    top = chatRowTop(idx)
    h = chatRowHeight(idx)
    if h >= m.chatClipH
        setChatScroll(top)
        return
    end if
    bot = top + h
    if top < m.chatScrollY
        setChatScroll(top)
    else if bot > m.chatScrollY + m.chatClipH
        setChatScroll(bot - m.chatClipH)
    end if
end sub

sub queueChatSnap()
    m.chatIgnoreFocus = true
    m.chatSnap.control = "stop"
    m.chatSnap.control = "start"
end sub

sub onChatSnap()
    layoutChatRows()
    count = chatCount()
    if count > 0
        lastIdx = count - 1
        if m.chatFollow = true
            m.chatFocusIdx = lastIdx
            setChatScroll(m.chatContentH)
        else
            if m.chatFocusIdx > lastIdx then m.chatFocusIdx = lastIdx
            if m.chatFocusIdx < 0 then m.chatFocusIdx = 0
            ensureChatVisible(m.chatFocusIdx)
        end if
        if m.zone = "chat" and m.global <> invalid then m.global.chatFocusIndex = m.chatFocusIdx
    end if
    m.chatIgnoreFocus = false
    if m.zone = "chat" then m.top.setFocus(true)
    paintChatHint()
end sub

sub openPhotoForIndex(idx as Integer)
    if idx < 0 then return
    if idx >= chatCount() then return
    row = m.chatList.getChild(idx)
    if row = invalid then return
    node = row.itemContent
    if node = invalid then return
    url = ""
    if node.photoUrl <> invalid then url = SafeHttpUrl(TrimText(node.photoUrl))
    if url = "" and node.HDPosterUrl <> invalid then url = SafeHttpUrl(TrimText(node.HDPosterUrl))
    if url = "" then return
    openPhotoModal(url)
end sub

sub paintChatHint()
    if m.chatFollow = true
        m.chatHint.text = "Newest in view"
        m.chatHint.color = "0x00FF00FF"
        m.chatEndBar.color = "0x00FF00FF"
    else
        m.chatHint.text = "Older chat  -  back to newest in 10s"
        m.chatHint.color = "0xFF8800FF"
        m.chatEndBar.color = "0xFF8800FF"
    end if
end sub

function chatCount() as Integer
    return m.chatList.getChildCount()
end function

sub onChatResume()
    m.chatFollow = true
    queueChatSnap()
    if m.zone = "chat" then m.top.setFocus(true)
end sub

sub focusChat()
    m.zone = "chat"
    m.helpLabel.text = "OK view picture  -  Left / Back leaves chat"
    if m.chatFollow = true then queueChatSnap()
    m.top.setFocus(true)
    syncChatFocus()
    paintChatHint()
end sub

sub syncChatFocus()
    idx = m.chatFocusIdx
    if idx < 0 then idx = 0
    lastIdx = chatCount() - 1
    if lastIdx >= 0 and idx > lastIdx then idx = lastIdx
    m.chatFocusIdx = idx
    if m.global <> invalid then m.global.chatFocusIndex = idx
end sub

sub moveChat(direction as Integer)
    count = chatCount()
    if count < 1 then return
    lastIdx = count - 1
    idx = m.chatFocusIdx
    if idx < 0 then idx = 0
    idx = idx + direction
    if idx < 0
        leaveChat()
        return
    end if
    if idx > lastIdx then idx = lastIdx
    m.chatFocusIdx = idx
    if idx >= chatFollowStart()
        setChatScroll(m.chatContentH)
        m.chatFollow = true
        m.chatResume.control = "stop"
    else
        ensureChatVisible(idx)
        m.chatFollow = false
        m.chatResume.control = "stop"
        m.chatResume.control = "start"
    end if
    if m.global <> invalid then m.global.chatFocusIndex = idx
    paintChatHint()
end sub

sub leaveChat()
    if m.photoModal.visible = true
        closePhotoModal()
        return
    end if
    m.zone = "player"
    m.helpLabel.text = "OK play / pause  -  Right chat  -  Rewind / FF station  -  Back"
    if m.global <> invalid then m.global.chatFocusIndex = -1
    m.top.setFocus(true)
end sub

sub openPhotoModal(url as String)
    m.photoModalImg.uri = url
    m.photoModal.visible = true
    m.photoJustOpened = true
    m.zone = "photo"
    m.helpLabel.text = "Back closes the picture"
    m.top.setFocus(true)
end sub

sub closePhotoModal()
    if m.photoModal.visible <> true then return
    m.photoModal.visible = false
    m.photoModalImg.uri = ""
    m.photoJustOpened = false
    m.zone = "chat"
    m.helpLabel.text = "OK view picture  -  Left / Back leaves chat"
    m.top.setFocus(true)
    paintChatHint()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.zone = "photo"
        if key = "OK" or key = "play"
            if m.photoJustOpened = true
                m.photoJustOpened = false
                return true
            end if
            return true
        end if
        if key = "back"
            closePhotoModal()
            return true
        end if
        return true
    end if
    if key = "OK" or key = "play"
        if m.zone = "chat"
            openPhotoForIndex(m.chatFocusIdx)
            return true
        end if
        m.top.action = "toggle"
        return true
    else if key = "right"
        if m.zone <> "chat"
            focusChat()
            return true
        end if
        return true
    else if key = "down"
        if m.zone <> "chat"
            focusChat()
            return true
        end if
        moveChat(1)
        return true
    else if key = "up"
        if m.zone = "chat"
            moveChat(-1)
            return true
        end if
    else if key = "left"
        if m.zone = "chat"
            leaveChat()
            return true
        end if
    else if key = "rewind"
        if m.zone = "chat" then return true
        m.top.action = "prevStation"
        return true
    else if key = "fastforward"
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
