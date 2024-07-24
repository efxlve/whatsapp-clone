import React, { useEffect } from "react";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Ionicons } from "@expo/vector-icons";

import ChatSettingsScreen from "../screens/ChatSettingsScreen";
import SettingsScreen from "../screens/SettingsScreen";
import ChatListScreen from "../screens/ChatListScreen";
import ChatScreen from "../screens/ChatScreen";
import NewChatScreen from "../screens/NewChatScreen";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { useSelector } from "react-redux";
import { getFirebaseApp } from "../utils/firebaseHelper";
import { child, getDatabase, off, onValue, ref } from "firebase/database";

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

const TabNavigator = () => {
    return (
        <Tab.Navigator screenOptions={{
            headerTitle: "",
            headerShadowVisible: false
        }}>
            <Tab.Screen
                name="ChatList"
                component={ChatListScreen}
                options={{
                    tabBarLabel: "Chats",
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="chatbubble-outline" size={size} color={color} />
                    ),
                }}
            />
            <Tab.Screen
                name="Settings"
                component={SettingsScreen}
                options={{
                    tabBarLabel: "Settings",
                    tabBarIcon: ({ color, size }) => (
                        <Ionicons name="settings-outline" size={size} color={color} />
                    ),
                }}
            />
        </Tab.Navigator>
    );
};

const StackNavigator = () => {
    return (
        <Stack.Navigator>
            <Stack.Group>
                <Stack.Screen
                    name="Home"
                    component={TabNavigator}
                    options={{ headerShown: false }}
                />
                <Stack.Screen
                    name="ChatScreen"
                    component={ChatScreen}
                    options={{
                        headerTitle: "",
                        headerBackTitle: "Back",
                    }}
                />
                <Stack.Screen
                    name="ChatSettings"
                    component={ChatSettingsScreen}
                    options={{
                        headerTitle: "Settings",
                        headerBackTitle: "Back",
                    }}
                />
            </Stack.Group>

            <Stack.Group screenOptions={{ presentation: 'containedModal' }}>
                <Stack.Screen
                    name="NewChat"
                    component={NewChatScreen}
                />
            </Stack.Group>
        </Stack.Navigator>
    )
}

const MainNavigator = (props) => {

    const userData = useSelector(state => state.auth.userData);
    const storedUsers = useSelector(state => state.users.storedUsers);

    useEffect(() => {
        console.log("Subscribing to firebase listeners");

        const app = getFirebaseApp();
        const dbRef = ref(getDatabase(app));
        const userChatsRef = child(dbRef, `userChats/${userData.userId}`);
        const refs = [userChatsRef];

        onValue(userChatsRef, (querySnapshot) => {
            const chatIdsData = querySnapshot.val() || {};
            const chatIds = Object.values(chatIdsData);

            const chatsData = {};
            let chatsFoundCount = 0;

            for (let i = 0; i < chatIds.length; i++) {
                const chatId = chatIds[i];
                const chatRef = child(dbRef, `chats/${chatId}`);
                refs.push(chatRef);

                onValue(chatRef, (chatSnapshot) => {
                    chatsFoundCount++;
                    console.log(chatSnapshot.val());
                });
            };

            console.log(chatIds);
        })

        return () => {
            console.log("Unsubscribing firebase listeners");
            refs.forEach(ref => off(ref));
        }
    }, []);


    return (
        <StackNavigator />
    );
};

export default MainNavigator;
