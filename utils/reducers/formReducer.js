export const reducer = (state, action) => {
    const { validationResult, inputId } = action;

    const updatedValidities = {
        ...state.inputValidities,
        [inputId]: validationResult
    };

    let updatedFormIsValid = true;

    for (const key in updatedValidities) {
        if (updatedValidities[key] !== undefined) {
            updatedFormIsValid = false;
            break;
        }
    };

    return {
        inputValidities: updatedValidities,
        formIsValid: updatedFormIsValid
    };
};