import React, { FC } from 'react';
import { Link } from 'react-router-dom';
import ButtonConnectWallet from 'components/ConnectWallet/ButtonConnectWallet';
import logo from 'assets/onlydust-logo.png';

interface NavBarProps {}

const NavBar: FC<NavBarProps> = () => (
  <div className='app'>
    <nav className='navbar'>
      <div className='logo'>
        <Link to='/'>
          <img className='nav-logo' alt='Only Dust logo' src={logo}/>
          <h1 className='site-title'>Starklings</h1>
        </Link>
      </div>
      <div className='user-login-button'>
        <ButtonConnectWallet buttonClass='button-primary' buttonText='Connect Wallet'/>
      </div>
    </nav>
  </div>
);

export default NavBar;
