import * as React from 'react';
import { StyleSheet, View, Button, EmitterSubscription } from 'react-native';
import NaitveAppleLogin, {
  Events,
  EventNames,
  CredentialStateChangedResult,
} from 'native-apple-login';

export default function App() {
  const eventSubscription = React.useRef<EmitterSubscription | null>(null);
  React.useEffect(() => {
    eventSubscription.current = Events.addListener(
      EventNames.CredentialStateChanged,
      ({ state, error }: CredentialStateChangedResult) => {
        console.log('cdh-debug', state, error);
      }
    );
    return () => {
      if (eventSubscription && eventSubscription.current) {
        eventSubscription.current.remove();
      }
    };
  }, []);
  return (
    <View style={styles.container}>
      <Button
        title="APPLE LOGIN"
        onPress={async () => {
          try {
            const result = await NaitveAppleLogin.login();
            console.log(result);
            NaitveAppleLogin.getCredentialState('');
          } catch (e) {
            console.error(e);
          }
        }}
      />
      <Button
        title="GET CREDENTIAL STATE"
        onPress={async () => {
          try {
            NaitveAppleLogin.getCredentialState('');
          } catch (e) {
            console.error(e);
          }
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
