# IOTA MAM SupplyChainManager PoC
## by topocare

This repository contains the source code for the FlutterApp described at [this Medium article](https://medium.com/topocare-x-iota/implementing-an-iota-based-supply-chain-documentation-cd8103bcec46).

It uses IOTA MAM for supply chain documentation. The data of the supply chain is stored in the IOTA tangle. Metadata (MAM roots) are exchanged between participants using QR codes.
While the scope of the app itself is focused on the transfer of ownership, it also contains functions to generate test-data.

## App Architecture
The app is separated into the following parts
- `appState` the global state of the app
- `screens` and `widgets` the UI

- `MamHandler` publishing / fetching MAM-messages using the [MAM Client JS Library](https://github.com/iotaledger/mam.client.js)
- `messages` MAM-messages used by the app
- `trytes` encoding / decoding for the tryte-representation used by MAM and IOTA in general

- `controllers` algorithms for the "sell" and "buy" sides of a transfer of ownership

## Development / Devices
The App was developed using Android Studio (with Flutter plugin).
It was tested on Android devices using USB debugging for installation.