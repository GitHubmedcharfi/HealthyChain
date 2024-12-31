pragma solidity ^0.5.1;
import "hardhat/console.sol";

contract Agent {

    struct Patient {
        string name;
        uint age;
        address[] doctorAccessList;
        uint[] diagnosis;
        string record;
    }

    struct Doctor {
        string name;
        uint age;
        address[] patientAccessList;
    }

    uint creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping(address => Patient) patientInfo;
    mapping(address => Doctor) doctorInfo;
    mapping(address => address) Empty;
    mapping(address => string) patientRecords;

    event AgentAdded(string name, uint age, uint designation);
    event AccessGranted(address doctor, address patient);
    event AccessRevoked(address doctor, address patient);
    event InsuranceClaimProcessed(address doctor, address patient, uint diagnosis, string record);

    function add_agent(string memory _name, uint _age, uint _designation, string memory _hash) public returns (string memory) {
    address addr = msg.sender;

    require(bytes(_name).length > 0, "Nom invalide ou informations manquantes");
    require(_age > 0, "Age invalide");  // Vérification de l'âge

    // Désignation: 0 = Patient, 1 = Docteur
    if (_designation == 0) {
        // Vérifier si le patient n'existe pas déjà
        require(patientInfo[msg.sender].age == 0, "Patient déjà ajouté");

        Patient memory p;
        p.name = _name;
        p.age = _age;
        p.record = _hash;
        patientInfo[msg.sender] = p;  // Sauvegarder les informations du patient
        patientList.push(addr);

        emit AgentAdded(_name, _age, _designation);
        return _name;
    } else if (_designation == 1) {
        // Vérifier si le docteur n'existe pas déjà
        require(doctorInfo[addr].age == 0, "Docteur déjà ajouté");

        Doctor storage d = doctorInfo[addr];
        d.name = _name;
        d.age = _age;
        doctorList.push(addr);

        emit AgentAdded(_name, _age, _designation);
        return _name;
    } else {
        revert("Désignation invalide");  // Désignation doit être 0 ou 1
    }
}


    function log(string memory message) internal {
        console.log("%s", message);
    }

    function get_patient(address addr) view public returns (string memory, uint, uint[] memory, address, string memory) {
        return (patientInfo[addr].name, patientInfo[addr].age, patientInfo[addr].diagnosis, Empty[addr], patientInfo[addr].record);
    }

    function get_doctor(address addr) view public returns (string memory, uint) {
        return (doctorInfo[addr].name, doctorInfo[addr].age);
    }

    function get_patient_doctor_name(address paddr, address daddr) view public returns (string memory, string memory) {
        return (patientInfo[paddr].name, doctorInfo[daddr].name);
    }

    function permit_access(address addr) payable public {
        require(msg.value == 2 ether, "You must pay exactly 2 ether to grant access");

        creditPool += 2;

        doctorInfo[addr].patientAccessList.push(msg.sender);
        patientInfo[msg.sender].doctorAccessList.push(addr);

        emit AccessGranted(addr, msg.sender);
    }

    function insurance_claim(address paddr, uint _diagnosis, string memory _hash) public {
        bool patientFound = false;
        for (uint i = 0; i < doctorInfo[msg.sender].patientAccessList.length; i++) {
            if (doctorInfo[msg.sender].patientAccessList[i] == paddr) {
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;

                emit InsuranceClaimProcessed(msg.sender, paddr, _diagnosis, _hash);
            }
        }

        require(patientFound, "Patient not found in doctor's access list");
        set_hash(paddr, _hash);
        remove_patient(paddr, msg.sender);
    }

    function remove_element_in_array(address[] storage Array, address addr) internal {
        uint del_index = 0;
        bool found = false;
        
        for (uint i = 0; i < Array.length; i++) {
            if (Array[i] == addr) {
                del_index = i;
                found = true;
                break;
            }
        }

        require(found, "Element not found in array");

        // Move the last element to the deleted index and pop it
        Array[del_index] = Array[Array.length - 1];
        Array.pop();
    }

    function remove_patient(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);

        emit AccessRevoked(daddr, paddr);
    }

    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory) {
        return patientInfo[addr].doctorAccessList;
    }

    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory) {
        return doctorInfo[addr].patientAccessList;
    }

    function revoke_access(address daddr) public payable {
        remove_patient(msg.sender, daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;

        emit AccessRevoked(daddr, msg.sender);
    }

    function get_patient_list() public view returns (address[] memory) {
        return patientList;
    }

    function get_doctor_list() public view returns (address[] memory) {
        return doctorList;
    }

    function get_hash(address paddr) public view returns (string memory) {
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }
}
