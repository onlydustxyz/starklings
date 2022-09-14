import React from 'react';
import ReactDOM from 'react-dom/client';
import 'App.sass';
import App from 'App';
import { StarknetProvider, getInstalledInjectedConnectors } from '@starknet-react/core'

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

const connectors = getInstalledInjectedConnectors()

root.render(
  <React.StrictMode>
    <StarknetProvider connectors={connectors}>
      <App />
    </StarknetProvider>
  </React.StrictMode>
);
