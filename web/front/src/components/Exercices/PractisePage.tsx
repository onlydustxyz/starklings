import React, { FC, useState } from 'react'
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api'
import { useFetchData, TDataResponse } from '../../hooks/useFetchData'
import HeaderPage from '../views/HeaderPage'
import { useLocation } from 'react-router-dom'
import CodeEditor from './CodeEditor'
import FileDrop from './FileDrop'


interface PractisePageProps {
  exTitle: string;
  code?: string;
  instructions?: string;
  from?: string;
}

const PractisePage: FC<PractisePageProps> = ({exTitle, code, instructions}) => {
  // call 
  const { state } = useLocation();
  const [open, setOpen] = useState(false)
  const [upload, setUpload] = useState(false)

  // EVENTS
  const openCode = () => {
    setOpen(!open)
  }
  const uploadFile = () => {
    setUpload(!upload)
  }
  
  // pass the title of the exercice to the editor
  if(typeof(state) === 'string'){
    exTitle = state;
  }
  return (
    <div className='practise-page'>
      <HeaderPage headerTitle={exTitle} />
      <div className='section'>
      <div className='instructions'>
        <h2 className='section-header'>Instructions</h2>
        <p className='subtitle'>Paste your code in the editor or use the button to upload your Cairo file.</p>
      </div>
      <div className='practise-mode'>
       <button className={upload? 'button-upload button-clicked' : 'button-upload'}
                onClick={() => {
                  uploadFile()
                }}>{upload? 'Drag and drop your Cairo file here': 'Upload'}</button>
        <div className='file-upload-wrapper'>
          {upload ? <FileDrop /> : ''}
        </div>
        <div className='button-paste'
             onClick={() =>{
              openCode()
             }}>{open? 'Code': 'Paste your code'}</div>
             {open? <CodeEditor title={exTitle}/> : ''}
      </div>
    </div>
  </div>
  );
 }



export default PractisePage;
