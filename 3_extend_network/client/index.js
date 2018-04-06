'use strict'; // self-defence

const express = require("express");
const http = require('http');
const bodyParser = require('body-parser');
const path = require('path');
const hlf = require('./hlf');

// Options -------------------------------------------------------------------------

const clientOptions = {
  wallet_path: '/Users/amb/Feina/amb/hlf/b9lab-hlf/3_extend_network/client/certs',
  user_id: 'orgadmin',
  channel_id: 'testchannel',
  chaincode_id: 'catalog',
  peer_url: 'grpc://localhost:17051',
  orderer_url: 'grpc://localhost:7050'
};

// Server -------------------------------------------------------------------------

const app = express();

app.engine('html', require('ejs').renderFile);

const server = http.createServer(app).listen(4000, function() {});
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(__dirname));
app.set('views', __dirname);

// Handlers  -------------------------------------------------------------------------

app.get('/', function(req, res) {
  res.render('UI.html');
});

app.post('/register', async function(req, res, next) {
  try {
    await hlf.sendTransaction(clientOptions,"register",req.body.args)
    res.send("Chaincode invoked")
  } catch (err) {
      res.status(500);
      res.send(err.toString());
  };
});

app.post('/transfer', async function(req, res, next) {
  try {
    await hlf.sendTransaction(clientOptions,"transfer",req.body.args)
    res.send("Chaincode invoked")
  } catch (err) {
      res.status(500);
      res.send(err.toString());
  };
});

app.get('/list', async function(req, res, next) {
  try {
    res.send(await hlf.query(clientOptions,"list",[]))
  } catch (err) {
      res.status(500);
      res.send(err.toString());
  };
});

app.get('/query', async function(req, res, next) {
  try {
    res.send(await hlf.query(clientOptions,"query",[req.query.args]))
  } catch (err) {
      res.status(500);
      res.send(err.toString());
  };
});

app.get('/whoami', async function(req, res, next) {
  try {
    res.send(await hlf.query(clientOptions,"whoami",[]))
  } catch (err) {
      res.status(500);
      res.send(err.toString());
  };
});

