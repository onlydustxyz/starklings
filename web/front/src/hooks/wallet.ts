import { AccountInterface } from 'starknet'
import { getMessageHash } from 'starknet/dist/utils/typedData'

const getChainId = (providerUrl: string) => {
  if (providerUrl.includes('alpha-mainnet.starknet.io')) {
    return 'SN_MAIN'
  } else if (providerUrl.includes('alpha4.starknet.io')) {
    return 'SN_GOERLI'
  }
  return 'localhost'
}

export const getTypedMessage = (message: string, providerBaseUrl: string) => ({
  domain: {
    name: 'StarkBoard',
    chainId: getChainId(providerBaseUrl),
    version: '0.0.1'
  },
  types: {
    StarkNetDomain: [
      { name: 'name', type: 'felt' },
      { name: 'chainId', type: 'felt' },
      { name: 'version', type: 'felt' }
    ],
    Message: [{ name: 'message', type: 'felt' }]
  },
  primaryType: 'Message',
  message: {
    message
  }
})

export async function signMessage (account: AccountInterface, message: string, providerBaseUrl: string) {
  const typedMessage = getTypedMessage(message, providerBaseUrl)
  const hash = getMessageHash(typedMessage, account.address)
  const signature = await account.signMessage(typedMessage)
  return { hash, signature }
}
