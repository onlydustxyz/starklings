import React, { FC, useState } from 'react';
import ExerciceContent from '../ExerciceContent/ExerciceContent';


interface ExerciceCardProps {
  name?: string,
  exerciceTitle?: string,
  status?: string; // success, wip, not-started
}

const ExerciceCard: FC<ExerciceCardProps> = ({exerciceTitle, status}) => {
  const [clickedCard, setClickedCard] = useState('');
  const cardHandler = (event: React.MouseEvent<HTMLElement>) => { 
    event.preventDefault();
  // set const card event current target
  const card = (event: React.MouseEvent<HTMLElement>) => { return event.currentTarget; };
  setClickedCard(card.name);
  };

  return(
    <div className='exercice-card' onClick={cardHandler}>
      <h3 className={`card-header ${status}`}>{exerciceTitle}</h3>
      {clickedCard !== '' ? <ExerciceContent listOfExercices={['Syntax00', 'Syntax01', 'Syntax02']} lastSuccessfulExercice={1}/> : ''}
    </div>
  );
}

export default ExerciceCard;
