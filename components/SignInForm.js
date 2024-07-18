import React from 'react';
import { Feather } from '@expo/vector-icons';
import Input from '../components/Input';
import SubmitButton from '../components/SubmitButton';
import { validateInput } from '../utils/actions/formActions';

const SignInForm = props => {

    const inputChangeHandler = (inputId, inputValue) => {
        console.log(validateInput(inputId, inputValue));
    }

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
            />

            <Input
                id="password"
                label="Password"
                icon="lock"
                iconPack={Feather}
                autoCapitalize="none"
                secureTextEntry
                onInputChanged={inputChangeHandler}
            />

            <SubmitButton
                title="Sign in"
                onPress={() => console.log("Button pressed")}
                style={{ marginTop: 20 }}
            />
        </>
    )
};

export default SignInForm;