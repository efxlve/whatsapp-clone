import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Button, FlatList, TouchableOpacity } from 'react-native';
import { HeaderButtons, Item } from 'react-navigation-header-buttons';
import CustomHeaderButton from '../components/CustomHeaderButton';
import { useSelector } from 'react-redux';
import DataItem from '../components/DataItem';
import PageContainer from '../components/PageContainer';
import colors from '../constants/colors';

const ChatListScreen = props => {
    const selectedUser = props.route?.params?.selectedUserId;
    const selectedUserList = props.route?.params?.selectedUsers;
    const chatName = props.route?.params?.chatName;

    const userData = useSelector(state => state.auth.userData);
    const storedUsers = useSelector(state => state.users.storedUsers);
    const userChats = useSelector(state => {
        const chatsData = state.chats.chatsData;
        return Object.values(chatsData).sort((a, b) => {
            return new Date(b.updatedAt) - new Date(a.updatedAt);
        });
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
        if (!selectedUser && !selectedUserList) {
            return;
        }

        let chatData;
        let navigationProps

        if (selectedUser) {
            chatData = userChats.find(cd => !cd.isGroupChat && cd.users.includes(selectedUser))
        }

        if (chatData) {
            navigationProps = { chatId: chatData.key }
        } else {
            const chatUsers = selectedUserList || [selectedUser];
            if (!chatUsers.includes(userData.userId)) {
                chatUsers.push(userData.userId);
            }

            navigationProps = {
                newChatData: {
                    users: chatUsers,
                    isGroupChat: selectedUserList !== undefined,
                }
            }

            if (chatName) {
                navigationProps.chatName = chatName;
            }
        }

        props.navigation.navigate("ChatScreen", navigationProps);
    }, [props.route?.params]);

    return <PageContainer>
        <PageTitle text="Chats" />

        <View>
            <TouchableOpacity onPress={() => props.navigation.navigate("NewChat", { isGroupChat: true })}>
                <Text style={styles.newGroupChat}>New Group</Text>
            </TouchableOpacity>
        </View>

        <FlatList
            data={userChats}
            renderItem={(itemData) => {
                const chatData = itemData.item;
                const chatId = chatData.key;

                const otherUserId = chatData.users.find(uid => uid !== userData.userId);
                const otherUser = storedUsers[otherUserId];

                if (!otherUser) return;

                const title = `${otherUser.firstName} ${otherUser.lastName}`;
                const subTitle = chatData.latestMessageText || "New chat";
                const image = otherUser.profilePicture;

                return <DataItem
                    title={title}
                    subTitle={subTitle}
                    image={image}
                    onPress={() => props.navigation.navigate("ChatScreen", { chatId })}
                />
            }}
        />
    </PageContainer>
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    },
    newGroupChat: {
        color: colors.blue,
        fontSize: 17,
        marginBottom: 5
    }
})

export default ChatListScreen;