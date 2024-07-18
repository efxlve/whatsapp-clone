import { validateEmail, validatePassword, validateString } from '../validationConstraints';

export const validateInput = (inputId, inputValue) => {
    if (inputId === "firstName" || inputId === "firstName") {
        return validateString(inputId, inputValue);
    }
    else if (inputId === "email") {
        return validateEmail(inputId, inputValue);
    }
    else if (inputId === "password") {
        return validatePassword(inputId, inputValue);
    }
};