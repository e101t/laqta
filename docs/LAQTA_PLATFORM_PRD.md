# LAQTA Platform PRD

## Product Vision
LAQTA is a premium Arabic platform for visual discovery, bookings, and monetization in photography and events. The platform blends short-form content, supplier discovery, direct communication, and booking-ready pages for photographers, wedding halls, and photo locations.

## Core Product Pillars
1. Content Platform
- Reels
- Stories
- Portfolio grids
- Trending discovery

2. Marketplace
- Photographers
- Wedding halls
- Photo locations
- Requests, offers, bookings, and messaging

3. Monetization Engine
- Subscription plans
- Sponsored ads
- Featured placement
- Future commissions and packages

## Primary Personas
### Customer
- Discovers photographers, halls, and locations
- Watches reels and stories
- Compares options and prices
- Sends requests and books
- Messages suppliers directly

### Photographer
- Publishes portfolio, reels, and stories
- Attracts customers
- Buys subscription plans
- Runs sponsored promotion
- Receives bookings and messages

### Venue / Location Provider
- Publishes venue profile, media, and features
- Appears in discovery surfaces
- Receives inquiries and bookings
- Uses featured placement later

## UX Direction
- Dark luxury visual language
- Gold-accented conversion surfaces
- Content-first browsing
- Fast jump from inspiration to booking
- Arabic-first layout with premium feel

## Screen Scope Implemented In This Slice
1. Home Feed
- Search
- Story-like shortcuts
- Category tabs
- Photographer and venue cards
- Premium bottom navigation with centered create button

2. Explore
- Search
- Category entry cards
- Featured halls section
- Photo locations section

3. Photographer Profile
- Hero cover
- Avatar overlay
- Trust / stats row
- Booking and contact CTA
- Preview / reels / reviews / works tabs

4. Wedding Halls
- Filter chips
- Hall list
- Hall details page

5. Photo Locations
- Location details page
- Gallery / highlights / map CTA

6. Monetization
- Subscription plans page
- Sponsored ad creation page

7. Messages
- Filter tabs
- Premium list rows

## Phase 1 Business Rules
### Subscriptions
- Three plans: Basic, Pro, Elite
- Monthly / yearly pricing toggle
- Plan differences are measurable:
  - portfolio limit
  - reel quota
  - featured priority
  - analytics depth
  - sponsored ad discount or access

### Sponsored Ads
- Promote one of:
  - account
  - reel
  - story
- Duration:
  - 3 days
  - 7 days
  - 14 days
- Region targeting:
  - all Iraq
  - governorate
  - city
- Budget entered before submission
- Admin approval remains required in backend phase

## Data Model Direction
### Existing Core
- users
- photographer_profiles
- bookings
- requests
- offers
- reels
- stories
- media objects
- notifications

### New Planned Entities
- venues
- venue_media
- venue_reviews
- photo_locations
- subscription_plans
- user_subscriptions
- sponsored_ads
- billing_transactions
- boost_campaigns

## Routing Direction
- Main feed remains the default entry for customers and photographers
- Explore becomes the supplier-discovery hub
- Plus CTA opens role-aware creation actions
- Deep links exist for halls, locations, subscriptions, and sponsored ads

## Technical Execution Strategy For This Slice
- No architecture rewrite
- No backend migration in this slice
- UI-first implementation using deterministic local presentation data
- Keep current app routing and role system intact
- Prepare clean screen boundaries so backend integration can be added later

## Not Included In This Slice
- Real subscription billing logic
- Real sponsored ad approval logic
- Real venue backend CRUD
- AI wedding planner
- Full package builder

## Success Criteria For This Slice
- The app visually reflects the approved premium direction
- Main core screens match the design intent closely
- Navigation between the new platform surfaces works
- Existing app build remains healthy
