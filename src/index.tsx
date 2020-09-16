import { NativeModules, NativeEventEmitter } from 'react-native';

export enum EventNames {
  CredentialStateChanged = 'credentialStateChanged',
}

interface LoginResult {
  authorizationCode: string;
  authorizedScopes: string[];
  fullName?: string;
  identityToken: string;
  email?: string;
  realUserStatus?: any;
  user: string;
}

export interface CredentialStateChangedResult {
  state: 'authorized' | 'revoked' | 'notfound' | 'transferred' | 'error';
  error?: string;
}

type NaitveAppleLoginType = {
  login: () => Promise<LoginResult>;
  getCredentialState: (userId: string) => void;
};

const { NaitveAppleLogin } = NativeModules;
export const Events = new NativeEventEmitter(NaitveAppleLogin);

export default NaitveAppleLogin as NaitveAppleLoginType;
