// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HenryNFT is ERC721Enumerable, Ownable{
    using Strings for uint256;

    bool public _isSaleActive = false;
    bool public _revealed = false;
    uint public constant MAX_SUPPLY = 10;
    uint public maxSupply = 20;
    uint public mintPrice = 0.03 ether;
    uint public maxBalance = 1;
    uint public maxMint = 1;
    
    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory baseInitURI, string memory initNotRevealedURI) ERC721("HenrySyh", "HS"){
        setBaseURI(baseInitURI);
        setNotRevealedURI(initNotRevealedURI);
    }

    function mintHS(uint tokenQuantity) public payable{
        // need to check
        require(_isSaleActive, "Sale must be active by owner");
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Sale would exceed max supply");
        require(balanceOf(msg.sender) + tokenQuantity <= maxBalance,"Sale would exceed max balance");
        require(tokenQuantity * mintPrice <= msg.value,"Not enough ether sent");
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");
        
        _mintHS(tokenQuantity);
    }

    function _mintHS(uint tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint mintIndex = totalSupply();
            if(mintIndex < maxSupply){
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function tokenURI(uint tokenId) override public view returns(string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    function burn(uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

}