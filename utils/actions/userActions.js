import { child, getDatabase, ref, get, query, orderByChild, startAt, endAt } from "firebase/database";
import { getFirebaseApp } from "../firebaseHelper";

export const getUserData = async (userId) => {
    try {
        const app = getFirebaseApp();
        const dbRef = ref(getDatabase(app));
        const userRef = child(dbRef, `users/${userId}`);

        const snapshot = await get(userRef);
        return snapshot.val();
    } catch (error) {
        console.log(error);
    }
};

export const searchUsers = async (queryText) => {
    const searchTerm = queryText.toLowerCase();

    try {
        const app = getFirebaseApp();
        const dbRef = ref(getDatabase(app));
        const userRef = child(dbRef, 'users');

        const queryRef = query(userRef, orderByChild('firstLast'), startAt(searchTerm), endAt(searchTerm + "\uf8ff"));

        const snapshot = await get(queryRef);

        if (snapshot.exists()) {
            return snapshot.val();
        }

        return {};
    } catch (error) {
        console.log(error);
        throw error;
    }
};