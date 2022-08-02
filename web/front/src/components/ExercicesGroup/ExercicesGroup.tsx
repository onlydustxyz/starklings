import React, { FC } from 'react';
import { HashRouter as Router, Route, Link, Routes } from 'react-router-dom';
import BasicPage from '../BasicPage/BasicPage';
import ExerciceCard from '../ExerciceCard/ExerciceCard';
import HeaderPage from '../HeaderPage/HeaderPage';


interface ExercicesGroupProps {}

const ExercicesGroup: FC<ExercicesGroupProps> = () => (
  <div className='page'>
    <HeaderPage headerTitle='Hi'/>
    <div className='section achievements'>
      <h2 className='section-header'>Achievements</h2>
      <div className='cards-wrapper'>
        <ExerciceCard exerciceTitle='Strings' status='success'/>
        <ExerciceCard exerciceTitle='Syntax' status='wip'/>
        <ExerciceCard exerciceTitle='Storage' status='not-started'/>
        <ExerciceCard exerciceTitle='Builtins' status='not-started'/>
        <ExerciceCard exerciceTitle='Implicit Args' status='not-started'/>
        <ExerciceCard exerciceTitle='Recursion' status='not-started'/>
      </div>
    </div>
  </div>
);

export default ExercicesGroup;
