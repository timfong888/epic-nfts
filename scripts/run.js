const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to", nftContract.address);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0); // exit success
    } catch (error) {
        console.log(error);
        process.exit(1); // exit codes: https://nodejs.org/api/process.html#process_exit_codes
    }
};

runMain();

