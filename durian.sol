pragma solidity ^0.5.7;

import "./ERC20Latte.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

/**
 *
 * Contribution campaigns including the ability to approve the transfer of funds per request
 *
 */

contract CrowdsaleDurian {

    using SafeMath for uint256;
    
    // Request definition
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }
    
    Request[] public requests; // requests instance
    address public manager; // the owner
    uint256 minimumContribution; // the... minimum contribution

    /*
        a factor to calculate minimum number of approvers by 100/factor
        the factor values are 2 and 10, factors that makes sense:
            2: meaning that the number or approvers required will be 50%
            3: 33.3%
            4: 25%
            5: 20%
            10: 10%
    */
    uint8 approversFactor;
    
    mapping(address => bool) public approvers;
    uint256 public approversCount;

    // function to add validation of the manager to run any function
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Constructor function to create a Campaign
    constructor(address creator, uint256 minimum, uint8 factor) public {
        // validate factor number betweeb 2 and 10
        require(factor >= 2);
        require(factor <= 10);
        manager = creator;
        approversFactor = factor;
        minimumContribution = minimum;
    }
    
    // allows a contributions
    function contribute() public payable {
        // validate minimun contribution
        require(msg.value >= minimumContribution);

        // increment the number of approvers
        if (!approvers[msg.sender]) {
            approversCount++;
        }

        approvers[msg.sender] = true; // this maps this address with true

    }

    // create a request...
    function createRequest(string memory description, uint256 value, address payable recipient) public restricted {

        // create the struct, specifying memory as a holder
        Request memory newRequest = Request({
           description: description,
           value: value,
           recipient: recipient,
           complete: false,
           approvalCount: 0
        });

        requests.push(newRequest);

    }

    // contributors has the right to approve request
    function approveRequest(uint256 index) public {
        
        // this is to store in a local variable "request" the request[index] and avoid using it all the time
        Request storage request = requests[index];
        
        // if will require that the sender address is in the mapping of approvers
        require(approvers[msg.sender]);
        
        // it will require the contributor not to vote twice for the same request
        require(!request.approvals[msg.sender]);
        
        // add the voter to the approvals map
        request.approvals[msg.sender] = true;
        
        // increment the number of YES votes for the request
        request.approvalCount++;
        
    }

    // check if the sender already approved the request index
    function approved(uint256 index) public view returns (bool) {

        // if the msg.sender is an approver and also the msg.sender already approved the request “index” returns true
        if (approvers[msg.sender] && requests[index].approvals[msg.sender]) {
            return true;
        } else {
            return false;
        }

    }
    
    // send the money to the vendor if there are enough votes
    // only the creator is allowed to run this function
    function finalizeRequest(uint256 index) public restricted {
        
        // this is to store in a local variable "request" the request[index] and avoid using it all the time
        Request storage request = requests[index];

        // transfer the money if it has more than X% of approvals
        require(request.approvalCount >= approversCount.div(approversFactor));
        
        // we will require that the request in process is not completed yet
        require(!request.complete);
        
        // mark the request as completed
        request.complete = true;
        
        // transfer the money requested (value) from the contract to the vendor that created the request
        request.recipient.transfer(request.value);
        
    }

    // helper function to show basic info of a contract in the interface
    function getSummary() public view returns (
      uint256, uint256, uint256, uint256, address
      ) {
        return (
          minimumContribution,
          address(this).balance,
          requests.length,
          approversCount,
          manager
        );
    }

    function getRequestsCount() public view returns (uint256) {
        return requests.length;
    }

}