import React, { FC } from 'react';
import '../../App.sass';



interface HeaderPageProps {}

const HeaderPage: FC<HeaderPageProps> = () => (
  <header className='header'>
    <h1>Get started with Starknet</h1>
    <p className='subitle'>Use Starklings, an interactive tutorial to get you up and running with Starknet</p>
  </header>
);

export default HeaderPage;
