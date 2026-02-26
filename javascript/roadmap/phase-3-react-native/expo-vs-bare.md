# Expo vs Bare React Native

[← Back to Phase 3](README.md) | [Roadmap](../README.md)

## Comparison

| Feature | Expo (Managed) | Bare React Native |
|---------|---------------|-------------------|
| Setup time | Minutes | Hours |
| OTA updates | ✅ EAS Update | ❌ App store required |
| Native module access | Limited (Expo SDK) | ✅ Full access |
| Custom native code | ❌ (use config plugins) | ✅ Unlimited |
| Build service | ✅ EAS Build (cloud) | Self-managed or EAS |
| Good for MVP | ✅ | ⚠️ |
| Good for production | ✅ Most apps | ✅ Complex native needs |
| Community libraries | Some need ejecting | ✅ All compatible |

---

## When to Use Expo

- Rapid prototyping or MVP
- Your team lacks iOS/Android native experience
- You want cloud builds (no Mac required for iOS)
- OTA updates are a priority (bug fixes without App Store review)
- You can work within the Expo SDK capabilities

```bash
# Start with Expo
npx create-expo-app my-app --template blank-typescript
cd my-app

# Run on device
npx expo start
# Scan QR with Expo Go app

# Production builds via EAS
npm install -g eas-cli
eas login
eas build --platform ios
eas build --platform android
```

---

## When to Use Bare React Native

- Need a native SDK not covered by Expo (BLE, VoIP, AR, custom hardware)
- Existing native iOS/Android codebase integration
- Maximum performance requirements
- Full control over native build configuration

```bash
# Bare React Native with TypeScript
npx @react-native-community/cli init MyApp --template react-native-template-typescript

# Run
npx react-native run-ios
npx react-native run-android
```

---

## Expo + EAS Build (Production Workflow)

```yaml
# eas.json — build profiles
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": { "buildType": "apk" }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "your@email.com", "ascAppId": "XXXXXXXXXX" },
      "android": { "serviceAccountKeyPath": "./google-service-account.json" }
    }
  }
}
```

```bash
# Build and submit to stores
eas build --platform all --profile production
eas submit --platform all
```

---

## Recommendation

**Start with Expo** unless you have a specific reason not to. You can always "eject" to bare workflow later, or use Expo with bare workflow from the start if needed.

---

→ [Phase 3 Overview](README.md) | [Phase 4 – Python Backend](../phase-4-python-backend/README.md)
