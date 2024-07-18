import React, { useCallback, useReducer } from 'react';
import { Feather } from '@expo/vector-icons';
import Input from '../components/Input';
import SubmitButton from '../components/SubmitButton';
import { validateInput } from '../utils/actions/formActions';
import { reducer } from '../utils/reducers/formReducer';

const initialState = {
    inputValidities: {
        email: false,
        password: false
    },
    formIsValid: false
}

const SignInForm = props => {

    const [formState, dispatchFormState] = useReducer(reducer, initialState);

    const inputChangeHandler = useCallback((inputId, inputValue) => {
        const result = validateInput(inputId, inputValue);
        dispatchFormState({ inputId, validationResult: result })
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
                onInputChanged={inputChangeHandler}
                errorText={formState.inputValidities["email"]}
            />

            <Input
                id="password"
                label="Password"
                icon="lock"
                iconPack={Feather}
                autoCapitalize="none"
                secureTextEntry
                onInputChanged={inputChangeHandler}
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