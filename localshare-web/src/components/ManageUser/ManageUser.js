import React from "react";
import { Button, Form, Input, Checkbox, Message } from 'semantic-ui-react';

class ManageUser extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            hasUser: true,
            losBalancePointer:"",
            firstName:"",
            lastName:"",
            country:"",
            tx: -1,
            nameTaken:false,

            offer:{
                dbRefId:'',
                price: 0
            }
        }
    }

    async componentDidMount(){
        const { drizzle, drizzleState } = this.props;
        const userRegistryInstance = drizzle.contracts.UserRegistry;
        const losLedgerInstance = drizzle.contracts.LosLedger;

        const mainAccount = drizzleState && drizzleState.accounts && !!Object.keys(drizzleState.accounts).length ? drizzleState.accounts[0] : "";

        const hasUser = await userRegistryInstance.methods.hasUser(mainAccount).call();
        this.setState({ hasUser });

        const losBalancePointer = losLedgerInstance.methods.balanceOf.cacheCall(mainAccount);
        this.setState({ losBalancePointer });
    }

    handleInputChange = (event) => {
        this.setState({
            [event.target.name]: event.target.value,
            organizationNameTaken: false
        })
    }

    handleOfferChange = (event) => {
        const offer = this.state.offer;
        offer[event.target.name] = event.target.value;

        this.setState({
            offer
        });
    }


    selectCountry = (value) => {
        this.setState({ country: value });
    }

    togglePrivacyTerms = () => {
        this.setState((prevState) => ({
            privacy: !prevState.privacy
        }));
    }

    toggleUseTerms = () => {
        this.setState((prevState) => ({
            use: !prevState.use
        }));
    }

    createUser = async () => {
        const { drizzle, drizzleState } = this.props;
        const { firstName, lastName, country } = this.state;
        const mainAccount = drizzleState && drizzleState.accounts && !!Object.keys(drizzleState.accounts).length ? drizzleState.accounts[0] : "";

        if (mainAccount !== "") {
            const contractInstance = drizzle.contracts.UserRegistry;
            const rawName = drizzle.web3.utils.utf8ToHex(`${firstName} ${lastName}`);
            const addressHaveOrg = await contractInstance.methods.hasUser(mainAccount).call();

            if (!addressHaveOrg) {
                const nameTaken = await contractInstance.methods.usernameTaken(rawName).call();
                if(!nameTaken){
                    const dbRefId = '1231313131313131';
                    const dbRefIdRaw = drizzle.web3.utils.utf8ToHex(dbRefId);
                    const estimatedGas = await contractInstance.methods.createUser(rawName, dbRefIdRaw).estimateGas({ from: mainAccount });
                    const tx = contractInstance.methods.createUser.cacheSend(rawName, dbRefIdRaw, { gas: estimatedGas, from: mainAccount });
                    this.setState({
                        tx
                    });

                } else {
                    this.setState({
                        nameTaken: true
                    })
                }
            }
        }
    }

    createOffer = async () => {
        const { drizzle, drizzleState } = this.props;
        const { offer } = this.state;
        const mainAccount = drizzleState && drizzleState.accounts && !!Object.keys(drizzleState.accounts).length ? drizzleState.accounts[0] : "";
        if (mainAccount !== "") {
            const contractInstance = drizzle.contracts.UserRegistry;
            const rawRefID = drizzle.web3.utils.utf8ToHex(offer.dbRefId);

            const estimatedGas = await contractInstance.methods.createOffer(offer.price, rawRefID).estimateGas({ from: mainAccount });
            console.log(estimatedGas);
            const tx = contractInstance.methods.createOffer.cacheSend(offer.price, rawRefID, { gas: estimatedGas, from: mainAccount });
        }
    }


    render(){
        const { hasUser, firstName, lastName, country, price, dbRefId  } = this.state;
        return (<div>
             <h1>{this.state.hasUser.toString()}</h1>
             <h1>{this.state.losBalancePointer.toString()}</h1>
                {hasUser ?
                    <div> Create offers
                        <Form>
                            <Form.Field>
                                <label>Price</label>
                                <Input placeholder='' value={price} name="price" onChange={this.handleOfferChange}/>
                                <label>DB Id</label>
                                <Input placeholder='' value={dbRefId} name="dbRefId" onChange={this.handleOfferChange}/>
                            </Form.Field>
                            <Button type='submit' id="createOrgBtn" onClick={this.createOffer}>Create Offer</Button>
                        </Form>
                    </div>
                    :
                    <Form>
                        <Form.Field>
                            <label>First Name</label>
                            <Input placeholder='' value={firstName} name="firstName" onChange={this.handleInputChange}/>
                            <label>Last Name</label>
                            <Input placeholder='' value={lastName} name="lastName" onChange={this.handleInputChange}/>
                            <label>Country</label>
                            <Input placeholder='' value={country} name="country" onChange={this.handleInputChange}/>
                        </Form.Field>
                        <Button type='submit' id="createOrgBtn" onClick={this.createUser}>Create a new user</Button>
                    </Form>
               }
            </div>
        );
    }
}

export default ManageUser;