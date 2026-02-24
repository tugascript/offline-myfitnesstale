# Entitlement Functions

This Firebase Functions package exposes three HTTP endpoints:

- `syncEntitlement` -> `POST /entitlements/sync`
- `getEntitlement` -> `GET /entitlements/me?appUserId=<id>`
- `revenueCatWebhook` -> `POST /webhooks/revenuecat`

## Deployment notes

1. Set environment secret: `REVENUECAT_WEBHOOK_SECRET`.
2. Configure your API gateway/rewrite paths to route:
- `/entitlements/sync` -> `syncEntitlement`
- `/entitlements/me` -> `getEntitlement`
- `/webhooks/revenuecat` -> `revenueCatWebhook`
3. Enable Firebase App Check and authentication in front of these functions.
4. Add RevenueCat webhook URL and secret to RevenueCat dashboard.

## Data shape

Firestore collection: `entitlements/{appUserId}`

Fields:
- `entitlement`: `free | premium`
- `status`: `active | grace | expired | billing_issue | unknown`
- `expiresAt`: unix seconds or `null`
- `verificationToken`: short-lived signed token placeholder
- `updatedAt`: unix seconds
- `source`: `server`
