import { configureStore } from '@reduxjs/toolkit'
import walletReducer from './reducers/wallet'
import { useDispatch } from 'react-redux'

const loading: Record<string, string> = {
  GET_STORE_DATA: 'REQUEST'
}

export interface AppState {
  loading: typeof loading;
  wallet: typeof walletReducer;
}

const store = configureStore({
  reducer: {
    wallet: walletReducer
  },
  middleware: getDefaultMiddleware => getDefaultMiddleware({ serializableCheck: false })
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch;
export const useAppDispatch = () => useDispatch<AppDispatch>()
export const wrapper = store
