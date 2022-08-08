import { useEffect, useState } from 'react';

export type TDataResponse = {
    status: Number
    statusText: String
    data: any
    error: any
    loading: boolean
}

export const useFetchData = (url: string): TDataResponse => {
    const [status, setStatus] = useState<Number>(0)
    const [statusText, setStatusText] = useState<String>('')
    const [data, setData] = useState<any>()
    const [error, setError] = useState<any>()
    const [loading, setLoading] = useState(false)

    const getData = async () => {
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
    };

    useEffect(() => {
        getData()
    }, [])

    return { status, statusText, data, error, loading }
/* export class useFetchData {
    static getData(arg0: string) {
      throw new Error('Method not implemented.');
    }
    
    public async getData(url: string): Promise<any> {
        const response = await fetch(url);
        return await response.json();
    }
*/
} 