import React, { FC } from 'react';


interface ExerciceCardProps {
  exerciceTitle?: string,
  status?: string; // success, wip || not-started
}

const ExerciceCard: FC<ExerciceCardProps> = ({exerciceTitle, status}) => (
    <div className='exercice-card'>
      <h3 className={`card-header ${status}`}>{exerciceTitle}</h3>
    </div>
);

export default ExerciceCard;
