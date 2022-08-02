import React, { FC } from 'react';
import ButtonConnectWallet from '../ButtonConnectWallet/ButtonConnectWallet';
import HeaderPage from '../HeaderPage/HeaderPage';
import logo from '../../assets/onlydust-logo.png';

interface NavBarProps {}

const NavBar: FC<NavBarProps> = () => (
  <div className='app'>
    <nav className='navbar'>
      <div className='logo'>
        <img className='nav-logo' alt='Only Dust logo' src={logo}/>
        <p className='site-title'>Starklings</p>
      </div>
      <div className='user-login-button'>
        <ButtonConnectWallet buttonClass='button-primary' buttonText='Connect Wallet'/>
      </div>
    </nav>
  </div>
);

export default NavBar;
