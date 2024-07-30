import { validateEmail, validatePassword, validateString, validateLength } from '../validationConstraints';

export const validateInput = (inputId, inputValue) => {
    if (inputId === "firstName" || inputId === "lastName") {
        return validateString(inputId, inputValue);
    }
    else if (inputId === "email") {
        return validateEmail(inputId, inputValue);
    }
    else if (inputId === "password") {
        return validatePassword(inputId, inputValue);
    }
    else if (inputId === "about") {
        return validateLength(inputId, inputValue, 0, 150, true);
    }
    else if (inputId === "chatName") {
        return validateLength(inputId, inputValue, 5, 50, false);
    }
};