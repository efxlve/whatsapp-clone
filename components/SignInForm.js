import React, { useCallback, useReducer } from 'react';
import { Feather } from '@expo/vector-icons';
import Input from '../components/Input';
import SubmitButton from '../components/SubmitButton';

import { validateInput } from '../utils/actions/formActions';
import { reducer } from '../utils/reducers/formReducer';

const initialState = {
    inputValues: {
        email: "",
        password: ""
    },
    inputValidities: {
        email: false,
        password: false
    },
    formIsValid: false
}

const SignInForm = props => {

    const [formState, dispatchFormState] = useReducer(reducer, initialState);

    const inputChangedHandler = useCallback((inputId, inputValue) => {
        const result = validateInput(inputId, inputValue);
        dispatchFormState({ inputId, validationResult: result, inputValue })
    }, [dispatchFormState]);

    return (
        <>
            <Input
                id="email"
                label="Email"
                icon="mail"
                iconPack={Feather}
                autoCapitalize="none"
                keyboardType="email-address"
                onInputChanged={inputChangedHandler}
                errorText={formState.inputValidities["email"]}
            />

            <Input
                id="password"
                label="Password"
                icon="lock"
                iconPack={Feather}
                autoCapitalize="none"
                secureTextEntry
                onInputChanged={inputChangedHandler}
                errorText={formState.inputValidities["password"]}
            />

            <SubmitButton
                title="Sign in"
                onPress={() => console.log("Button pressed")}
                style={{ marginTop: 20 }}
                disabled={!formState.formIsValid}
            />
        </>
    )
};

export default SignInForm;