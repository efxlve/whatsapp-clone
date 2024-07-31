import * as Device from 'expo-device';
import * as Notifications from 'expo-notifications';
import { getFirebaseApp } from '../firebaseHelper';
import { createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import { child, get, getDatabase, ref, set, update } from 'firebase/database';
import { authenticate, logout } from '../../store/authSlice';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { getUserData } from './userActions';

let timer;

export const signUp = (firstName, lastName, email, password) => {
    return async dispatch => {
        const app = getFirebaseApp();
        const auth = getAuth(app);

        try {
            const result = await createUserWithEmailAndPassword(auth, email, password);
            const { uid, stsTokenManager } = result.user;
            const { accessToken, expirationTime } = stsTokenManager;

            const expiryDate = new Date(expirationTime);
            const timeNow = new Date();
            const millisecondsUntilExpiry = expiryDate - timeNow;

            const userData = await createUser(firstName, lastName, email, uid);

            dispatch(authenticate({ token: accessToken, userData }));
            saveDataToStorage(accessToken, uid, expiryDate);
            await storePushToken(userData);

            timer = setTimeout(() => {
                dispatch(userLogout(userData));
            }, millisecondsUntilExpiry)
        } catch (error) {
            console.log(error);
            const errorCode = error.code;

            let message = "Something went wrong.";

            if (errorCode === "auth/email-already-in-use") {
                message = "This email is already in use";
            }

            throw new Error(message);
        }
    }
};

export const signIn = (email, password) => {
    return async dispatch => {
        const app = getFirebaseApp();
        const auth = getAuth(app);

        try {
            const result = await signInWithEmailAndPassword(auth, email, password);
            const { uid, stsTokenManager } = result.user;
            const { accessToken, expirationTime } = stsTokenManager;

            const expiryDate = new Date(expirationTime);
            const timeNow = new Date();
            const millisecondsUntilExpiry = expiryDate - timeNow;

            const userData = await getUserData(uid);

            dispatch(authenticate({ token: accessToken, userData }));
            saveDataToStorage(accessToken, uid, expiryDate);
            await storePushToken(userData);

            timer = setTimeout(() => {
                dispatch(userLogout(userData));
            }, millisecondsUntilExpiry)
        } catch (error) {
            const errorCode = error.code;

            let message = "Something went wrong.";

            if (errorCode === "auth/wrong-password" || errorCode === "auth/user-not-found" || errorCode === "auth/invalid-credential") {
                message = "The username or password was incorrect";
            }

            throw new Error(message);
        }
    }
};

export const userLogout = (userData) => {
    return async dispatch => {
        try {
            await removePushToken(userData);
        } catch (error) {
            console.log(error);
        }

        AsyncStorage.clear();
        clearTimeout(timer);
        dispatch(logout());
    }
};

export const updateSignedInUserData = async (userId, newData) => {
    if (newData.firstName && newData.lastName) {
        const firstLast = `${newData.firstName} ${newData.lastName}`.toLowerCase();
        newData.firstLast = firstLast;
    }

    const dbRef = ref(getDatabase());
    const childRef = child(dbRef, `users/${userId}`);
    await update(childRef, newData);
}

const createUser = async (firstName, lastName, email, userId) => {
    const firstLast = `${firstName} ${lastName}`.toLowerCase();
    const userData = {
        firstName,
        lastName,
        firstLast,
        email,
        userId,
        signUpDate: new Date().toISOString()
    };

    const dbRef = ref(getDatabase());
    const childRef = child(dbRef, `users/${userId}`);
    await set(childRef, userData);
    return userData;
}

const saveDataToStorage = (token, userId, expiryDate) => {
    AsyncStorage.setItem("userData", JSON.stringify({
        token,
        userId,
        expiryDate: expiryDate.toISOString()
    }));
}

const storePushToken = async (userData) => {
    if (!Device.isDevice) {
        return;
    }

    token = (await Notifications.getExpoPushTokenAsync({
        projectId: '2e676ef8-32b8-4baa-91db-45b2ab1c1df8'
    })).data; 

    const tokenData = { ...userData.pushTokens } || {};
    const tokenArray = Object.values(tokenData);

    if (tokenArray.includes(token)) {
        return;
    }

    tokenArray.push(token);

    for (let i = 0; i < tokenArray.length; i++) {
        const tok = tokenArray[i];
        tokenData[i] = tok;
    }

    const app = getFirebaseApp();
    const dbRef = ref(getDatabase(app));
    const userRef = child(dbRef, `users/${userData.userId}/pushTokens`);

    await set(userRef, tokenData);
}

const removePushToken = async (userData) => {
    if (!Device.isDevice) {
        return;
    }

    token = (await Notifications.getExpoPushTokenAsync({
        projectId: '2e676ef8-32b8-4baa-91db-45b2ab1c1df8'
    })).data; 

    const tokenData = await getUserPushTokens(userData.userId);

    for(const key in tokenData) {
        if (tokenData[key] === token) {
            delete tokenData[key];
            break;
        }
    }

    const app = getFirebaseApp();
    const dbRef = ref(getDatabase(app));
    const userRef = child(dbRef, `users/${userData.userId}/pushTokens`);

    await set(userRef, tokenData);
}

export const getUserPushTokens = async (userId) => {
    try {
        const app = getFirebaseApp();
        const dbRef = ref(getDatabase(app));
        const userRef = child(dbRef, `users/${userId}/pushTokens`);

        const snapshot = await get(userRef);

        if (!snapshot || !snapshot.exists()) {
            return {};
        }

        return snapshot.val() || {};

    } catch (error) {
        console.log(error);
    }
}