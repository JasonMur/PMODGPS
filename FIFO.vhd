----------------------------------------------------------------------------------
-- Engineer: 			Jason Murphy
-- Create Date:   		09:00 01/12/2017 
-- Design Name: 		FIFO
-- Module Name:   		FIFO - Behavioral 
-- Project Name: 		GPSInterface
-- Target Devices: 		Spartan 6 xc6slx9-3tgg144
-- Tool versions: 		ISE 14.7
-- Description: 		8 bit FIFO for buffering UART data
--				Revision V0.01
-- Dependencies: 			
-- Revision 			0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo is port (  
	clk50 : in std_logic;
   	readData : in std_logic;   --Read Data from FIFO.  Active low data read on falling edge
   	writeData : in std_logic;  --Write Data to FIFO.  Active low data written on falling edge
   	dataOut : out std_logic_vector(7 downto 0);    --output data from FIFO
   	dataIn : in std_logic_vector (7 downto 0);     --input data to FIFO
   	empty, full : out std_logic);     --set as '1' when FIFO overrun occurs
end fifo;

architecture Behavioral of fifo is

	type SRAM is array (0 to 255) of std_logic_vector(7 downto 0);
	signal FIFO : SRAM :=(others => (others => '0'));
	signal readDataSig, writeDataSig : std_logic_vector (1 downto 0);
	signal FIFOReadPtr, FIFOWritePtr : integer range 0 to 255 := 0;

begin
	process(clk50)
	begin
	if rising_edge(clk50) then
		readDataSig <= readDataSig(0) & readData;
		writeDataSig <= writeDataSig(0) & writeData;
		
		if readDataSig = "10" then
			if FIFOReadPtr = FIFOWritePtr then
				dataOut <= "00100100";
				empty <= '1';
			else
				dataOut <= FIFO(FIFOReadPtr);
				FIFOReadPtr <= FIFOReadPtr + 1;
				empty <= '0';
			end if;
		end if;
		
		if writeDataSig = "10" then
			if (FIFOWritePtr + 1) = FIFOReadPtr then
				full <= '1';
			elsif FIFOWritePtr = 255 and FIFOReadPtr = 0 then
				full <= '1';
			else
				FIFO(FIFOWritePtr) <= datain;
				FIFOWritePtr <= FIFOWritePtr + 1;
				full <= '0';
			end if;
		end if;
		
	end if;
	end process;

end Behavioral;
