import React, { FC } from 'react';
import ButtonConnectWallet from '../ConnectWallet/ButtonConnectWallet';
import HeaderPage from './HeaderPage';
import cairoImg from '../../assets/code-cairo.png';
import resourcesImg from '../../assets/resources-img.png';


interface HomeProps {}

const Home: FC<HomeProps> = () => (
  <div className='page'>
        <HeaderPage headerTitle='Get started with Starknet' subtitle='Use Starklings, an interactive tutorial to get you up and running with Starknet'/>
        <section className='section section-cairo'>
          <div className='explanations'>
            <h2 className='section-header'>Learn Cairo</h2>
            <p className='section-description'>Cairo is a new computer language which opens endless opportunities. And even if it’s amazing to use, first days are very tough (mathematician language, you know what I mean...). How do long-strings work? Hardhat or Nile? How to manage references?</p>
          </div>
          <div className='illustration'>
            <img className='section-image' alt='Cairo code' src={cairoImg}/>
          </div>
        </section>
        <div className='separator-button'>
          <ButtonConnectWallet buttonClass='button-secondary' buttonText='Start here'/>
          </div>
        <section className='section section-resources'>
          <div className='illustration'>
            <img className='section-image' alt='Magic Cards' src={resourcesImg}/>
          </div>
          <div className='explanations'>
            <h2 className='section-header'>Get resources and support</h2>
            <p className='section-description'>We will help you understand this ecosystem, with incredible resources. The ecosystem is growing fast, very fast. But it can be confusing sometimes, what exactly can I build there? A DEX? A new library? Can I work on a Foundry equivalent? (Unit tests are life). We’ll give you access to the core needs of the ecosystem. You will make a difference without days of research.</p>
            <div className='button-boxed'>
              <ButtonConnectWallet buttonClass='button-primary' buttonText='Connect and start'/>
            </div>
          </div>
        </section>
      </div>
);

export default Home;
