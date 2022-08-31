import React, { FC, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStarknet } from '@starknet-react/core'
import ConnectWalletModal from './ConnectWalletModal'


interface ButtonConnectWalletProps {
  buttonClass: string,
  buttonText: string,
  link?: string
}

const ButtonConnectWallet: FC<ButtonConnectWalletProps> = ({buttonClass, buttonText}) => {
  const { account } = useStarknet();
  const isConnected = (account !== undefined && account !== null && account.length > 0)
  const navigate = useNavigate();

  const [showModal, toggleModal] = useState(false)

  useEffect(() => {
    if (isConnected) {
      return navigate("/logged");
    }
  }, [isConnected, navigate])

  return (
    <>
      <button onClick={() => toggleModal(true)} className={buttonClass}>
            {isConnected ?  `${account.substring(0, 7)}...` : buttonText}
      </button>
      <ConnectWalletModal open={showModal} close={() => toggleModal(false)} buttonClass={buttonClass}/>
    </>
  );
}

export default ButtonConnectWallet;
