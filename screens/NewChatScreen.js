import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Button, TextInput, ActivityIndicator, FlatList } from 'react-native';
import { HeaderButtons, Item } from 'react-navigation-header-buttons';
import CustomHeaderButton from '../components/CustomHeaderButton';
import PageContainer from '../components/PageContainer';
import { FontAwesome } from '@expo/vector-icons';
import colors from '../constants/colors';
import commonStyles from '../constants/commonStyles';
import { searchUsers } from '../utils/actions/userActions';
import DataItem from '../components/DataItem';

const NewChatScreen = props => {
    const [isLoading, setIsLoading] = useState(false);
    const [users, setUsers] = useState();
    const [noResultsFound, setNoResultsFound] = useState(false);
    const [searchTerm, setSearchTerm] = useState(``);

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

    useEffect(() => {
        const delaySearch = setTimeout(async () => {
            if (!searchTerm || searchTerm === "") {
                setUsers();
                setNoResultsFound(false);
                return;
            }

            setIsLoading(true);

            const usersResult = await searchUsers(searchTerm);
            setUsers(usersResult);

            if (Object.keys(usersResult).length === 0) {
                setNoResultsFound(true);
            } else {
                setNoResultsFound(false);
            }

            setIsLoading(false);
        }, 500);

        return () => clearTimeout(delaySearch);
    }, [searchTerm]);

    return <PageContainer>
        <View style={styles.searchContainer}>
            <FontAwesome name='search' size={15} color={colors.lightGrey} />

            <TextInput
                placeholder='Search'
                style={styles.searchBox}
                onChangeText={(text) => setSearchTerm(text)}
            />
        </View>

        {
            isLoading &&
            <View style={commonStyles.center}>
                <ActivityIndicator size={'large'} color={colors.primary} />
            </View>
        }

        {
            !isLoading && !noResultsFound && users &&
            <FlatList
                data={Object.keys(users)}
                renderItem={(itemData) => {
                    const userId = itemData.item;
                    const userData = users[userId];
                    return <DataItem
                        title={`${userData.firstName} ${userData.lastName}`}
                        subTitle={userData.about}
                        image={userData.profilePicture}
                    />;
                }}
            />
        }

        {
            !isLoading && noResultsFound && (
                <View style={commonStyles.center}>
                    <FontAwesome
                        name='question'
                        size={55}
                        color={colors.lightGrey}
                        style={styles.noResultsIcon}
                    />
                    <Text style={styles.noResultsText}>No users found</Text>
                </View>
            )
        }

        {
            !isLoading && !users && (
                <View style={commonStyles.center}>
                    <FontAwesome
                        name='users'
                        size={55}
                        color={colors.lightGrey}
                        style={styles.noResultsIcon}
                    />
                    <Text style={styles.noResultsText}>Enter a name to search for a user</Text>
                </View>
            )
        }

    </PageContainer >;
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
    },
    noResultsIcon: {
        marginBottom: 20
    },
    noResultsText: {
        color: colors.textColor,
        fontFamily: 'regular',
        letterSpacing: 0.3
    }
});

export default NewChatScreen;