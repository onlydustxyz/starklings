import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import { JsxEmit } from 'typescript';
import ExercicesGroup from '../Exercices/ExercicesGroup';


interface ButtonConnectWalletProps {
  buttonClass: string,
  buttonText: string,
  link?: string
}

const ButtonConnectWallet: FC<ButtonConnectWalletProps> = ({buttonClass, buttonText}) => (
    <button className={buttonClass}>
      <Link to='/logged'>
      {buttonText? buttonText : 'Connect Wallet'}
      </Link>
    </button>
  
);
export default ButtonConnectWallet;
