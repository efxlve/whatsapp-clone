import { initializeApp } from "firebase/app";

export const getFirebaseApp = () => {
    const firebaseConfig = {
        apiKey: "AIzaSyDoueCkiOOwOxwGBxHg8EbuRHKyP9g4YwQ",
        authDomain: "whatsapp-ad3b9.firebaseapp.com",
        projectId: "whatsapp-ad3b9",
        storageBucket: "whatsapp-ad3b9.appspot.com",
        messagingSenderId: "840475282753",
        appId: "1:840475282753:web:8538bbbc22095d22df25c0",
        measurementId: "G-F2PJNH1GSE"
    };
    
    return initializeApp(firebaseConfig);
};