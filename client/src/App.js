import Button from '../node_modules/react-bootstrap/Button.js';
import Form from '../node_modules/react-bootstrap/Form.js';
import FormGroup from '../node_modules/react-bootstrap/FormGroup';
import FormControl from '../node_modules/react-bootstrap/FormControl';
import BootstrapTable from '../node_modules/react-bootstrap-table/lib/BootstrapTable';
import TableHeaderColumn from '../node_modules/react-bootstrap-table/lib/TableHeaderColumn';
import 'react-bootstrap-table/dist/react-bootstrap-table-all.min.css';

import React, { Component } from "react";
import DMCT from "./contracts/DMCT.json";
import getWeb3 from "./utils/getWeb3";
import ipfs from "./utils/ipfs";

import "./App.css";

class App extends Component {

  constructor(props) {
    super(props)
    this.state = { 
      DMCTInstance: "", 
      certificateTitle: "",
      certificateData: "",
      certificateURL: null,
      certificateMedia: "",
      returnValues: [],
      transactions:[],
      transactionHash:"",
      buffer: "",
      certificateFrame: "",
      certificateFrameURL:"",
      web3: null, 
      accounts: null
    };
    this.handleIssueDMCT = this.handleIssueDMCT.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.uploadFile = this.uploadFile.bind(this);
    this.getFile = this.getFile.bind(this);
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = DMCT.networks[networkId];
      const instance = new web3.eth.Contract(
        DMCT.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ DMCTInstance: instance, web3: web3, account: accounts[0]})
      this.addEventListener(this)
      } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.log(error);
    }
  };

  addEventListener(component) {
    this.state.DMCTInstance.events.ReturnCreateCertificate({fromBlock: 0, toBlock: 'latest'})
      .on('data', function(event){
        console.log(event);
        var newTransactionsArray = component.state.transactions.slice()
        var newReturnValuesArray = component.state.returnValues.slice()
        newTransactionsArray.push(event)
        newReturnValuesArray.push(event.returnValues)
        console.log(newTransactionsArray, newReturnValuesArray);
        component.setState({transactions: newTransactionsArray})
        component.setState({returnValues: newReturnValuesArray})
      })
      .on('error', console.error);
  }

  captureFile =(event) => {
    event.stopPropagation()
    event.preventDefault()
    const file = event.target.files[0]
    let reader = new window.FileReader()
    reader.readAsArrayBuffer(file)
    reader.onloadend = () => this.convertToBuffer(reader)
  }
 
  convertToBuffer = async(reader) => {
    const buffer = await Buffer.from(reader.result);
    this.setState({buffer});
  };

  uploadFile = async(event) => {
    event.preventDefault()
    console.log(this.state.buffer);
    await ipfs.add(this.state.buffer, (err, ipfshash) => {
      this.setState({certificateURL: ipfshash[0].hash});
    })
  };

  getFile = (event) => {
    event.preventDefault();
    console.log(this.state.certificateMedia);
    const url = "ipfs/" + this.state.certificateMedia;
    ipfs.cat(this.state.certificateMedia, (err, mediaFrame) => {
      this.setState({certificateFrame: mediaFrame})
      this.setState({certificateFrameURL: "https://ipfs.io/" + url})
    })
  };

  handleChange(event) {
    switch(event.target.name) {
      case "certificateTitle":
        this.setState({certificateTitle: event.target.value})
        break;
      case "certificateData":
        this.setState({certificateData: event.target.value})
        break;
      case "certificateURL":
        this.setState({certificateURL: event.target.value})
        break;
      case "certificateMedia":
        this.setState({certificateMedia: event.target.value})
        break;
      default:
        break;
    }
  }

  async handleIssueDMCT(event) {
    if(typeof this.state.DMCTInstance !== "undefined") {
      event.preventDefault();
      await this.state.DMCTInstance.methods.createCertificate(
          this.state.certificateTitle, 
          this.state.certificateData, 
          this.state.certificateURL).send({from: this.state.account}
          ,(error, transactionHash) => {
            console.log("transaction hash is ", transactionHash);
            this.setState({transactionHash});
          });
    }
  }

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <header className="App-header">
          <h1> Portfolio </h1>
        </header>
          <Form className="container-1" onSubmit={this.uploadFile}>
            <FormGroup controlId = "formUploadFile" />
            <FormControl
                bsPrefix="form" 
                type = "text"
                name = "certificateTitle"
                value={this.state.certificateTitle}
                placeholder="Enter title"
                onChange ={this.handleChange} 
              />
              <FormControl
                bsPrefix="form" 
                type="text"
                name="certificateData"
                value={this.state.certificateData}
                placeholder="Enter Media Data"
                onChange ={this.handleChange}
              />
            <input type="file" onChange={this.captureFile}/> 
            <Button type="submit"> Upload File </Button>
          </Form>
          <Form className="container" onSubmit={this.handleIssueDMCT}>
            <FormGroup controlId = "formCreateCertificate" />
              <Button type ="submit" > Issue Certificate </Button>   
          </Form>
          <BootstrapTable className="container-1" data={this.state.returnValues} striped bordered hover>
            <TableHeaderColumn isKey dataField='CID'>ID</TableHeaderColumn>
            <TableHeaderColumn dataField='title'>Title</TableHeaderColumn>
            <TableHeaderColumn dataField='data'>Data</TableHeaderColumn>
            <TableHeaderColumn dataField='url'> Hash </TableHeaderColumn>
          </BootstrapTable>
          <BootstrapTable className="container-1" data={this.state.transactions} striped bordered hover>
            <TableHeaderColumn isKey dataField='transactionHash'> Transaction # </TableHeaderColumn>
          </BootstrapTable>
          <Form className="container" onSubmit={this.getFile}>
            <FormControl
              bsPrefix="form" 
              type="text"
              name="certificateMedia"
              value={this.state.certificateMedia}
              placeholder="Enter URL to retrieve Media"
              onChange ={this.handleChange}
            />
            <Button type="submit"> Get Media </Button>
            <br></br>
            <br></br>

            <iframe title="frame" src={this.state.certificateFrameURL} name="certificateFrame" height="100%" width="100%" ></iframe>
          </Form>
      </div>
    );
  }
}

export default App;
