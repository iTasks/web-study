# Native Features

[← Back to Phase 3](README.md) | [Roadmap](../README.md)

## Camera

```bash
# With Expo
npx expo install expo-camera expo-image-picker

# Bare React Native
npm install react-native-vision-camera
```

```tsx
import * as ImagePicker from 'expo-image-picker';

function ProfilePhotoUploader() {
  const [image, setImage] = useState<string | null>(null);

  const pickImage = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      Alert.alert('Permission needed', 'Please allow access to your photos.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });

    if (!result.canceled) {
      setImage(result.assets[0]!.uri);
      await uploadPhoto(result.assets[0]!.uri);
    }
  };

  return (
    <Pressable onPress={pickImage}>
      {image ? (
        <Image source={{ uri: image }} style={styles.avatar} />
      ) : (
        <View style={styles.placeholder}>
          <Text>Add Photo</Text>
        </View>
      )}
    </Pressable>
  );
}
```

---

## Location

```bash
npx expo install expo-location
```

```tsx
import * as Location from 'expo-location';

function useCurrentLocation() {
  const [location, setLocation] = useState<Location.LocationObject | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission denied');
        return;
      }

      const loc = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
      });
      setLocation(loc);
    })();
  }, []);

  return { location, error };
}
```

---

## Push Notifications

```bash
npx expo install expo-notifications expo-device
```

```typescript
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';

// Configure notification behavior
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

async function registerForPushNotifications(): Promise<string | null> {
  if (!Device.isDevice) {
    console.warn('Push notifications require a physical device');
    return null;
  }

  const { status: existing } = await Notifications.getPermissionsAsync();
  let finalStatus = existing;

  if (existing !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }

  if (finalStatus !== 'granted') return null;

  const token = (await Notifications.getExpoPushTokenAsync()).data;
  return token;
}

// Send to your backend for storage
async function syncPushToken(userId: string) {
  const token = await registerForPushNotifications();
  if (token) {
    await apiClient.post('/users/push-token', { token });
  }
}
```

---

## Secure Storage

```bash
npx expo install expo-secure-store
```

```typescript
import * as SecureStore from 'expo-secure-store';

// Store sensitive data encrypted (Keychain on iOS, Keystore on Android)
export const secureStorage = {
  async set(key: string, value: string) {
    await SecureStore.setItemAsync(key, value);
  },
  async get(key: string): Promise<string | null> {
    return SecureStore.getItemAsync(key);
  },
  async remove(key: string) {
    await SecureStore.deleteItemAsync(key);
  },
};

// JWT token management on mobile
export const tokenStorage = {
  async saveTokens(access: string, refresh: string) {
    await Promise.all([
      secureStorage.set('access_token', access),
      secureStorage.set('refresh_token', refresh),
    ]);
  },
  async getAccessToken() {
    return secureStorage.get('access_token');
  },
  async clearTokens() {
    await Promise.all([
      secureStorage.remove('access_token'),
      secureStorage.remove('refresh_token'),
    ]);
  },
};
```

---

## Resources

- [Expo SDK Reference](https://docs.expo.dev/versions/latest/)
- [React Native Vision Camera](https://mrousavy.com/react-native-vision-camera/)
- [Expo Notifications](https://docs.expo.dev/push-notifications/overview/)

---

→ [Expo vs Bare](expo-vs-bare.md) | [Navigation](navigation.md) | [Phase 3 Overview](README.md)
