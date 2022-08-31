import React from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom'
import NavBar from './components/views/NavBar';
import BasicPage from './components/views/BasicPage';
import Home from './components/views/Home';
import './App.sass';
import HeaderPage from './components/views/HeaderPage';
import ButtonConnectWallet from './components/ConnectWallet/ButtonConnectWallet';
import Footer from './components/views/Footer';
import ExercicesGroup from './components/Exercices/ExercicesGroup';
import PractisePage from './components/Exercices/PractisePage';

// TODO : Make sure there is unity into routing, 
// configuring routing using useNavigate is necessary 
// before delivery
export default function App() {
  let exTitle = 'Practise'
  return (
    <Router>
      <div className='App'>
        <div className='wrapper'>
          <NavBar/>
          <Routes>
            <Route path='/' element={<Home/>}/>
            <Route path='logged' element={<ExercicesGroup/>}/>
            <Route path='exercice/' element={<PractisePage exTitle={exTitle}/>}/>
            <Route path='terms-of-service' element={<BasicPage basicPageTitle='Terms of Service'/>}/>
            <Route path='privacy-policy' element={<BasicPage basicPageTitle='Privacy Policy'/>}/>
          </Routes>
          <Footer />
        </div>
      </div>
    </Router>
  );
}