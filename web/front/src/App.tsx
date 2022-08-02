import React from 'react';
import NavBar from './components/NavBar/NavBar';
import Home from './components/Home/Home';
import './App.sass';
import HeaderPage from './components/HeaderPage/HeaderPage';
import ButtonConnectWallet from './components/ButtonConnectWallet/ButtonConnectWallet';
import Footer from './components/Footer/Footer';

export default function App() {
  return (
    <div className='App'>
      <div className='wrapper'>
        <NavBar/>
        <Home />
        <Footer />
      </div>

    </div>
  );
}
