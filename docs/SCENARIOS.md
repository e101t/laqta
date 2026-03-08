# LAQTA Scenarios

Date: 2026-03-08
Purpose: Current executable scenarios aligned with the migrated app shell and routing flow

## Entry and Routing Scenarios

### SC-01 First Launch Without Language Selection
Expected flow:
1. Splash route loads
2. Router detects missing language preference
3. User is redirected to language selection
4. After selection, user is redirected to auth

### SC-02 Signed-Out User
Expected flow:
1. Splash route loads
2. Router detects no authenticated user
3. User is redirected to auth

### SC-03 Signed-In User With Incomplete Profile
Expected flow:
1. Router loads authenticated user
2. Profile status is fetched
3. If profile is incomplete, user is sent to basic info
4. Completing profile returns the user to the main shell

### SC-04 Blocked User
Expected flow:
1. Router loads authenticated user
2. Profile status indicates admin block marker
3. User is redirected to blocked-account screen

## Customer Scenarios

### SC-10 Customer Main Shell
Expected tabs:
- Dashboard
- Explore
- Shop
- My Bookings
- Chat
- Profile

### SC-11 Customer Creates a Request Draft
Expected flow:
1. Open create-request screen
2. Provide future date/time and location
3. Save draft or submit request
4. Request appears in customer requests list

### SC-12 Customer Accepts an Offer
Expected flow:
1. Customer opens request details
2. Customer accepts a photographer offer
3. Booking record is created or updated
4. Booking details reflect the new status

## Photographer Scenarios

### SC-20 Photographer Main Shell
Expected tabs:
- Dashboard
- Explore
- Requests
- My Bookings
- Chat
- Profile

### SC-21 Photographer Submits an Offer
Expected flow:
1. Photographer opens open requests
2. Photographer submits an offer
3. Offer is associated with the request
4. Customer can review the offer later

### SC-22 Photographer Creates a Post
Expected flow:
1. Photographer opens create-post screen
2. Media is selected
3. Post is uploaded or mocked in test mode
4. Create action completes without router breakage

### SC-23 Photographer Creates a Story
Expected flow:
1. Photographer opens create-story screen
2. Image is selected
3. Story is uploaded or mocked in test mode
4. Create action completes successfully

## Admin Scenarios

### SC-30 Admin Main Shell
Expected tabs:
- Dashboard
- Disputes
- Reports
- Users
- Profile

### SC-31 Admin Blocks a User
Expected flow:
1. Admin opens users screen
2. Admin adds block marker
3. Blocked user is redirected away from the normal shell on next routing check

## Regression Scenarios Worth Re-Running After Router Changes

- Language selection -> auth -> profile setup
- Customer dashboard load with empty data
- Explore screen open with no feed data
- Request creation and bookings navigation
- Chat list routing from the main shell
- Admin blocked-account redirect
- Payment screen routing with booking metadata

## Automated Coverage

The following automated checks currently cover parts of these scenarios:
- `test/widgets/app_router_auth_test.dart`
- `test/widgets/app_router_profile_flow_test.dart`
- `test/widgets/auth_screen_test.dart`
- `test/widgets/customer_dashboard_screen_test.dart`
- `test/widgets/explore_screen_test.dart`
- `test/widgets/payment_screen_test.dart`
- `integration_test/app_flow_test.dart`
- `integration_test/booking_flow_test.dart`
