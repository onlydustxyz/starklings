import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import ExercicesGroup from '../Exercices/ExercicesGroup';
import HeaderPage from './HeaderPage';

interface BasicPageProps {
  basicPageTitle: string,
  basicPageSubtitle?: string,
  basicPageText?: string;
}

const BasicPage: FC<BasicPageProps> = ({basicPageTitle, basicPageSubtitle}) => (
  <div className='page'>
    <HeaderPage headerTitle={basicPageTitle} subtitle={basicPageSubtitle}/>
    <Routes>
        <Route path='terms-of-service' element={<BasicPage basicPageTitle='Terms of Service'/>}/>
        <Route path='privacy-policy' element={<BasicPage basicPageTitle='Privacy Policy'/>}/>
    </Routes>
  </div>
);

export default BasicPage;
