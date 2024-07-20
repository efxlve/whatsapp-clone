import React from "react";
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

import ChatListScreen from '../screens/ChatListScreen';
import ChatSettingsScreen from '../screens/ChatSettingsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import ChatScreen from "../screens/ChatScreen";

const Stack = createStackNavigator();
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

const MainNavigator = props => {
    return (
        <Stack.Navigator>
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
        </Stack.Navigator>
    );
};

export default MainNavigator;