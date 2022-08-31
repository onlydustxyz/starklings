import React, { FC, useEffect, useState } from 'react';
import { useConnectors, useStarknet, useSignTypedData } from '@starknet-react/core'
import { getTypedMessage } from '../../hooks/wallet'


interface Props {
    open: boolean;
    close: () => void;
    buttonClass: string;
}

const ConnectWalletModal: FC<Props> = ({ open, close, buttonClass }: Props) => {
    const { connect, disconnect, connectors } = useConnectors()
    const { account } = useStarknet();
    const isWalletConnected = (account !== undefined && account !== null && account.length > 0)
    const [signature, setSignature] = useState(null)

    const { data, error, signTypedData, loading } = useSignTypedData(getTypedMessage(account, 'alpha4.starknet.io'))

    const handleConnect = ((connector: any) => {
      if (isWalletConnected) {
        disconnect()
        close()
      } else {
        connect(connector)
      }
    })

    const signStarklings = () => {
        //Implements Connexion logic : Check API if user exists, else, create account with signature
        signTypedData()
    }

    useEffect(() => {
        if (data && ~loading) {
            close()
        }
    }, [loading, data, close])

    return (
        <div className="wallet-modal" style={{ display: open ? 'block' : 'none' }}>
            <div className="wallet-modal-content">
                {isWalletConnected ?
                    <>
                    <button onClick={signStarklings} className={buttonClass}>
                        {'Sign in Starklings'}
                    </button>
                    <button onClick={() => handleConnect(null)} className={buttonClass}>
                        {'Disconnect'}
                    </button>
                    </>
                : connectors.map((connector) =>
                    connector.available() &&
                    (
                        <button key={connector.id()} onClick={() => handleConnect(connector)} className={buttonClass}>
                            {'Connect with '+connector.name()}
                        </button>
                    )
                )}
            </div>
        </div>
    );
  }
  
  export default ConnectWalletModal;