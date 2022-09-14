import { useEffect, useState } from 'react';

export const useFetchData = <T>(url: string) => {
    const [status, setStatus] = useState<Number>(0)
    const [statusText, setStatusText] = useState<String>('')
    const [data, setData] = useState<T>()
    const [error, setError] = useState<Error | null>(null)
    const [loading, setLoading] = useState(false)

    useEffect(() => {
        (async () => {
                  setError(null)
                  setLoading(true)
              try {
                  const response = await fetch(url)
                  const json = await response.json()
                  setStatus(response.status)
                  setStatusText(response.statusText)
                  setData(json)
              } catch (error) {
                setError(error as Error)
              }
              setLoading(false)
              setError(null)
        })();
      }, [url]); 
      return { status, statusText, data, error, loading }
} 
