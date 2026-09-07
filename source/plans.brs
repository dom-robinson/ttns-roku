function PlanCatalog() as Object
    return [
        {
            id: "listed",
            group: "On-air gigs",
            title: "Listed",
            price: "Free",
            blurb: "Light rotation if your venue is already in the feed.",
            body: "Listed is the free starting point. If TTNS already has your venue or gigs, you may hear light rotation without a paid portal. You do not get the full advertiser tools. Upgrade to Bronze or higher to edit scripts, see stats, and increase presence. A Spotlight is the one-off alternative for a single event."
        },
        {
            id: "bronze",
            group: "On-air gigs",
            title: "Bronze",
            price: "GBP 25 / mo",
            blurb: "Portal access, edit scripts, monthly stats.",
            body: "Bronze opens the venue portal. You can edit on-air scripts, manage which gigs are active, and see monthly stats. This is the usual first paid step when you want regular radio presence rather than the free Listed seeding."
        },
        {
            id: "silver",
            group: "On-air gigs",
            title: "Silver",
            price: "GBP 60 / mo",
            blurb: "Prime-time eligible, 3 creatives, one classified slot.",
            body: "Silver is prime-time eligible. You can run up to three creative variants per gig, you get one classified slot, and stats come weekly. You can stack Silver with Spotlight or a classified product if you want a burst plus the ongoing plan."
        },
        {
            id: "gold",
            group: "On-air gigs",
            title: "Gold",
            price: "GBP 120 / mo",
            blurb: "Custom voice and first refusal on Live slots.",
            body: "Gold adds a custom voice and first refusal on Live from Venue slots, plus dashboard stats. It is the top monthly gig plan. Live broadcasts themselves are still booked separately at GBP 350 per event."
        },
        {
            id: "spotlight",
            group: "On-air gigs",
            title: "Spotlight",
            price: "GBP 30 / event",
            blurb: "A focused burst of about 14 days and 20 plays.",
            body: "Spotlight is a one-event push, not a monthly subscription. You get a focused burst of about 14 days and about 20 plays for a specific gig. Useful when you are otherwise Listed or you want extra weight on one night."
        },
        {
            id: "classified",
            group: "On-air classified",
            title: "Classified",
            price: "GBP 25 / year",
            blurb: "One active month on air, then the pool, plus a year on the web.",
            body: "Classified is for music services, not gigs. You get one active on-air month (about 30 plays), then pooled rotation, and a 12-month web directory listing. This is a different product from Bronze / Silver / Gold."
        },
        {
            id: "boost",
            group: "On-air classified",
            title: "Boost",
            price: "GBP 12",
            blurb: "Another active on-air month on top of Classified.",
            body: "Boost adds another active on-air month to a Classified product. Use it when you want a second burst without moving up to Plus or Pro."
        },
        {
            id: "classified-plus",
            group: "On-air classified",
            title: "Classified Plus",
            price: "GBP 50 / mo",
            blurb: "21 plays a week for music-service ads.",
            body: "Classified Plus is the monthly service plan at 21 plays a week. It is for studios, teachers, hire, and similar music businesses that want a steady on-air presence."
        },
        {
            id: "classified-pro",
            group: "On-air classified",
            title: "Classified Pro",
            price: "GBP 90 / mo",
            blurb: "42 plays a week for music-service ads.",
            body: "Classified Pro doubles Plus to 42 plays a week. Same idea as Plus: music services on the radio, not venue gig listings."
        },
        {
            id: "live",
            group: "Premium",
            title: "Live from Venue",
            price: "GBP 350 / event",
            blurb: "A network live broadcast slot for one event.",
            body: "Live from Venue is a network live broadcast slot. Capacity is limited each week. The package usually includes a promo window and recording support as described at checkout. Cancellation and kill fees apply, especially inside 7 days. Connectivity is usually yours unless TTNS supplies it in the booking terms. Gold monthly plans get first refusal on these slots."
        },
        {
            id: "kit",
            group: "Community board",
            title: "Kit and artists wanted",
            price: "GBP 1 / post",
            blurb: "Website hosting for kit and collaborator ads. Not on the radio.",
            body: "Kit for sale, kit wanted, and artists wanted are website board posts at GBP 1 each. TTNS hosts the ad and introduces people. Sales and meet-ups are between you. Kit for sale needs an asking price. These posts do not go on the radio unless you also buy an on-air product."
        },
        {
            id: "gig-request",
            group: "Community board",
            title: "Request an Act / DJ",
            price: "GBP 20 / post",
            blurb: "TTNS emails matching acts. No booking fee.",
            body: "Post the style, date, and event. TTNS emails matching Act / DJ profiles who asked to hear about this. You talk to them directly. TTNS is not the agent and takes no booking fee. This is a website post, not an on-air advert."
        },
        {
            id: "act-directory",
            group: "Community board",
            title: "Act / DJ and Directory",
            price: "GBP 1, then GBP 10 / year",
            blurb: "Be found for gigs, tuition, studios, hire, and crew.",
            body: "Act / DJ profiles and the Music and Creative Directory are GBP 1 for the first year, then GBP 10 a year. Use Act / DJ if you want gigs. Use Directory for tuition, studios, hire, media, and crew (up to four categories). Cancel from My Account on the city site. Community and venue logins are separate."
        },
        {
            id: "extras",
            group: "Notes",
            title: "Watches and MP3 rebuilds",
            price: "Free / GBP 5",
            blurb: "Watches are free. Rebuilding an on-air MP3 after a text change is GBP 5.",
            body: "Community watches email you when matching listings appear and cost nothing. Text edits before audio is made are free. If an on-air MP3 already exists and you change the words, rebuilding that file is GBP 5. Sign-up, claims, and Stripe checkout stay on brighton.ttns.fm/plans or your city site."
        }
    ]
end function
