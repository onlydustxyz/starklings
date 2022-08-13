import React, { FC, useState } from 'react';
import ExerciceContent from './ExerciceContent';
import { useFetchData, TDataResponse } from '../../hooks/useFetchData';

interface ExerciceCardProps {
  exName?: string,
  exerciceTitle?: string,
  status?: string; // success, wip, not-started
}

const ExerciceCard: FC<ExerciceCardProps> = ({exerciceTitle, status}) => {
  // EVENTS VARS 
  const [hide, setHide] = useState(false)


  // CONTENTS VARS
  let listEx: any[] = []
  const getListOfExercices: TDataResponse = useFetchData('https://api.github.com/repos/onlydustxyz/starklings/contents/exercises/' + exerciceTitle)
  if(getListOfExercices.data) {
    getListOfExercices.data.forEach((d: { name: any; }) => {
      // if data is .cairo add to list without extension
      let data = d.name.split('.')
      if(data[1] === 'cairo') {
        // replace underscores with space
        data[0] = data[0].replace(/_/g, ' ')
        // check if strg contains number
        let hasNum : boolean = data[0].match(/\d/) ? true : false
        if(hasNum) {
          let formattedData = data[0].slice(-2)
          formattedData = data[0].slice(0, -2) + ' ' + formattedData
          listEx.push(formattedData)
        }
        else {
          listEx.push(data[0])
        }
      }
    })
  }

  // EVENTS
  const toggleHide = () => {
    setHide(!hide)
  }
  const cardOut = () => {
    setHide(hide)
  }
  return(
    <div className={hide? 'exercice-card show-content':'exercice-card'} 
         onClick={() => {setHide(hide); toggleHide()}}
         onMouseOut={() => cardOut()}>
      <h3 className={`card-header ${status}`}>{exerciceTitle}</h3>
        <div className='content'>
          {hide? <ExerciceContent listOfExercices={listEx} lastSuccessfulExercice={1}/> : ''}
        </div>
    </div>
  )
}

export default ExerciceCard;
