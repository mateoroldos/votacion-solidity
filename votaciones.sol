// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

contract votacion{
    // Direccion del propietario del contrato
    address owner;

    // Constructor
    constructor () public{
        owner = msg.sender;
    }

    // Relacion entre el nombre del candidato y el hash de sus datos personales
    mapping (string=>bytes32) ID_Candidato;

    // Relacion entre el nombre del candidato y el numero de votos
    mapping (string=>uint) votos_candidato;

    // Lista para almacenar todos los candidatos
    string [] candidatos;

    // Lista de los hashes de la identidad de los votantes
    bytes32 [] votantes;

    // Funcion para que alguien se presente a las elecciones
    function Representar(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public{
         
        // Hash de los datos del candidato
        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));

        // Almacenar el hash de los datos del candidato ligado a su nombre
        ID_Candidato[_nombrePersona] = hash_Candidato;

        // Almacenamos el nombre del candidato
        candidatos.push(_nombrePersona);
    }

    // Devolver candidatos que se presentaron
    function verCandidatos() public view returns(string[] memory) {
        return candidatos;
    }

    function Votar(string memory _candidato) public {
        
        // Hash de la direccion de la persona que ejecuta la funcion
        bytes32 hash_Votante = keccak256(abi.encodePacked(msg.sender));

        // Verificamos si el votante ya ha votado
        for(uint i=0; i<votantes.length; i++){
            require(votantes[i]!=hash_Votante, "Ya has votado previamente");
        }
        
        // Añadir el hash del votante a array de votantes
        votantes.push(hash_Votante);

        // Añadimos un voto al candidato seleccionado
        votos_candidato[_candidato]++;   
    }

    // Dado el nombre de un candidato nos devuelvo la cantidad de votos que tiene
    function VerVotos(string memory _candidato) public view returns(uint) {
        return votos_candidato[_candidato];
    }

    //Funcion auxiliar que transforma un uint a un string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Ver los votos de cada uno de los candidatos
    function VerResultados() public view returns(string memory) {

        // Guardamos en una variable string los candidatos con sus respectivos votos
        string memory resultados;

        for(uint i=0; i<candidatos.length; i++){
            // Actualizamos el string resultados y añadimos el candidato que ocupa la posicion "i" del array candidatos y su numero de votos 
            resultados = string(abi.encodePacked(resultados, "(", candidatos[i], ", ", uint2str(VerVotos(candidatos[i])), ") --- " ));
        }

        // Devolvemos los resultados
        return resultados;
    }

    function Ganador() public view returns(string memory) {

        // Variable que contiene el nombre del ganador
        string memory ganador = candidatos[0];

        // Flag que detecta un empate
        bool flag;

        // Recorremos el array de candidatos para encontrar el ganador
        for(uint i=1; i<candidatos.length; i++){

            // Comprobamos si alguien supera al ganador
            if(votos_candidato[ganador] < votos_candidato[candidatos[i]]){
                ganador = candidatos[i];
                flag = false;
            }else{
                // Detectamos si hay un empate
                if(votos_candidato[ganador] == votos_candidato[candidatos[i]]){
                    flag = true;
                }
            }
        }

        // Chequeamos si el resultado fue empate
        if (flag == true){
            ganador = "¡Hay un empate!";
        }

        // Devolvemos al ganador
        return ganador;
    }
}