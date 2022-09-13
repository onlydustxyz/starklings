import { useEffect, useState } from 'react';

export const useFetchData = <T>(url: string) => {
    const [status, setStatus] = useState<Number>(0)
    const [statusText, setStatusText] = useState<String>('')
    const [data, setData] = useState<T>()
    const [error, setError] = useState<any>()
    const [loading, setLoading] = useState(false)

    useEffect(() => {
        (async () => {
                  setLoading(true)
              try {
                  const response = await fetch(url)
                  const json = await response.json()
                  setStatus(response.status)
                  setStatusText(response.statusText)
                  setData(json)
              } catch (error) {
                  setError(error)
              }
              setLoading(false)
        })();
      
        return () => {
        };
      }, []); 
      return { status, statusText, data, error, loading }
} 
