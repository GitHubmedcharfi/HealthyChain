/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("solidity-coverage");
module.exports = {
  solidity: {
    version: "0.5.1", // Assurez-vous que c'est la version correcte pour votre contrat
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337, // Hardhat Network par défaut
    },
    ganache: {
      url: "http://127.0.0.1:8545", // URL de Ganache
      accounts: [
        // Vous devez entrer ici les clés privées des comptes Ganache
        // Vous pouvez obtenir les clés privées à partir de l'interface Ganache ou du terminal
        "0xd0e1365704ef2176b202fbcf17490bbc93ff9b47280e371e4be780d126779c58",
        "0x1714695b7e701a0744a21d6087a155192c95f6d5d9e3bb48415846b9085738eb"
      ],
      chainId: 1337, // ID de chaîne par défaut de Ganache
    }
  }
};

