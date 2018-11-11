import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

import ManageUser from './components/ManageUser/ManageUser';
import LocalMarket from "./components/LocalMarket/LocalMarket";

class App extends Component {
    state = {loading: true, drizzleState: null};

    componentDidMount() {
        const {drizzle} = this.props;

        this.unsubscrible = drizzle.store.subscribe(() => {
            const drizzleState = drizzle.store.getState();

            if (drizzleState.drizzleStatus.initialized) {
                this.setState({loading: false, drizzleState});
            }
        });
    }

    componentWillUnmount() {
        this.unsubscrible();
    }

    render() {
        if (this.state.loading) return "Loading Drizzle...";
        return (<div className="App">
                <ManageUser
                  drizzle={this.props.drizzle}
                  drizzleState={this.state.drizzleState}
                />
                <LocalMarket
                    drizzle={this.props.drizzle}
                    drizzleState={this.state.drizzleState}
                />
            </div>
        );
    }
}

export default App;
