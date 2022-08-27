
import { Navigate, Outlet } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { WalletState } from '../store/reducers/wallet'
import { RootState } from '../store/store'


export const PrivateRoutes = () => {
    const { status } = useSelector<RootState, WalletState>(state => state.wallet)
    const isConnected = status === 'connected'

    return (
        isConnected ? <Outlet/> : <Navigate to='/'/>
    )
}
