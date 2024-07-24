import React, { useEffect } from "react";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

import ChatListScreen from '../screens/ChatListScreen';
import ChatSettingsScreen from '../screens/ChatSettingsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import ChatScreen from "../screens/ChatScreen";
import NewChatScreen from "../screens/NewChatScreen";
import { useSelector } from "react-redux";
import { getFirebaseApp } from "../utils/firebaseHelper";
import { child, getDatabase, onValue, ref } from "firebase/database";
const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

const TabNavigator = () => {
    return (
        <Tab.Navigator screenOptions={{
            headerTitle: '',
            headerShadowVisible: false
        }}>
            <Tab.Screen name="ChatList" component={ChatListScreen} options={{
                tabBarLabel: 'Chats',
                tabBarIcon: ({ color, size }) => <Ionicons name="chatbubble-outline" size={size} color={color} />
            }} />
            <Tab.Screen name="Settings" component={SettingsScreen} options={{
                tabBarLabel: 'Settings',
                tabBarIcon: ({ color, size }) => <Ionicons name="settings-outline" size={size} color={color} />
            }} />
        </Tab.Navigator>
    );
};

const StackNavigator = () => {
    <Stack.Navigator>
        <Stack.Group>
            <Stack.Screen name="Home" component={TabNavigator} options={{ headerShown: false }} />
            <Stack.Screen name="ChatScreen" component={ChatScreen} options={{
                gestureEnabled: true,
                headerTitle: "",
                headerBackTitle: "Back"
            }} />
            <Stack.Screen name="ChatSettings" component={ChatSettingsScreen} options={{
                gestureEnabled: true,
                headerTitle: "Settings",
                headerBackTitle: "Back"
            }} />
        </Stack.Group>

        <Stack.Group screenOptions={{ presentation: 'containedModal' }}>
            <Stack.Screen name="NewChat" component={NewChatScreen} />
        </Stack.Group>
    </Stack.Navigator>
}

const MainNavigator = props => {
    const userData = useSelector(state => state.auth.userData);
    const storedUsers = useSelector(state => state.users.storedUsers);

    useEffect(() => {
        console.log("Subscribing to firebase listeners");

        const app = getFirebaseApp();
        const dbRef = ref(getDatabase(app));
        const userChatsRef = child(dbRef, `userChats/${userData.userId}`);

        onValue(userChatsRef, (querySnapshot) => {
            const chatIdsData = querySnapshot.val() || {};
            const chatIds = Object.values(chatIdsData);

            console.log(chatIds);
        });
    }, []);

    return (
        <StackNavigator />
    );
};

export default MainNavigator;