import React, { FC } from 'react';
import '../../App.sass';



interface HeaderPageProps {
  headerTitle: string,
  subtitle?: string;
}

const HeaderPage: FC<HeaderPageProps> = ({headerTitle, subtitle}) => (
  <header className='header'>
    <h1>{headerTitle}</h1>
    <p className='subtitle'>{subtitle}</p>
  </header>
);

export default HeaderPage;
