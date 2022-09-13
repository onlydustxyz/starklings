import { FC } from 'react';
import { HashRouter as Router, Route, Routes } from 'react-router-dom'; // router used for "path"
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
