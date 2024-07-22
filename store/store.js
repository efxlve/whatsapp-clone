import { configureStore } from "@reduxjs/toolkit";
import authSlice from "./authSlice";
import userSlice from "./userSlice";

export const store = configureStore({
    reducer: {
        auth: authSlice,
        users: userSlice
    }
});