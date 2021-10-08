// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";


contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // VRF 
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='25%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["ROCK", "PAPER", "SCISSORS"];
    string[] secondWords = ["ROCK", "PAPER", "SCISSORS"];
    string[] thirdWords = ["ROCK", "PAPER", "SCISSORS"];

    
    constructor() ERC721 ("Quadrant", 'QuadrantNFT') {
        
       // source:  https://docs.chain.link/docs/vrf-contracts/
                
       // VRFConsumerBase(
    //        0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
    //        0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
    //    );
        
        {
            keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
            fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
        }
        
        console.log("constructor line from constructor function");
        
    }
    
    
    // I create a function to randomly pick a word from each array.
      function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
          
        // I seed the random generator. More on this in the lesson. 
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
      }
    
      function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
      }
    
      function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
      }
    
    function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function makeAnEpicNFT() public {
        // get the current token ID and it starts with int208
        uint256 newItemId = _tokenIds.current();
        
        
        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        
        string memory combinedWord = string(abi.encodePacked(first, second, third));
        
        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, '<tspan x="200" dy="1.2em">', first, "</tspan>", '<tspan x="200"  dy="1.2em">',second, '</tspan><tspan x="200" dy="1.2em">', third, "</tspan></text></svg>"));
    
         // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
    
        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");
        
        // actually mint to the sender 
        _safeMint(msg.sender, newItemId);
        
        // set the NFT data 
        _setTokenURI(newItemId, finalTokenUri );
        
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        
        // increment the Counter
        _tokenIds.increment();
        

    } 
    
}

