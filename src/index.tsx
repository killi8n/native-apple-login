import { NativeModules } from 'react-native';

type NativeAppleLoginType = {
  multiply(a: number, b: number): Promise<number>;
};

const { NativeAppleLogin } = NativeModules;

export default NativeAppleLogin as NativeAppleLoginType;
