import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import * as serviceWorker from './serviceWorker';

import { Drizzle, generateStore } from "drizzle";

import UserRegistry from "./contracts/UserRegistry";
import LocalMarkert from "./contracts/LocalMarket";
import ContractRegistry from "./contracts/ContractRegistry";
import BillSystem from "./contracts/BillSystem";
import LosLedger from "./contracts/LosLedger";

const options = { contracts: [LosLedger, UserRegistry, LocalMarkert, ContractRegistry, BillSystem] };

const drizzleStore = generateStore(options);
const drizzle = new Drizzle(options, drizzleStore);


ReactDOM.render(<App drizzle={drizzle}/>, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();
