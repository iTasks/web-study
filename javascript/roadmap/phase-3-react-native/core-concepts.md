# React Native Core Concepts

[← Back to Phase 3](README.md) | [Roadmap](../README.md)

## Native Components vs HTML

React Native renders to native UI — no HTML, no browser DOM.

```tsx
import {
  View,
  Text,
  Image,
  TextInput,
  ScrollView,
  FlatList,
  Pressable,
  StyleSheet,
  Platform,
} from 'react-native';

function UserCard({ user }: { user: User }) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
      <View style={styles.info}>
        <Text style={styles.name}>{user.name}</Text>
        <Text style={styles.email}>{user.email}</Text>
      </View>
      <Pressable
        style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}
        onPress={() => onSelect(user.id)}
      >
        <Text style={styles.buttonText}>View Profile</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',    // horizontal layout
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 12,
    marginHorizontal: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,            // Android shadow
  },
  avatar: { width: 48, height: 48, borderRadius: 24 },
  info: { flex: 1, marginLeft: 12 },
  name: { fontSize: 16, fontWeight: '600', color: '#111' },
  email: { fontSize: 14, color: '#666', marginTop: 2 },
  button: { paddingHorizontal: 12, paddingVertical: 6, backgroundColor: '#007AFF', borderRadius: 8 },
  buttonPressed: { opacity: 0.7 },
  buttonText: { color: '#fff', fontWeight: '600' },
});
```

---

## Flexbox in React Native

React Native uses Flexbox — **column** direction by default (unlike CSS where row is default).

```tsx
const styles = StyleSheet.create({
  // Column layout (default)
  container: {
    flex: 1,
    flexDirection: 'column',   // default, top to bottom
    justifyContent: 'center',  // main axis (vertical)
    alignItems: 'center',      // cross axis (horizontal)
  },

  // Row layout
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  // Responsive sizing
  fullWidth: { flex: 1 },           // take remaining space
  halfWidth: { flex: 0.5 },        // half of parent
  fixedWidth: { width: 100 },      // fixed px
  percentWidth: { width: '50%' },  // percentage
});
```

---

## Lists

```tsx
// FlatList — virtualized, essential for large data sets
function UserListScreen() {
  const { data, isLoading } = useUsers();

  return (
    <FlatList
      data={data}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => <UserCard user={item} />}
      ListEmptyComponent={<EmptyState />}
      ListHeaderComponent={<ListHeader />}
      refreshControl={
        <RefreshControl
          refreshing={isLoading}
          onRefresh={refetch}
          tintColor="#007AFF"
        />
      }
      onEndReached={loadMore}        // pagination
      onEndReachedThreshold={0.3}   // trigger 30% from bottom
      ItemSeparatorComponent={() => <View style={styles.separator} />}
    />
  );
}
```

---

## Platform-Specific Code

```tsx
import { Platform } from 'react-native';

// Inline platform check
const fontSize = Platform.OS === 'ios' ? 16 : 14;
const shadowStyle = Platform.select({
  ios: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
  },
  android: {
    elevation: 4,
  },
  default: {},
});

// Platform-specific files (auto-resolved by Metro bundler)
// Button.ios.tsx    — loaded on iOS
// Button.android.tsx — loaded on Android
// Button.tsx        — fallback
```

---

## Safe Area

Essential for notch/island devices.

```bash
npm install react-native-safe-area-context
```

```tsx
import { SafeAreaProvider, SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

// Wrap app
function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

// Use in screens
function HomeScreen() {
  const insets = useSafeAreaInsets();
  return (
    <View style={{ flex: 1, paddingTop: insets.top }}>
      {/* content */}
    </View>
  );
}
```

---

## Resources

- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Native Components](https://reactnative.dev/docs/components-and-apis)
- [Expo Documentation](https://docs.expo.dev/)

---

→ [Navigation](navigation.md) | [Phase 3 Overview](README.md)
