import React from "react";
import { StyleSheet, View, Text } from "react-native";
import colors from '../constants/colors';

const Bubble = props => {
    const { text, type } = props;

    const bubbleStyle = { ...styles.container };
    const textStyle = { ...styles.text };

    switch (type) {
        case "system":
            textStyle.color = '#65644A';
            bubbleStyle.backgroundColor = colors.beige;
            bubbleStyle.alignItems = 'center';
            bubbleStyle.marginTop = 10;
            break;
        case "error":
            bubbleStyle.backgroundColor = colors.red;
            textStyle.color = 'white';
            bubbleStyle.marginTop = 10;
            break;
    
        default:
            break;
    }

    return (
        <View style={styles.wrapperStyle}>
            <View style={bubbleStyle}>
                <Text style={textStyle}>
                    {text}
                </Text>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    wrapperStyle: {
        flexDirection: 'row',
        justifyContent: 'center'
    },
    container: {
        backgroundColor: 'white',
        borderRadius: 6,
        padding: 5,
        marginBottom: 10,
        borderColor: '#E2DACC',
        borderWidth: 1
    },
    text: {
        fontFamily: 'regular',
        letterSpacing: 0.3
    }
});

export default Bubble;