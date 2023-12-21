// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract FunctionsConsumerExample is FunctionsClient, ConfirmedOwner { 
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    struct Article {
        bytes url;
        uint256 publishedDate;
    }

    Article[] private articles;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(bytes32 indexed requestId, bytes response, bytes err);

    event ArticleAdded(bytes url, uint256 publishedDate);
    // CUSTOM PARAMS - START
    // Sepolia Router address;
      // Additional Routers can be found at 
    //   https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0; 

    //Functions Subscription ID
    uint64 subscriptionId = 9999;

    //Gas limit for callback tx do not change
    uint32 gasLimit = 300000;

    //DoN ID for Sepolia, from supported networks in the docs
    // Additional DoN IDs can be found at 
    //   https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000; 

    // Source Javascript to run
    string source = "";

    // CUSTOM PARAMS - END

    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    function sendRequest() external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donId
        );

        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }

        articles.push(Article(response, block.timestamp));
        emit ArticleAdded(response, block.timestamp);

        s_lastResponse = response;

        s_lastError = err;
        emit Response(requestId, s_lastResponse, s_lastError);
    }

    function getAllArticles() public view returns (string[] memory) {
        string[] memory allArticles = new string[](articles.length);
        for (uint i = 0; i < articles.length; i++) {
            allArticles[i] = string(articles[i].url);
        }
        return allArticles;
    }
}