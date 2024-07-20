import { Text, View, StyleSheet } from "react-native";
import colors from "../constants/colors";


export default PageTitle = props => {
    return <View style={styles.container}>
        <Text style={styles.text}>{props.text}</Text>
    </View>
};

const styles = StyleSheet.create({
    container: {
        marginBottom: 10
    },
    text: {
        fontSize: 20,
        color: colors.textColor,
        fontFamily: "bold",
        letterSpacing: 0.3
    }
});