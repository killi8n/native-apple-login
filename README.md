# native-apple-login

## installation

```bash
$ yarn add native-apple-login
$ cd ios
$ pod install
```
## how to use

```js
import AppleLogin from "native-apple-login";

const login = async () => {
    const result = await AppleLogin.login();
}
```

> Apple Credential State Change Listener

```js
import AppleLogin, {
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
                if (state === "revoked") {
                    logout();
                }
            }
        );
        return () => {
            if (eventSubscription && eventSubscription.current) {
                eventSubscription.current.remove();
            }
        };
    }, []);

    const fetchList = async () => {
        NaitveAppleLogin.getCredentialState(await AsyncStorage.getUserAppleId());
        await getList();
    }
}
```