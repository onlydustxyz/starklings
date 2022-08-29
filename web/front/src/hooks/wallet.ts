import { TypedData } from 'starknet/dist/utils/typedData'


const getChainId = (providerUrl: string) => {
  if (providerUrl.includes('alpha-mainnet.starknet.io')) {
    return 'SN_MAIN'
  } else if (providerUrl.includes('alpha4.starknet.io')) {
    return 'SN_GOERLI'
  }
  return 'localhost'
}

export const getTypedMessage = (wallet: string | undefined, providerBaseUrl: string): TypedData => ({
  domain: {
    name: 'Starklings',
    chainId: getChainId(providerBaseUrl),
    version: '1'
  },
  types: {
    Starklings: [
      { name: 'message', type: 'felt' },
      { name: 'wallet', type: 'felt' },
      { name: 'version', type: 'felt' }
    ],
    Message: [{ name: 'message', type: 'felt' }]
  },
  primaryType: 'Starklings',
  message: {
    message: 'Ok',
    wallet: wallet,
    version: 1
  }
})
