import React, { useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { faUpload } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'


function FileDrop() {
  const onDrop = useCallback((acceptedFiles: File[]) => {
    console.log(acceptedFiles)
    onDrop(acceptedFiles)
    //props.onDrop(acceptedFiles)
  } , [])
  const { getRootProps, getInputProps } = useDropzone({ onDrop })
  return (
    <div className='file-upload-zone' {...getRootProps()}>
        <FontAwesomeIcon className='upload-icon' icon={faUpload} />
      <input {...getInputProps()} />
    </div>
  )
}

export default FileDrop;