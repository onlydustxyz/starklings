import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { RootState } from '../store'
import { connect } from 'get-starknet'
import { toast } from 'material-react-toastify'
import { AccountInterface, defaultProvider, ProviderInterface } from 'starknet'

export interface WalletState {
  account?: AccountInterface;
  status?: 'connected' | 'connecting' | 'disconnected';
  provider?: ProviderInterface;
  error: string;
}

const initialState: WalletState = {
  account: undefined,
  provider: defaultProvider,
  status: 'disconnected',
  error: ''
}

export const connectWallet = createAsyncThunk('wallet/connect', async () => {
  try {
    const starknet = await connect({ modalOptions: { theme: 'dark' } }) // Let the user pick a wallet
    if (!starknet) return
    await starknet.enable() // connect the wallet
    if (
      starknet.isConnected &&
      starknet.provider &&
      starknet.account.address
    ) {
      return { account: starknet.account, provider: starknet.provider, status: 'connected' }
    } else {
      return { status: 'disconnected' }
    }
  } catch (e) {
    toast.error('⚠️ Argent-X wallet extension missing!', {
      position: 'top-right',
      autoClose: 2000,
      hideProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true
    })
  }
})

const walletSlice = createSlice({
  name: 'wallet',
  initialState,
  reducers: {
    disconnect (state) {
      state.status = 'disconnected'
      state.error = ''
    }
  },
  extraReducers (builder) {
    builder
      .addCase(connectWallet.pending, (state) => {
        state.status = 'connecting'
        state.error = ''
      })
      .addCase(connectWallet.fulfilled, (state, action) => {
        state.status = action.payload?.status as 'disconnected' | 'connected' | 'connecting'
        state.account = action.payload?.account
        state.provider = action.payload?.provider
      })
      .addCase(connectWallet.rejected, (state, action) => {
        state.status = 'disconnected'
        state.error = action.error.message || 'An unknown error ocurred'
      })
  }
})

export const { disconnect } = walletSlice.actions

export default walletSlice.reducer

export const selectStarknetInfo = (state: RootState) => state.wallet
