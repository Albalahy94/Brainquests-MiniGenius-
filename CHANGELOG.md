# Changelog

All notable changes to the **Brainquests (Mini Genius)** project will be documented in this file.

---

## [2.0.1+4] - 2026-11-01

### Added
- **Brainquests Pro / VIP Tier (Levels 11-20)** across all 10 core games.
- **Jigsaw Puzzle v2**: Built a full library of 20 distinct vector-rendered scenes (`PuzzleLibrary`) with dynamic piece slicing (4 to 25 pieces) and full-preview modal.
- **Find the Difference v2**: Built 20 unique thematic scenes (`DifferenceLibrary`) with custom difference spots per scene, responsive dual canvas, celebration markers, and hint system.
- **Cognitive Development Radar**: Added 6-dimensional radar chart in Parent Dashboard tracking Memory, Logic, Speed, Focus, Math, and Language.
- **Direct WhatsApp Support**: Integrated WhatsApp support button for phone `+201067481561` in both Settings and Parent Dashboard, protected by Parental Gate.
- **Albalahy Central Licensing Hub Integration**:
  - Registered app `brainquests` with API key `bq_live_7c8d9e0f1a2b3c4d`.
  - Added `LicensingApiService` using native `dart:io` `HttpClient`.
  - Added `showRedeemCodeDialog` in Settings and Paywall to redeem VIP license keys.
  - Pre-seeded test keys: `BRAIN-VIP-2026` (Lifetime) and `BRAIN-YEAR-2026` (1 Year).
- **Apple App Store Review Compliance**:
  - StoreKit auto-renewable subscriptions paywall (`minigenius_monthly`, `minigenius_yearly` with 7-day trial, `minigenius_lifetime`).
  - Prominent "Restore Purchases" button.
  - Auto-renewal terms & cancellation instructions.
  - Separate clickable links for Privacy Policy and standard Apple Terms of Use (EULA).
  - 100% ad-free (AdMob stripped) and zero tracking SDKs for COPPA compliance.

### Fixed
- Fixed single image reuse in Jigsaw Puzzle and Find the Difference.
- Reverted unintended Gradle 9.x bump to stable Gradle 8.14.
- Zero `dart analyze` compilation errors across the codebase.

---

For detailed implementation notes and documentation, see:
- [`docs/Fixes_and_Guides/PROJECT_UPDATE_LOG_V2.md`](file:///d:/projects/Brainquests/docs/Fixes_and_Guides/PROJECT_UPDATE_LOG_V2.md)
- [`docs/Fixes_and_Guides/VERSION_2_SUBSCRIPTIONS_AND_STORE_SETUP.md`](file:///d:/projects/Brainquests/docs/Fixes_and_Guides/VERSION_2_SUBSCRIPTIONS_AND_STORE_SETUP.md)

