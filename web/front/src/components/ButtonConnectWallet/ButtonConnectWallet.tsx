import React, { FC } from 'react';
import { JsxEmit } from 'typescript';


interface ButtonConnectWalletProps {
  buttonClass: string,
  buttonText: string,
  link?: string
}

const ButtonConnectWallet: FC<ButtonConnectWalletProps> = ({buttonClass, buttonText}) => (
  <button className={buttonClass}>
    {buttonText? buttonText : 'Connect Wallet'}
  </button>
);
export default ButtonConnectWallet;
