# E000 connected baseline completion screenshot

- Captured: 2026-08-01 20:43 Asia/Tokyo
- App source commit: `10919f9`
- Run ID: `00000000-0000-0000-0000-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- SHA-256: `921b17b0ded9b67e25332c2d1a8177f02d240ce7cb9de1f57231deceeab21228`

## What it shows

- The automated run ended 100 spans.
- The run ID is visible in the app.
- Persistence was disabled.
- Status correctly says host reconciliation is required.

## UI defect exposed

The Delivery card renders `0.0%` while the app explicitly has no receipt data.
Host reconciliation later proved 100% delivery. Rendering zero therefore confuses
"not reconciled" with "nothing arrived". Preserve this screenshot as the defect
record; a follow-up commit changes the unresolved state to `Pending`.

