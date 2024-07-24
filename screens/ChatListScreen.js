import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Button, FlatList } from 'react-native';
import { HeaderButtons, Item } from 'react-navigation-header-buttons';
import CustomHeaderButton from '../components/CustomHeaderButton';
import { useSelector } from 'react-redux';

const ChatListScreen = props => {
    const selectedUser = props.route?.params?.selectedUserId;

    const userData = useSelector(state => state.auth.userData);
    const userChats = useSelector(state => {
        const chatsData = state.chats.chatsData;
        return Object.values(chatsData);
    });

    useEffect(() => {
        props.navigation.setOptions({
            headerRight: () => {
                return <HeaderButtons HeaderButtonComponent={CustomHeaderButton}>
                    <Item 
                        title='New chat'
                        iconName='create-outline'
                        onPress={() => props.navigation.navigate("NewChat")}
                    />
                </HeaderButtons>
            }
        });
    }, []);

    useEffect(() => {
        if (!selectedUser) {
            return;
        }

        const chatUsers = [selectedUser, userData.userId];

        const navigationProps = {
            newChatData: { users: chatUsers }
        }

        props.navigation.navigate("ChatScreen", navigationProps);
    }, [props.route?.params]);

    return <FlatList 
        data={userChats}
        renderItem={(itemData) => {
            const chatData = itemData.item;            
            const otherUserId = chatData.users.find(uid => uid !== userData.userId);

            return <Text>{otherUserId}</Text>
        }}
    />;
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    }
})

export default ChatListScreen;