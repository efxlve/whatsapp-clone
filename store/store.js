import { configureStore } from "@reduxjs/toolkit";
import authSlice from "./authSlice";
import userSlice from "./userSlice";
import chatSlice from "./chatSlice";

export const store = configureStore({
    reducer: {
        auth: authSlice,
        users: userSlice,
        chats: chatSlice
    }
});