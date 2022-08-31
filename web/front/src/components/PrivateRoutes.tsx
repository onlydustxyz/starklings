
import React, { useEffect } from 'react';
import { Navigate, Outlet } from 'react-router-dom'
import { useStarknet } from '@starknet-react/core'


export const PrivateRoutes = () => {
    const { account } = useStarknet();
    const isConnected = (account !== undefined && account !== null && account.length > 0)

    useEffect(() => {
    }, [isConnected])

    return (
        isConnected ? <Outlet/> : <Navigate to='/'/>
    )
}
