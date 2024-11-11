import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'jotai';
import { VisibilityProvider } from './providers/VisibilityProvider';
import App from './components/App';
import './index.scss';
import TV from './components/TV';
ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Provider>
      <TV></TV>
      <VisibilityProvider>
        <App />
      </VisibilityProvider>
    </Provider>
  </React.StrictMode>,
);
