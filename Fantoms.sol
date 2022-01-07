// SPDX-License-Identifier: MIT

/*
    0xFantomsNFT Testnet Smart Contract v1
*/
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact r1xvu0@protonmail.com
contract FantomsNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    string private hiddenTokenURI = "https://storageapi.fleek.co/a1fa5514-37e2-41b9-a76c-1a7147172e46-bucket/HiddenFantom-Testnet-Metadata/";
    string private unveiledUri = "REDACTED/";

    string public contractMetadata = "https://storageapi.fleek.co/a1fa5514-37e2-41b9-a76c-1a7147172e46-bucket/Fantoms-tv1a_C_Metadata.json";
    bool public canMint = false;
    bool public canUnveil = false;

    mapping (uint => bool) public fantomUnveiled;

    uint256 maxSupply = 10001;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Fantoms", "FTMS") {
        _tokenIdCounter.increment();
    }
    
    function contractURI() public view returns (string memory) {
        // return "PLACEHOLDERURI";
        return contractMetadata;
    }
    
    function changeContractMetadata(string memory newMetadataURI) public onlyOwner {
        contractMetadata = newMetadataURI;
    }

    function safeMint(address to) public returns(string memory){
        require(canMint == true, "Minting is disabled at the moment!");
        require(_tokenIdCounter.current() < maxSupply, "Maximal supply reached!");
        uint256 tokenId = _tokenIdCounter.current();
        string memory theUri = concat(uint2str(tokenId), ".json");
        string memory realUri = concat(hiddenTokenURI, theUri);
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, realUri);
        return realUri;
    }

    function adminUnveil() public onlyOwner {
        for (uint i=1; i < _tokenIdCounter.current(); i++ ) {
            canUnveil = true;
            unveil(i);
        }
    }

    function unveil(uint tokenId) public returns(string memory){
        require(canUnveil == true, "Unveiling is disabled at the moment!");
        require(tokenId < _tokenIdCounter.current(), "Unveiling Fantoms that are not minted is not possible :(");
        string memory unveilUri = concat(uint2str(tokenId), ".json");
        string memory realUri = concat(unveiledUri, unveilUri);
        fantomUnveiled[tokenId] = true;
        _setTokenURI(tokenId, realUri);
        return tokenURI(tokenId);
    }

    function changeUnveilUri(string memory uri) public onlyOwner {
        unveiledUri = uri;
    }

    function viewUnveilUri() public view returns(string memory) {
        return unveiledUri;
    }

    function enablePauseMint() public onlyOwner {
        if (canMint == true) {
            canMint = false;
        } else {
            canMint = true;
        }
    }

    function enablePauseUnveil() public onlyOwner {
        if (canUnveil == true) {
            canUnveil = false;
        } else {
            canUnveil = true;
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getTokenIds(address _owner) public view returns (uint[] memory) {
        uint[] memory _tokensOfOwner = new uint[](ERC721.balanceOf(_owner));
        uint i;

        for (i=0;i<ERC721.balanceOf(_owner);i++){
            _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(_owner, i);
        }
        return (_tokensOfOwner);
    }

        function uint2str(uint256 _i) internal pure returns (string memory str) {
      if (_i == 0)
          {
            return "0";
          }
          
      uint256 j = _i;
      uint256 length;
      
      while (j != 0)
          {
            length++;
            j /= 10;
          }
          
      bytes memory bstr = new bytes(length);
      uint256 k = length;
      j = _i;
      
      while (j != 0)
          {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
          }
          
      str = string(bstr);
    }
    
    
    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
}
