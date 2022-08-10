import React, { FC } from 'react'
import Editor from '@monaco-editor/react'
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api'
import { useFetchData, TDataResponse } from '../../hooks/useFetchData'
import { registerCairoLanguageSupport } from 'monaco-language-cairo'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircleInfo } from '@fortawesome/free-solid-svg-icons'
import HeaderPage from '../views/HeaderPage'


interface PractisePageProps {}

// The editor colors can be customized through CSS or through JS

monaco.editor.defineTheme('starklings', {
	base: 'vs-dark',
	inherit: true,
	rules: [{
    token: '',
    background: '#0E0D2E'}],
	colors: {
		'editorCursor.foreground': '#AE00FF',
		'editorLineNumber.foreground': '#EBDDFF',
		'editor.selectionBackground': '#0009BC',
    'editor.descriptionForeground': '#666'
	}
});

//registerCairoLanguageSupport(monaco)
monaco.editor.setTheme('starklings');


function PractisePage() {
  // call 
  return (
    <div className='practise-page'>
      <HeaderPage headerTitle='Practise' />
      <div className='section'>
      <div className='instructions'>
        <h2 className='section-header'>Instructions</h2>
        <p className='subtitle'>Make the text pass.</p>
      </div>
      <div id='codeEditor' className='code-editor-wrapper'>
        <Editor
          className-='code-editor'
          height='80vh'
          defaultLanguage='python'
          defaultValue='lang starknet \n
          @storage_var func test () -> (test : felt):\n
          end'
          theme='vs-dark'
          width='100%'
       />
       <div className='validation'>
       <a className='icon-docs' href='https://www.cairo-lang.org/docs/how_cairo_works/index.html'>
          <FontAwesomeIcon icon={faCircleInfo}/>
        </a>
        <button className='button-run-code'>Run</button>
       </div>
     </div>
    </div>
    </div>
  );
 }



export default PractisePage;
