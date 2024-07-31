import 'react-native-gesture-handler';
import { Image, LogBox, Platform, StyleSheet, Text, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect, useCallback, useState } from 'react';
import * as Font from 'expo-font';
import AppNavigator from './navigation/AppNavigator';
import { Provider } from 'react-redux';
import { store } from './store/store';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { MenuProvider } from 'react-native-popup-menu';
import logo from './assets/images/Logo.png';

LogBox.ignoreLogs(['AsyncStorage has been extracted']);
// AsyncStorage.clear();

SplashScreen.preventAutoHideAsync();

export default function App() {

  const [appIsLoaded, setAppIsLoaded] = useState(false);

  useEffect(() => {
    const prepare = async () => {
      try {
        await Font.loadAsync({
          "black": require("./assets/fonts//Roboto-Black.ttf"),
          "blackItalic": require("./assets/fonts/Roboto-BlackItalic.ttf"),
          "bold": require("./assets/fonts/Roboto-Bold.ttf"),
          "boldItalic": require("./assets/fonts/Roboto-BoldItalic.ttf"),
          "italic": require("./assets/fonts/Roboto-Italic.ttf"),
          "light": require("./assets/fonts/Roboto-Light.ttf"),
          "lightItalic": require("./assets/fonts/Roboto-LightItalic.ttf"),
          "medium": require("./assets/fonts/Roboto-Medium.ttf"),
          "mediumItalic": require("./assets/fonts/Roboto-MediumItalic.ttf"),
          "regular": require("./assets/fonts/Roboto-Regular.ttf"),
          "thin": require("./assets/fonts/Roboto-Thin.ttf"),
          "thinItalic": require("./assets/fonts/Roboto-ThinItalic.ttf"),
        });
      }
      catch (error) {
        console.log(error);
      }
      finally {
        setAppIsLoaded(true);
      }
    };

    prepare();
  }, []);

  const onLayout = useCallback(async () => {
    if (appIsLoaded) {
      await SplashScreen.hideAsync();
    }
  }, [appIsLoaded]);

  if (!appIsLoaded) {
    return null;
  }

  if (Platform.OS === 'web') {
    return (
      <View style={styles.webContainer}>
        <Image source={logo} style={styles.logo} />
        <Text style={styles.webMessage}>This application is not supported on the web.</Text>
      </View>
    );
  }

  return (
    <Provider store={store}>
      <GestureHandlerRootView style={{ flex: 1 }}>
        <SafeAreaProvider
          style={styles.container}
          onLayout={onLayout}>
          <MenuProvider>
            <AppNavigator />
          </MenuProvider>
        </SafeAreaProvider>
      </GestureHandlerRootView>
    </Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff'
  },
  label: {
    fontFamily: "regular"
  },
  webContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white', 
    padding: 20
  },
  webMessage: {
    fontSize: 18,
    color: '#333', 
    textAlign: 'center',
    marginTop: 20
  },
  logo: {
    width: 150,
    height: 150,
    resizeMode: 'contain'
  }
});
