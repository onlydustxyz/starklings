import React, { FC } from 'react'
import Editor from '@monaco-editor/react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircleInfo } from '@fortawesome/free-solid-svg-icons'

interface CodeEditorProps {
    title?: string;
    code?: string;
}

const CodeEditor: FC<CodeEditorProps> = ({title}) => {
    console.log(title)
    return (
        <div id='codeEditor' className='code-editor-wrapper'>
        <Editor
          className-='code-editor'
          height='80vh'
          defaultLanguage='python'
          defaultValue='#place your code here'
          theme='vs-dark'
          width='100%'
       />
       <div className='validation'>
       <a className='icon-docs' href='https://www.cairo-lang.org/docs/how_cairo_works/index.html'>
          <FontAwesomeIcon icon={faCircleInfo}/>
        </a>
        <button className='button-run-code'>Check</button>
       </div>
     </div>
    )
}

export default CodeEditor;