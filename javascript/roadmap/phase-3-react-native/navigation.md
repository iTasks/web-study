# Navigation with React Navigation

[← Back to Phase 3](README.md) | [Roadmap](../README.md)

## Setup

```bash
npm install @react-navigation/native
npm install react-native-screens react-native-safe-area-context

# Stack navigator
npm install @react-navigation/native-stack

# Tab navigator
npm install @react-navigation/bottom-tabs

# Drawer navigator
npm install @react-navigation/drawer react-native-gesture-handler react-native-reanimated
```

---

## Basic Navigator Structure

```tsx
// App.tsx — navigation root
import { NavigationContainer } from '@react-navigation/native';

function App() {
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  );
}

// Root navigator — switches between auth and main app
function RootNavigator() {
  const { user } = useAuth();
  return user ? <MainNavigator /> : <AuthNavigator />;
}
```

---

## Stack Navigator

```tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Type-safe navigation params
type UsersStackParamList = {
  UserList: undefined;
  UserDetail: { userId: string; name: string };
  EditUser: { userId: string };
};

const Stack = createNativeStackNavigator<UsersStackParamList>();

function UsersNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="UserList"
      screenOptions={{
        headerStyle: { backgroundColor: '#007AFF' },
        headerTintColor: '#fff',
        headerTitleStyle: { fontWeight: '600' },
      }}
    >
      <Stack.Screen
        name="UserList"
        component={UserListScreen}
        options={{ title: 'Users' }}
      />
      <Stack.Screen
        name="UserDetail"
        component={UserDetailScreen}
        options={({ route }) => ({ title: route.params.name })}
      />
      <Stack.Screen
        name="EditUser"
        component={EditUserScreen}
        options={{
          presentation: 'modal',   // iOS modal presentation
          title: 'Edit User',
        }}
      />
    </Stack.Navigator>
  );
}
```

---

## Bottom Tab Navigator

```tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

type TabParamList = {
  Home: undefined;
  Search: undefined;
  Profile: undefined;
};

const Tab = createBottomTabNavigator<TabParamList>();

function MainNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          const icons: Record<keyof TabParamList, string> = {
            Home: focused ? 'home' : 'home-outline',
            Search: focused ? 'search' : 'search-outline',
            Profile: focused ? 'person' : 'person-outline',
          };
          return <Ionicons name={icons[route.name] as any} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#8E8E93',
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
```

---

## Navigation Hooks

```tsx
import { useNavigation, useRoute, useFocusEffect } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';

function UserListScreen() {
  const navigation = useNavigation<NativeStackNavigationProp<UsersStackParamList>>();

  const goToDetail = (user: User) =>
    navigation.navigate('UserDetail', { userId: user.id, name: user.name });

  // Refresh data when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      refetch();
      return () => { /* cleanup on blur */ };
    }, []),
  );

  return (
    <FlatList
      data={users}
      renderItem={({ item }) => (
        <Pressable onPress={() => goToDetail(item)}>
          <UserRow user={item} />
        </Pressable>
      )}
    />
  );
}

// Read params in target screen
function UserDetailScreen() {
  const route = useRoute<RouteProp<UsersStackParamList, 'UserDetail'>>();
  const { userId, name } = route.params;
  // ...
}
```

---

## Deep Linking

```tsx
// Linking configuration
const linking = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: '',
      Users: {
        screens: {
          UserList: 'users',
          UserDetail: 'users/:userId',
        },
      },
    },
  },
};

<NavigationContainer linking={linking}>
  <RootNavigator />
</NavigationContainer>
```

---

## Resources

- [React Navigation Documentation](https://reactnavigation.org/docs/getting-started)
- [Navigation TypeScript](https://reactnavigation.org/docs/typescript)

---

→ [Native Features](native-features.md) | [Core Concepts](core-concepts.md) | [Phase 3 Overview](README.md)
