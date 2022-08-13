import React, { useCallback } from 'react'
import { useDropzone } from 'react-dropzone'


function FileDrop() {
  const onDrop = useCallback((acceptedFiles: File[]) => {
    console.log(acceptedFiles)
    onDrop(acceptedFiles)
    //props.onDrop(acceptedFiles)
  } , [])
  const { getRootProps, getInputProps } = useDropzone({ onDrop })
  return (
    <div className='file-upload-zone' {...getRootProps()}>
      <input {...getInputProps()} />
    </div>
  )
}

export default FileDrop;