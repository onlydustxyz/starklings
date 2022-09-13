import { FC } from 'react';
import { useNavigate } from 'react-router-dom';

interface ExerciceContentProps {
  listOfExercices: Array<string>,
  lastSuccessfulExercice: number,
}
function ExerciceContent(props: ExerciceContentProps) {
  const navigate = useNavigate()
  const ExerciceContentReturn: FC<ExerciceContentProps> = ({listOfExercices, lastSuccessfulExercice}) => (
  <ul className='exercices'>
    {listOfExercices.map(
      (exercice, index)=> index < lastSuccessfulExercice ? 
        <li key ={index} className='exercice success'>{exercice}</li>: 
        <li key ={index} className='exercice not-started'
            onClick= {() => {navigate('/exercice',
              { state: exercice })}}>{exercice}</li>
    )}
  </ul>
  )
  return ExerciceContentReturn(props)
  }

export default ExerciceContent;
