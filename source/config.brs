' Public endpoints only. This channel does not need API keys or logins.

function AppVersion() as String
    return "0.2.0-beta"
end function

function NowPlayingUrl() as String
    return "https://nowplaying.ttns.uk/trackinfo/current"
end function

function CanvasStateUrl() as String
    return "https://canvas.ttns.uk/api/state.php"
end function

function FallbackArtworkUrl() as String
    return "pkg:/images/ttns-logo.png"
end function

function ChatEmojisUrl() as String
    return "https://chatbot.ttns.uk/api/emojis.php"
end function

function BrandLogoUrl() as String
    return "pkg:/images/ttns-logo.png"
end function

function ChatMessagesUrl() as String
    return "https://chatbot.ttns.uk/api/messages.php?limit=25"
end function

function PlansPath() as String
    return "/plans"
end function

function NationalSiteUrl() as String
    return "https://www.ttns.fm"
end function

function CategoryLabel(categoryId as String) as String
    labels = {
        "services": "Services",
        "kit_for_sale": "Kit for sale",
        "kit_wanted": "Kit wanted",
        "artists_wanted": "Artists wanted",
        "artists_available": "Artists available",
        "gig_request": "Request an Act / DJ"
    }
    if labels[categoryId] <> invalid then return labels[categoryId]
    return PrettyToken(categoryId)
end function
