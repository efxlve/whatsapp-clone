import React from 'react';
import { StyleSheet } from 'react-native';
import PageContainer from '../components/PageContainer';
import PageTitle from '../components/PageTitle';

const SettingsScreen = props => {
    return <PageContainer>
        <PageTitle text="Settings" />
    </PageContainer>;
};

const styles = StyleSheet.create({
    container: {
        flex: 1
    }
})

export default SettingsScreen;