import React from "react";
import { StyleSheet, View, Text, TouchableWithoutFeedback } from "react-native";
import colors from '../constants/colors';

const Bubble = props => {
    const { text, type } = props;

    const bubbleStyle = { ...styles.container };
    const textStyle = { ...styles.text };
    const wrapperStyle = { ...styles.wrapperStyle };

    let Container = View;

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
        case "myMessage":
            wrapperStyle.justifyContent = 'flex-end';
            bubbleStyle.backgroundColor = '#E7FED6';
            bubbleStyle.maxWidth = '90%';
            Container = TouchableWithoutFeedback;
            break;
        case "theirMessage":
            wrapperStyle.justifyContent = 'flex-start';
            bubbleStyle.maxWidth = '90%';
            Container = TouchableWithoutFeedback;
            break;

        default:
            break;
    }

    return (
        <View style={wrapperStyle}>
            <Container onLongPress={() => console.log("long pressed")} style={{ width: '100%' }}>
                <View style={bubbleStyle}>
                    <Text style={textStyle}>
                        {text}
                    </Text>
                </View>
            </Container>
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