import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import { JsxEmit } from 'typescript';
import ExercicesGroup from '../ExercicesGroup/ExercicesGroup';


interface ButtonConnectWalletProps {
  buttonClass: string,
  buttonText: string,
  link?: string
}

const ButtonConnectWallet: FC<ButtonConnectWalletProps> = ({buttonClass, buttonText}) => (
  <Link to='/logged'>
    <button className={buttonClass}>
      {buttonText? buttonText : 'Connect Wallet'}
    </button>
  </Link>
);
export default ButtonConnectWallet;
