import React, { FC, useState } from 'react';
import ExerciceContent from './ExerciceContent';
import { useFetchData, TDataResponse } from '../../hooks/useFetchData';


interface ExerciceCardProps {
  name?: string,
  exerciceTitle?: string,
  status?: string; // success, wip, not-started
}

const ExerciceCard: FC<ExerciceCardProps> = ({exerciceTitle, status}) => {
  console.log(exerciceTitle)
  let listEx: any[] = []
  const [clickedCard, setClickedCard] = useState('')
  const getListOfExercices: TDataResponse = useFetchData('https://api.github.com/repos/onlydustxyz/starklings/contents/exercises/' + exerciceTitle)
  console.log(getListOfExercices)
  if(getListOfExercices.data) {
    getListOfExercices.data.forEach((d: { name: any; }) => {
      // if data is .cairo add to list without extension
      let data = d.name.split('.')
      if(data[1] === 'cairo') {
        listEx.push(data[0])
      }
    }
    )
  }
  const cardHandler = (event: React.MouseEvent<HTMLElement>) => { 
    event.preventDefault();
  // set const card event current target
  const card = (event: React.MouseEvent<HTMLElement>) => { return event.currentTarget; };
  setClickedCard(card.name);
  };

  return(
    <div className='exercice-card' onClick={cardHandler}>
      <h3 className={`card-header ${status}`}>{exerciceTitle}</h3>
      {clickedCard !== '' ? <ExerciceContent listOfExercices={listEx} lastSuccessfulExercice={1}/> : ''}
    </div>
  );
}

export default ExerciceCard;
