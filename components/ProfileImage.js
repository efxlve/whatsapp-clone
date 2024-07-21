import React, { useState } from  'react';
import { Image, StyleSheet, TouchableOpacity, View } from 'react-native';
import { FontAwesome } from '@expo/vector-icons';

import userImage from '../assets/images/userImage.jpeg';
import colors from '../constants/colors';
import { launchImagePicker, uploadImageAsync } from '../utils/imagePickerHelper';
import { updateSignedInUserData } from '../utils/actions/authActions';

const ProfileImage = props => {
    const source = props.uri ?  { uri: props.uri } : userImage;

    const [image, setImage] = useState(source);

    const userId = props.userId;

    const pickImage = async () => {
        try {
            const tempUri = await launchImagePicker();

            if (!tempUri) return;

            const uploadUrl = await uploadImageAsync(tempUri);

            if (!uploadUrl) {
                throw new Error("Could not upload image");
            }

            await updateSignedInUserData(userId, { profilePicture: uploadUrl });

            setImage({ uri: uploadUrl });
        }
        catch (error) {
            console.log(error);
        }
    }

    return (
        <TouchableOpacity onPress={pickImage}>
            <Image
                style={{ ...styles.image, ...{ width: props.size, height: props.size } }}
                source={image}/>

            <View style={styles.editIconContainer}>
                <FontAwesome name="pencil" size={15} color="black" />
            </View>
        </TouchableOpacity>
    )
};

const styles = StyleSheet.create({
    image: {
        borderRadius: 50,
        borderColor: colors.grey,
        borderWidth: 1
    },
    editIconContainer: {
        position: 'absolute',
        bottom: 0,
        right: 0,
        backgroundColor: colors.lightGrey,
        borderRadius: 20,
        padding: 8
    }
})

export default ProfileImage;