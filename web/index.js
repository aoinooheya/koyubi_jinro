// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyC2NMnW6VHDEBjdr1y7-F-MBLu2iv8kd9E",
  authDomain: "koyubijinro.firebaseapp.com",
  projectId: "koyubijinro",
  storageBucket: "koyubijinro.appspot.com",
  messagingSenderId: "420630967339",
  appId: "1:420630967339:web:b3f404144679c775b9e66e",
  measurementId: "G-LWJ1LB946C"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);