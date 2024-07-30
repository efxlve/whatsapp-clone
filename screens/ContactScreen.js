import React, { useEffect, useState } from "react";
import { StyleSheet, View, Text } from "react-native";
import { useSelector } from "react-redux";
import PageContainer from "../components/PageContainer";
import ProfileImage from "../components/ProfileImage";
import PageTitle from "../components/PageTitle";
import colors from "../constants/colors";
import { getUserChats } from "../utils/actions/userActions";
import DataItem from "../components/DataItem";
import SubmitButton from "../components/SubmitButton";

const ContactScreen = props => {
    const storedUsers = useSelector(state => state.users.storedUsers);
    const currentUser = storedUsers[props.route.params.uid];

    const storedChats = useSelector(state => state.chats.chatsData);
    const [commonChats, setCommonChats] = useState([]);

    const chatId = props.route.params.chatId;
    const chatData = chatId && storedChats[chatId];

    useEffect(() => {
        const getCommonUserChats = async () => {
            const currentUserChats = await getUserChats(currentUser.userId);
            setCommonChats(
                Object.values(currentUserChats).filter(cid => storedChats[cid] && storedChats[cid].isGroupChat)
            )
        }

        getCommonUserChats();
    }, []);

    return <PageContainer>
        <View style={styles.topContainer}>
            <ProfileImage
                uri={currentUser.profilePicture}
                size={80}
                style={{ marginBottom: 20 }}
            />

            <PageTitle text={`${currentUser.firstName} ${currentUser.lastName}`} />
            {
                currentUser.about &&
                <Text style={styles.about} numberOfLines={2}>{currentUser.about}</Text>
            }
        </View>

        {
            commonChats.length > 0 &&
            <>
                <Text style={styles.heading}>{commonChats.length} {commonChats.length === 1 ? "Group" : "Groups"} in Common</Text>
                {
                    commonChats.map(cid => {
                        const chatData = storedChats[cid];
                        return <DataItem 
                            key={cid}
                            title={chatData.chatName}
                            subTitle={chatData.latestMessageTtext}
                            type="link"
                            onPress={() => props.navigation.push("ChatScreen", { chatId: cid })}
                            image={chatData.chatImage}
                        />
                    })
                }
            </>
        }

        {
            chatData && chatData.isGroupChat &&
            <SubmitButton 
                title="Remove from chat"
                color={colors.red}
            />
        }

    </PageContainer>
};

const styles = StyleSheet.create({
    topContainer: {
        alignItems: 'center',
        justifyContent: 'center',
        marginVertical: 20
    },
    about: {
        fontFamily: 'medium',
        fontSize: 16,
        letterSpacing: 0.3,
        color: colors.grey
    },
    heading: {
        fontFamily: 'bold',
        letterSpacing: 0.3,
        color: colors.textColor,
        marginVertical: 8
    }
});

export default ContactScreen;