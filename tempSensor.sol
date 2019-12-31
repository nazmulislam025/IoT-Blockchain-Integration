pragma solidity ^0.5.11;

//Smart contract for ESP8266 connected to RPi running embedded Geth
//Geth node is local, behind firewall, Rinkeby ProofOfAuthority
//ESP8266 posts temperature from DS18B20 sensor
//Rinkeby users can get realtime temperature via updateTemp function 
//Must send minimum 0.01 ether to updateTemp function
//If ESP8266 does not update contract, the batteries need replacing
//Rinkeby users can turn on green LED attached to ESP8266 via turnLightOn function
//Must send minimum 1.0 ether to turnLightOn function
//Only the contact owner can turn the light off

contract tempSensor
{
    bool LEDturnedOn;
    bool tempUpdated;
    int256 currentTemp;
    uint256 lastTempUpdate;
    address owner;
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public
    {
        LEDturnedOn = false;
        tempUpdated = true;
        lastTempUpdate = block.number;
        owner = msg.sender;
    }
    
    function isLightTurnedOn() public view returns (bool)
    {
        return LEDturnedOn;
    }
    
    function isTempCurrent() public view returns (bool)
    {
        return tempUpdated;
    }
    
    function turnLightOn() public payable
    {
        if( msg.value < 1000 finney){ revert(); }
        LEDturnedOn = true;
    }
    
    function turnLightOffAdminOnly() public onlyOwner
    {
        LEDturnedOn = false;
    }
    
    function updateTemp() public payable
    {
        if(msg.value < 10 finney){ revert(); }
        tempUpdated = false;
    }
    
    function setTempDeviceOnly(int256 _temp) public onlyOwner
    {
        currentTemp = _temp;
        lastTempUpdate = block.number;
        tempUpdated = true;
    }
    
    function getTemp() public view returns (int256, uint256)
    {
        return (currentTemp, lastTempUpdate);
    }

    function transferOutAdminOnly(address payable addr, uint256 amount) public onlyOwner
    {
        if(amount <= address(this).balance)
        {
            addr.transfer(amount);
        }
    }
}
