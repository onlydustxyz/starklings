import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import BasicPage from '../views/BasicPage';
import ExerciceCard from './ExerciceCard';
import HeaderPage from '../views/HeaderPage';
import { useFetchData, TDataResponse } from '../../hooks/useFetchData';


interface ExercicesGroupProps {}

//const ExercicesGroup: FC<ExercicesGroupProps> = () => (
function ExercicesGroup() {
  const getExercicesData: TDataResponse = useFetchData('https://api.github.com/repos/onlydustxyz/starklings/contents/exercises')
  let cardList: any = []
  getExercicesData.data.forEach((d: { name: any; }) => {
   cardList?.push(<ExerciceCard exerciceTitle={d.name} status='wip'/>)
  })
  return (
      <div className='page'>
        <HeaderPage headerTitle='Hi'/>
          <div className='section achievements'>
            <h2 className='section-header'>Achievements</h2>
            <div className='cards-wrapper'>
              {cardList}
           </div>
         </div>
      </div>
  );
}

export default ExercicesGroup;