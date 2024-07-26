import React, { useCallback, useEffect, useState } from "react";
import {
    View,
    StyleSheet,
    ImageBackground,
    TextInput,
    TouchableOpacity,
    KeyboardAvoidingView,
    Platform,
    FlatList,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Feather } from "@expo/vector-icons";

import backgroundImage from "../assets/images/BackgroundImage.png";
import colors from "../constants/colors";
import { useSelector } from "react-redux";
import PageContainer from "../components/PageContainer";
import Bubble from "../components/Bubble";
import { createChat, sendTextMessage } from "../utils/actions/chatActions";

const ChatScreen = (props) => {
    const [chatUsers, setChatUsers] = useState([]);
    const [messageText, setMessageText] = useState("");
    const [chatId, setChatId] = useState(props.route?.params?.chatId);
    const [errorBannerText, setErrorBannerText] = useState("");

    const userData = useSelector(state => state.auth.userData);
    const storedUsers = useSelector(state => state.users.storedUsers);
    const storedChats = useSelector(state => state.chats.chatsData);
    const chatMessages = useSelector(state => {
        if (!chatId) return [];

        const chatMessagesData = state.messages.messagesData[chatId];

        if (!chatMessagesData) return [];

        const messageList = [];
        for (const key in chatMessagesData) {
            const message = chatMessagesData[key];

            messageList.push({
                key,
                ...message
            });
        }

        return messageList;
    });

    const chatData = (chatId && storedChats[chatId]) || props.route?.params?.newChatData;

    const getChatTitleFromName = () => {
        const otherUserId = chatUsers.find(uid => uid !== userData.userId);
        const otherUserData = storedUsers[otherUserId];

        return otherUserData && `${otherUserData.firstName} ${otherUserData.lastName}`;
    }

    useEffect(() => {
        props.navigation.setOptions({
            headerTitle: getChatTitleFromName()
        })
        setChatUsers(chatData.users)
    }, [chatUsers])

    const sendMessage = useCallback(async () => {

        try {
            let id = chatId;
            if (!id) {
                // No chat Id. Create the chat
                id = await createChat(userData.userId, props.route.params.newChatData);
                setChatId(id);
            }

            await sendTextMessage(chatId, userData.userId, messageText);

            setMessageText("");
        } catch (error) {
            console.log(error);
            setErrorBannerText("Message failed to send");
            setTimeout(() => setErrorBannerText(""), 5000);
        }
    }, [messageText, chatId]);

    return (
        <SafeAreaView edges={["right", "left", "bottom"]} style={styles.container}>
            <KeyboardAvoidingView
                style={styles.screen}
                behavior={Platform.OS === "ios" ? "padding" : undefined}
                keyboardVerticalOffset={100}>
                <ImageBackground
                    source={backgroundImage}
                    style={styles.backgroundImage}
                >
                    <PageContainer style={{ backgroundColor: 'transparent' }}>

                        {
                            !chatId && <Bubble text='This is a new chat. Say hi!' type="system" />
                        }

                        {
                            errorBannerText !== "" && <Bubble text={errorBannerText} type="error" />
                        }

                        {
                            chatId &&
                            <FlatList
                                data={chatMessages}
                                renderItem={(itemData) => {
                                    const message = itemData.item;

                                    const isOwnMessage = message.sentBy === userData.userId;

                                    const messageType = isOwnMessage ? "myMessage" : "theirMessage";


                                    return <Bubble
                                        type={messageType}
                                        text={message.text}
                                        messageId={message.key}
                                        userId={userData.userId}
                                        chatId={chatId}
                                    />
                                }}
                            />
                        }


                    </PageContainer>
                </ImageBackground>

                <View style={styles.inputContainer}>
                    <TouchableOpacity
                        style={styles.mediaButton}
                        onPress={() => console.log("Pressed!")}
                    >
                        <Feather name="plus" size={24} color={colors.blue} />
                    </TouchableOpacity>

                    <TextInput
                        style={styles.textbox}
                        value={messageText}
                        onChangeText={(text) => setMessageText(text)}
                        onSubmitEditing={sendMessage}
                    />

                    {messageText === "" && (
                        <TouchableOpacity
                            style={styles.mediaButton}
                            onPress={() => console.log("Pressed!")}
                        >
                            <Feather name="camera" size={24} color={colors.blue} />
                        </TouchableOpacity>
                    )}

                    {messageText !== "" && (
                        <TouchableOpacity
                            style={{ ...styles.mediaButton, ...styles.sendButton }}
                            onPress={sendMessage}
                        >
                            <Feather name="send" size={20} color={"white"} />
                        </TouchableOpacity>
                    )}
                </View>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: "column",
    },
    screen: {
        flex: 1
    },
    backgroundImage: {
        flex: 1,
    },
    inputContainer: {
        flexDirection: "row",
        paddingVertical: 8,
        paddingHorizontal: 10,
        height: 50,
    },
    textbox: {
        flex: 1,
        borderWidth: 1,
        borderRadius: 50,
        borderColor: colors.lightGrey,
        marginHorizontal: 15,
        paddingHorizontal: 12,
    },
    mediaButton: {
        alignItems: "center",
        justifyContent: "center",
        width: 35,
    },
    sendButton: {
        backgroundColor: colors.blue,
        borderRadius: 50,
        padding: 8,
    },
});

export default ChatScreen;
