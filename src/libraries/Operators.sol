// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract Operator {
    mapping(address => bool) private _operators;

    event SetOperatorStatus(address operator, bool isActive);

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Operator: Caller is not operator");
        _;
    }

    function _setOperator(address operator, bool isActive) internal {
        _operators[operator] = isActive;

        emit SetOperatorStatus(operator, isActive);
    }

    function isOperator(address user) public view returns (bool) {
        return _operators[user];
    }

    function setOperator(address operator, bool isActive) external virtual;
}
