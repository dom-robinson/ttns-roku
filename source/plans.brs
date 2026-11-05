' Public "plans" screen copy for the Nov 2026 next-version pivot:
' free city gig listings; venue paid ladder and Community board parked.

function PlanCatalog() as Object
    return [
        {
            id: "listed",
            group: "City gig listings",
            title: "Free to air",
            price: "Free",
            blurb: "Local gigs from the feed on your city site and in this channel.",
            body: "TTNS FM is eccentric eclectic internet radio with local gig listings at the centre. Venues in the local feed appear on the city site and in the apps with ticket links. There is no charge to venues for being listed."
        },
        {
            id: "listen",
            group: "City gig listings",
            title: "Listen online",
            price: "Free",
            blurb: "City streams and The Thursday Night Show national feed.",
            body: "Pick Brighton (or another city when live) for local listings, or The Thursday Night Show for the national stream. Streams are online only — the Brighton DAB multiplex is being turned off."
        },
        {
            id: "sponsor",
            group: "Notes",
            title: "City sponsors",
            price: "Coming soon",
            blurb: "One sponsor per city for the listings skin.",
            body: "We are moving to a single city sponsor model (for example Local gig listings sponsored by…). Details will appear on the city websites when ready. Sign-up for tickets stays on your city site such as brighton.ttns.fm."
        }
    ]
end function
