import React, { FC } from 'react';
import BasicPage from './BasicPage';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import footerLogo from '../../assets/od-footer-logo.svg';
  import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
  import { faTwitter, faDiscord, faGithub } from '@fortawesome/free-brands-svg-icons';


interface FooterProps {}

const Footer: FC<FooterProps> = () => (
  <footer className='footer'>
    <div className='footer-content'>
      <img className='footer-logo' alt='Only Dust logo' src={footerLogo}/>
      <ul className='social-network-links'>
        <li className='footer-icon discord'><a href='https://discord.gg/ttxj7QRbtb'><FontAwesomeIcon icon={faDiscord} /></a></li>
        <li className='footer-icon twitter'><a href='https://twitter.com/OnlyDust_xyz'><FontAwesomeIcon icon={faTwitter} /></a></li>
        <li className='footer-icon github'><a href='https://github.com/onlydustxyz/starklings'><FontAwesomeIcon icon={faGithub} /></a></li>
      </ul>
    </div>
    <ul className='footer-links'>
      <li className='link'><Link to='terms-of-service'>Terms of Service</Link></li>
      <li className='link'><Link to='privacy-policy'>Privacy Policy</Link></li>
    </ul>

  </footer>
);

export default Footer;
