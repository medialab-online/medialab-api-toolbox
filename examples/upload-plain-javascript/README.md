# MediaLab Upload (plain JS)

This example uses plain javascript with modern `async` and `fetch` to communicate with the MediaLab upload API.

## Requirements

- Node package manager: `yarn` (`npm` should also work)
- MediaLab account (https://www.medialab.co)

## Install

- Run `yarn install` to install the required dependencies. 
- Copy `javascript/config.example.js` to `javascript/config.js` and add your MediaLab URL and private token. 
- Run `yarn start` to serve locally.

## ⚠️ Warning

Please keep in mind including a private MediaLab API token in public-facing javascript can leave your token vulnerable to exposure
