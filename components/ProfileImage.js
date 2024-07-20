import React from "react";
import { Image, StyleSheet, View } from 'react-native';
import colors from '../constants/colors';
import userImage from "../assets/images/userImage.jpeg";

const ProfileImage = props => {
    return (
        <View>
            <Image
                style={{ ...styles.image, ...{ width: props.size, height: props.size } }}
                source={userImage}
            />
        </View>
    )
};

const styles = StyleSheet.create({
    image: {
        borderRadius: 50,
        borderColor: colors.grey,
        borderWidth: 1
    }
});

export default ProfileImage;