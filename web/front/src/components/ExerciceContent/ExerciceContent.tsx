import React, { FC } from 'react';


interface ExerciceContentProps {
  listOfExercices: Array<string>,
  lastSuccessfulExercice: number;
}

const ExerciceContent: FC<ExerciceContentProps> = ({listOfExercices, lastSuccessfulExercice}) => (
  <ul className='exercices'>
    {listOfExercices.map((exercice, index)=> index < lastSuccessfulExercice ? <li className='exercice success'>{exercice}</li>: <li className='exercice not-started'>{exercice}</li>)}
  </ul>
);

export default ExerciceContent;
