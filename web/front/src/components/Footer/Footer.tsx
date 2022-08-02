import React, { FC } from 'react';
import footerLogo from '../../assets/od-footer-logo.svg';


interface FooterProps {}

const Footer: FC<FooterProps> = () => (
  <footer className='footer'>
    <div className='footer-content'>
      <img className='footer-logo' alt='Only Dust logo' src={footerLogo}/>
      <ul className='social-network-links'>
        <li className='footer-icon discord'></li>
        <li className='footer-icon twitter'></li>
        <li className='footer-icon github'></li>
      </ul>
    </div>
    <ul className='footer-links'>
      <li className='link'><a href=''>Terms of Service</a></li>
      <li className='link'><a href=''>Privacy Policy</a></li>
    </ul>
  </footer>
);

export default Footer;
