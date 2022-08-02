import React from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom'
import NavBar from './components/NavBar/NavBar';
import BasicPage from './components/BasicPage/BasicPage';
import Home from './components/Home/Home';
import './App.sass';
import HeaderPage from './components/HeaderPage/HeaderPage';
import ButtonConnectWallet from './components/ButtonConnectWallet/ButtonConnectWallet';
import Footer from './components/Footer/Footer';
import ExercicesGroup from './components/ExercicesGroup/ExercicesGroup';

export default function App() {
  return (
    <Router>
      <div className='App'>
        <div className='wrapper'>
          <NavBar/>
          <Routes>
            <Route path='/' element={<Home/>}/>
            <Route path='logged' element={<ExercicesGroup/>}/>
            <Route path='terms-of-service' element={<BasicPage basicPageTitle='Terms of Service'/>}/>
            <Route path='privacy-policy' element={<BasicPage basicPageTitle='Privacy Policy'/>}/>
          </Routes>
          <Footer />
        </div>
      </div>
    </Router>
  );
}
