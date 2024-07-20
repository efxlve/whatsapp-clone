import React, { useCallback, useReducer } from 'react';
import { StyleSheet } from 'react-native';
import { Feather, FontAwesome } from '@expo/vector-icons';
import PageContainer from '../components/PageContainer';
import PageTitle from '../components/PageTitle';
import Input from '../components/Input';
import { validateInput } from '../utils/actions/formActions';
import { reducer } from '../utils/reducers/formReducer';
import { useSelector } from 'react-redux';

const initialState = {
    inputValues: {
        firstName: "",
        lastName: "",
        email: "",
        about: ""
    },
    inputValidities: {
        firstName: false,
        lastName: false,
        email: false,
        about: false
    },
    formIsValid: false
}

const SettingsScreen = props => {
    const userData = useSelector(state => state.auth.userData);
    
    const [formState, dispatchFormState] = useReducer(reducer, initialState);

    const inputChangedHandler = useCallback((inputId, inputValue) => {
        const result = validateInput(inputId, inputValue);
        dispatchFormState({ inputId, validationResult: result, inputValue })
    }, [dispatchFormState]);

    return <PageContainer>
        <PageTitle text="Settings" />
        <Input
            id="firstName"
            label="First name"
            icon="user-o"
            iconPack={FontAwesome}
            onInputChanged={inputChangedHandler}
            autoCapitalize="none"
            errorText={formState.inputValidities["firstName"]}
            initialValue={userData.firstName}
        />

        <Input
            id="lastName"
            label="Last name"
            icon="user-o"
            iconPack={FontAwesome}
            onInputChanged={inputChangedHandler}
            autoCapitalize="none"
            errorText={formState.inputValidities["lastName"]}
            initialValue={userData.lastName}
        />

        <Input
            id="email"
            label="Email"
            icon="mail"
            iconPack={Feather}
            onInputChanged={inputChangedHandler}
            keyboardType="email-address"
            autoCapitalize="none"
            errorText={formState.inputValidities["email"]}
            initialValue={userData.email}
        />

        <Input
            id="about"
            label="About"
            icon="user-o"
            iconPack={FontAwesome}
            onInputChanged={inputChangedHandler}
            autoCapitalize="none"
            errorText={formState.inputValidities["about"]}
            initialValue={userData.about}
        />
    </PageContainer>;
};

const styles = StyleSheet.create({
    container: {
        flex: 1
    }
})

export default SettingsScreen;