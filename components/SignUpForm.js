import React, { useCallback, useReducer } from 'react';
import { Feather, FontAwesome } from '@expo/vector-icons';
import Input from '../components/Input';
import SubmitButton from '../components/SubmitButton';
import { validateInput } from '../utils/actions/formActions';
import { reducer } from '../utils/reducers/formReducer';

const initialState = {
    inputValidities: {
        firstName: false,
        lastName: false,
        email: false,
        password: false
    },
    formIsValid: false
}

const SignUpForm = props => {
    const [formState, dispatchFormState] = useReducer(reducer, initialState);

    const inputChangeHandler = useCallback((inputId, inputValue) => {
        const result = validateInput(inputId, inputValue);
        dispatchFormState({ inputId, validationResult: result })
    }, [dispatchFormState]);

    return (
        <>
            <Input
                id="firstName"
                label="First name"
                icon="user-o"
                iconPack={FontAwesome}
                onInputChanged={inputChangeHandler}
                autoCapitalize="none"
                errorText={formState.inputValidities["firstName"]}
            />

            <Input
                id="lastName"
                label="Last name"
                icon="user-o"
                iconPack={FontAwesome}
                onInputChanged={inputChangeHandler}
                autoCapitalize="none"
                errorText={formState.inputValidities["lastName"]}
            />

            <Input
                id="email"
                label="Email"
                icon="mail"
                iconPack={Feather}
                onInputChanged={inputChangeHandler}
                keyboardType="email-address"
                autoCapitalize="none"
                errorText={formState.inputValidities["email"]}
            />

            <Input
                id="password"
                label="Password"
                icon="lock"
                autoCapitalize="none"
                secureTextEntry
                iconPack={Feather}
                onInputChanged={inputChangeHandler}
                errorText={formState.inputValidities["password"]}
            />

            <SubmitButton
                title="Sign up"
                onPress={() => console.log("Button pressed")}
                style={{ marginTop: 20 }}
                disabled={!formState.formIsValid}
            />
        </>
    )
};

export default SignUpForm;