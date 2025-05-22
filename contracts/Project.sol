// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Decentralized Skill Verification Oracle
 * @dev A smart contract system for verifying professional skills through trusted oracles
 * @author Your Name
 */
contract Project is Ownable, ReentrancyGuard {
    
    // Struct to represent a skill verification request
    struct SkillVerification {
        address applicant;
        string skillName;
        string evidenceHash; // IPFS hash or other proof
        uint256 timestamp;
        VerificationStatus status;
        address verifyingOracle;
        uint256 stakeAmount;
    }
    
    // Struct to represent an oracle
    struct Oracle {
        address oracleAddress;
        string specialization;
        uint256 reputation;
        bool isActive;
        uint256 totalVerifications;
    }
    
    // Enum for verification status
    enum VerificationStatus {
        Pending,
        Verified,
        Rejected,
        Disputed
    }
    
    // State variables
    mapping(uint256 => SkillVerification) public verifications;
    mapping(address => Oracle) public oracles;
    mapping(address => uint256[]) public userVerifications;
    mapping(string => uint256[]) public skillVerifications;
    
    uint256 public verificationCounter;
    uint256 public constant STAKE_AMOUNT = 0.01 ether;
    uint256 public constant ORACLE_REWARD = 0.005 ether;
    
    // Events
    event SkillVerificationRequested(
        uint256 indexed verificationId,
        address indexed applicant,
        string skillName
    );
    
    event SkillVerified(
        uint256 indexed verificationId,
        address indexed oracle,
        bool approved
    );
    
    event OracleRegistered(
        address indexed oracle,
        string specialization
    );
    
    constructor() Ownable(msg.sender) {
        verificationCounter = 0;
    }
    
    /**
     * @dev Register as an oracle with specialization
     * @param _specialization The area of expertise for the oracle
     */
    function registerOracle(string memory _specialization) external {
        require(bytes(_specialization).length > 0, "Specialization cannot be empty");
        require(!oracles[msg.sender].isActive, "Oracle already registered");
        
        oracles[msg.sender] = Oracle({
            oracleAddress: msg.sender,
            specialization: _specialization,
            reputation: 100, // Starting reputation
            isActive: true,
            totalVerifications: 0
        });
        
        emit OracleRegistered(msg.sender, _specialization);
    }
    
    /**
     * @dev Request skill verification by staking tokens
     * @param _skillName Name of the skill to be verified
     * @param _evidenceHash IPFS hash or other proof of skill
     */
    function requestSkillVerification(
        string memory _skillName,
        string memory _evidenceHash
    ) external payable nonReentrant {
        require(msg.value >= STAKE_AMOUNT, "Insufficient stake amount");
        require(bytes(_skillName).length > 0, "Skill name cannot be empty");
        require(bytes(_evidenceHash).length > 0, "Evidence hash cannot be empty");
        
        uint256 verificationId = verificationCounter++;
        
        verifications[verificationId] = SkillVerification({
            applicant: msg.sender,
            skillName: _skillName,
            evidenceHash: _evidenceHash,
            timestamp: block.timestamp,
            status: VerificationStatus.Pending,
            verifyingOracle: address(0),
            stakeAmount: msg.value
        });
        
        userVerifications[msg.sender].push(verificationId);
        skillVerifications[_skillName].push(verificationId);
        
        emit SkillVerificationRequested(verificationId, msg.sender, _skillName);
    }
    
    /**
     * @dev Verify a skill request (oracle function)
     * @param _verificationId ID of the verification request
     * @param _approved Whether the skill is verified or not
     */
    function verifySkill(uint256 _verificationId, bool _approved) external nonReentrant {
        require(oracles[msg.sender].isActive, "Not an active oracle");
        require(_verificationId < verificationCounter, "Invalid verification ID");
        
        SkillVerification storage verification = verifications[_verificationId];
        require(verification.status == VerificationStatus.Pending, "Verification already processed");
        require(verification.applicant != msg.sender, "Cannot verify own skill");
        
        // Update verification status
        verification.status = _approved ? VerificationStatus.Verified : VerificationStatus.Rejected;
        verification.verifyingOracle = msg.sender;
        
        // Update oracle stats
        oracles[msg.sender].totalVerifications++;
        if (_approved) {
            oracles[msg.sender].reputation += 5;
        }
        
        // Handle payments
        if (_approved) {
            // Return stake to applicant and pay oracle
            payable(verification.applicant).transfer(verification.stakeAmount - ORACLE_REWARD);
            payable(msg.sender).transfer(ORACLE_REWARD);
        } else {
            // Oracle gets partial reward, rest goes to contract
            payable(msg.sender).transfer(ORACLE_REWARD / 2);
        }
        
        emit SkillVerified(_verificationId, msg.sender, _approved);
    }
    
    // View functions
    function getVerification(uint256 _verificationId) external view returns (SkillVerification memory) {
        require(_verificationId < verificationCounter, "Invalid verification ID");
        return verifications[_verificationId];
    }
    
    function getUserVerifications(address _user) external view returns (uint256[] memory) {
        return userVerifications[_user];
    }
    
    function getSkillVerifications(string memory _skill) external view returns (uint256[] memory) {
        return skillVerifications[_skill];
    }
    
    function getOracleInfo(address _oracle) external view returns (Oracle memory) {
        return oracles[_oracle];
    }
    
    function isSkillVerified(address _user, string memory _skillName) external view returns (bool) {
        uint256[] memory userVers = userVerifications[_user];
        
        for (uint256 i = 0; i < userVers.length; i++) {
            SkillVerification memory verification = verifications[userVers[i]];
            if (
                keccak256(abi.encodePacked(verification.skillName)) == keccak256(abi.encodePacked(_skillName)) &&
                verification.status == VerificationStatus.Verified
            ) {
                return true;
            }
        }
        return false;
    }
    
    // Emergency functions
    function withdrawContractBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    function deactivateOracle(address _oracle) external onlyOwner {
        oracles[_oracle].isActive = false;
    }
}
