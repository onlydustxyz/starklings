import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import ButtonConnectWallet from '../ButtonConnectWallet/ButtonConnectWallet';
import HeaderPage from '../HeaderPage/HeaderPage';
import logo from '../../assets/onlydust-logo.png';

interface NavBarProps {}

const NavBar: FC<NavBarProps> = () => (
  <div className='app'>
    <nav className='navbar'>
      <div className='logo'>
        <Link to='/'><a href='/'><img className='nav-logo' alt='Only Dust logo' src={logo}/></a></Link>
        <Link to='/' className='site-title'>Starklings</Link>
      </div>
      <div className='user-login-button'>
        <ButtonConnectWallet buttonClass='button-primary' buttonText='Connect Wallet'/>
      </div>
    </nav>
  </div>
);

export default NavBar;
