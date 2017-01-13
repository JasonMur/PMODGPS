----------------------------------------------------------------------------------
-- Engineer: 			Jason Murphy
-- Create Date:   		09:00 01/12/2017 
-- Design Name: 		UARTtoI2C
-- Module Name:   		UARTtoI2C - Behavioral 
-- Project Name: 		GPSInterface
-- Target Devices: 		Spartan 6 xc6slx9-3tgg144
-- Tool versions: 		ISE 14.7
-- Description: 		Reads GPS data from UART via I2C on
--				Raspberry Pi
-- Dependencies: 			
-- Revision 			0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UARTtoI2C is Port ( 
   	sck : inout  STD_LOGIC;
   	sda : inout  STD_LOGIC;
   	RxD : in  STD_LOGIC;
   	clk50 : in  STD_LOGIC);
end UARTtoI2C;

architecture Behavioral of UARTtoI2C is

component I2CInt port( 
	sda, sck : inout std_logic := 'Z';
	clk50 : in std_logic; 
	Bsy : in std_logic;	
	regAddr : out std_logic_vector (7 downto 0);
	regDataIn : in std_logic_vector (7 downto 0);
	regDataOut : out std_logic_vector (7 downto 0);
	readData, writeData : out std_logic := '1';
	sdaTest, sckTest : out std_logic);
end component; 

component UART Port ( 
	clk50 : in STD_LOGIC;
	RxD : in  STD_LOGIC;
   	Dout : out  STD_LOGIC_VECTOR (7 downto 0);
   	Drdy : out  STD_LOGIC);
end component;

component fifo port (  
	clk50 : in std_logic;
   	readData : in std_logic;   --Read Data from FIFO.  Active low data read on falling edge
   	writeData : in std_logic;  --Write Data to FIFO.  Active low data written on falling edge
   	dataOut : out std_logic_vector(7 downto 0);    --output data from FIFO
   	dataIn : in std_logic_vector (7 downto 0);     --input data to FIFO
   	empty : out std_logic);     --set as '1' when FIFO overrun occurs
end component;

signal dataFromFIFOSig, dataToFIFOSig : std_logic_vector(7 downto 0);
signal readDataSig, writeDataSig : std_logic;
signal bsySig : std_logic;

begin

I2C1 : I2CInt port map (
	sda => sda,
	sck => sck,
	clk50 => clk50, 
	bsy => '0',
	regDataIn => dataFromFIFOSig,
	readData => readDataSig
);

fifo1 : fifo port map (
	clk50 => clk50,
   	readData => readDataSig,
   	writeData => writeDataSig,
   	dataOut => dataFromFIFOSig,
   	dataIn => dataToFIFOSig,
	empty => bsySig
);

UART1 : UART Port map (
	clk50 => clk50,
	RxD => RxD,
   	Dout => dataToFIFOSig,
   	Drdy => writeDataSig
);

end Behavioral;

