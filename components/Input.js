import { StyleSheet, Text, TextInput, View } from "react-native"

import colors from "../constants/colors";

const Input = props => {

    const onChangeText = text => {
        props.onInputChanged(props.id, text);
    }

    return <View style={styles.container}>
        <Text style={styles.label}>{props.label}</Text>

        <View style={styles.inputContainer}>
            {
                props.icon && <props.iconPack
                    name={props.icon}
                    size={props.iconSize || 15}
                    style={styles.icon} />
            }
            <TextInput
                { ...props }
                style={styles.input}
                onChangeText={onChangeText}
            />
        </View>

        {
            props.errorText &&
            <View style={styles.errorContainer}>
                <Text style={styles.errorText}>{props.errorText[0]}</Text>
            </View>
        }
    </View>
};

const styles = StyleSheet.create({
    container: {
        width: '100%'
    },
    label: {
        marginVertical: 8,
        fontFamily: 'bold',
        letterSpacing: 0.3,
        color: colors.textColor
    },
    inputContainer: {
        width: '100%',
        backgroundColor: 'red',
        paddingHorizontal: 10,
        paddingVertical: 15,
        borderRadius: 2,
        backgroundColor: colors.nearlyWhite,
        flexDirection: 'row',
        alignItems: 'center'
    },
    icon: {
        marginRight: 10,
        color: colors.grey
    },
    input: {
        color: colors.textColor,
        flex: 1,
        fontFamily: 'regular',
        letterSpacing: 0.3,
        paddingTop: 0
    },
    errorContainer: {
        marginVertical: 5
    },
    errorText: {
        color: 'red',
        fontSize: 13,
        fontFamily: 'regular',
        letterSpacing: 0.3
    }
})

export default Input;