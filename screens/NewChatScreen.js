import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Button, TextInput } from 'react-native';
import { HeaderButtons, Item } from 'react-navigation-header-buttons';
import CustomHeaderButton from '../components/CustomHeaderButton';
import PageContainer from '../components/PageContainer';
import { FontAwesome } from '@expo/vector-icons';
import colors from '../constants/colors';

const NewChatScreen = props => {
    useEffect(() => {
        props.navigation.setOptions({
            headerLeft: () => {
                return <HeaderButtons HeaderButtonComponent={CustomHeaderButton}>
                    <Item 
                        title='Close'
                        onPress={() => props.navigation.goBack()}
                    />
                </HeaderButtons>
            },
            headerTitle: "New chat"
        });
    }, []);

    return <PageContainer>
        <View style={styles.searchContainer}>
            <FontAwesome name='search' size={15} color={colors.lightGrey} />

            <TextInput 
                placeholder='Search'
                style={styles.searchBox}
                onChangeText={() => {}}
            />
        </View>
    </PageContainer>;
};

const styles = StyleSheet.create({
    searchContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.extraLightGrey,
        height: 30,
        marginVertical: 8,
        paddingHorizontal: 8,
        paddingVertical: 5,
        borderRadius: 16
    },
    searchBox: {
        marginLeft: 8,
        fontSize: 15,
        width: '100%'
    }
});

export default NewChatScreen;