import React from "react";
import { Button, Form, Input, Checkbox, Message } from 'semantic-ui-react';


class LocalMarket  extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            offers: []
        }
    }

    async componentDidMount(){
        const { drizzle, drizzleState } = this.props;
        const localMarketInstance = drizzle.contracts.LocalMarket;

        const mainAccount = drizzleState && drizzleState.accounts && !!Object.keys(drizzleState.accounts).length ? drizzleState.accounts[0] : "";

        const offerIndexes = await localMarketInstance.methods.getOfferIndexesFromAddress().call();

        offerIndexes.forEach(async (index) => {
            const offer = await localMarketInstance.methods.getOfferFromIndex(index).call();
            const { offers } = this.state;
            offers.push(offer);
            this.setState({offers});
        });
    }

    render(){
        const {offers} = this.state;
        return (
            <div>
                <h4>Offers</h4>
                    {
                        offers.map(offer => (
                            <div >
                                <h4>{JSON.stringify(offer)}</h4>
                            </div>
                        ))
                    }
            </div>
        )
    }
}

export default LocalMarket;