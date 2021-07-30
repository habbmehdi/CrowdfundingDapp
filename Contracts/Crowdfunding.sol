// We will be using Solidity version 0.5.4
pragma solidity 0.8.4;
// Importing OpenZeppelin's SafeMath Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';


contract Project {
    using SafeMath for uint256;
        
        
    enum State {
        Ongoing,
        Successful,
        Expired
    }
        
    address payable public creator;
    uint public amountGoal;
    // address(this).balance
    uint public raiseBy;
    State public state = State.Ongoing;
    mapping (address => uint) public contributions;
    
    
    modifier checkState(State _state){
        require(state == _state);
        _;
    }
    
    
    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }
    
    constructor
    (
        address payable projectStarter,
        uint fundRaisingDeadline,
        uint goalAmount
    ) {
        creator = projectStarter;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
    }
    
    function contribute() external checkState(State.Ongoing) payable {
        require(msg.sender != creator);
        contributions[msg.sender] += msg.value;
        checkFundingChange;
    }
    
    function checkFundingChange() public{
        if (address(this).balance >= amountGoal) {
            state = State.Successful;
            payOut();
        }
    }
    
    function getRefund() public checkState(State.Expired) returns (bool){
        require(contributions[msg.sender] > 0);
        
        uint amount = contributions[msg.sender];
        
        if (amount > 0){
            
            contributions[msg.sender] = 0;
            
            
            if (!payable(msg.sender).send(amount)){
                contributions[msg.sender] = amount;
                return false;
            }
        }
        
        return true;
    }
    
    function payOut() internal checkState(State.Successful){
        payable(creator).transfer(address(this).balance);
    }
    
}