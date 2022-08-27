import React, { FC, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux'
import { connectWallet, WalletState } from '../../store/reducers/wallet'
import { RootState, useAppDispatch } from '../../store/store'


interface ButtonConnectWalletProps {
  buttonClass: string,
  buttonText: string,
  link?: string
}

const ButtonConnectWallet: FC<ButtonConnectWalletProps> = ({buttonClass, buttonText}) => {
  const { status, account } = useSelector<RootState, WalletState>(state => state.wallet)
  const isConnected = status === 'connected'
  const dispatch = useAppDispatch()
  const navigate = useNavigate();

  useEffect(() => {
    if (isConnected) {
      return navigate("/logged");
    }
  }, [isConnected, navigate])

  return (
    <button onClick={() => dispatch(connectWallet())} className={buttonClass}>
      {isConnected ?  `${account?.address.substring(0, 7)}...` : buttonText}
    </button>
  );
}
export default ButtonConnectWallet;
