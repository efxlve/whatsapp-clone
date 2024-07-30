import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useSelector } from 'react-redux';
import PageContainer from '../components/PageContainer';
import PageTitle from '../components/PageTitle';
import ProfileImage from '../components/ProfileImage';

const ChatSettingsScreen = props => {
    const chatId = props.route.params.chatId;
    const chatData = useSelector(state => state.chats.chatsData[chatId]);

    return <PageContainer>
        <PageTitle text="Chat Settings" />

        <ScrollView contentContainerStyle={styles.scrollView}>
            <ProfileImage
                showEditButton={true}
                size={80}
            />

            <Text>{chatData.chatName}</Text>
        </ScrollView>
    </PageContainer>;
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    },
    scrollView: {
        justifyContent: 'center',
        alignItems: 'center'
    }
})

export default ChatSettingsScreen;