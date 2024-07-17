import React from "react";
import { NavigationContainer } from '@react-navigation/native';

import MainNavigator from "./MainNavigator";

const AppNavigator = props => {
    return (
        <NavigationContainer>
            <MainNavigator />
        </NavigationContainer>)
};

export default AppNavigator;