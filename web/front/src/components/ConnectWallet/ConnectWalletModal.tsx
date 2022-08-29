import React, { FC, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConnectors, useStarknet } from '@starknet-react/core'


interface Props {
    open: boolean;
    close: () => void;
    buttonClass: string;
}

const ConnectWalletModal: FC<Props> = ({ open, close, buttonClass }: Props) => {
    const { connect, disconnect, connectors } = useConnectors()
    const { account } = useStarknet();
    const isConnected = (account !== undefined && account !== null && account.length > 0)
  
    const handleConnect = ((connector: any) => {
      if (isConnected) {
        disconnect()
        close()
      } else {
        connect(connector)
        close()
      }
    })
  
    return (
        <div className="wallet-modal" style={{ display: open ? 'block' : 'none' }}>
            <div className="wallet-modal-content">
                {isConnected ?
                    <button onClick={() => handleConnect(null)} className={buttonClass}>
                        {'Disconnect'}
                    </button>
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