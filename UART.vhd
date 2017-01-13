----------------------------------------------------------------------------------
-- Engineer: 				Jason Murphy
-- Create Date:   		09:00 01/27/2016 
-- Design Name: 			UART
-- Module Name:   		UART - Behavioral 
-- Project Name: 			GPSInterface
-- Target Devices: 		Spartan 6 xc6slx9-3tgg144
-- Tool versions: 		ISE 14.7
-- Description: 			8 bit output UART receiver
--								Fixed at 9600 baud, no parity
--								receive only no RTS/CTS Ctrl
--								Revision V0.01
-- Dependencies: 			
-- Revision 				0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART is Port ( 
	clk50 : in STD_LOGIC;
	RxD : in  STD_LOGIC;
   Dout : out  STD_LOGIC_VECTOR (7 downto 0);
   Drdy : out  STD_LOGIC);
end UART;

architecture Behavioral of UART is

signal RxDBuff : std_logic_vector(1 downto 0);
signal counter : integer range 0 to 1048575 := 0;
type cmdSequence is (unknown, idle, startBit, validData, stopBit, error);
signal currentState : cmdSequence := unknown;
signal DoutSig : std_logic_vector(7 downto 0);
signal bitCount : integer range 0 to 7 := 0;
begin

process(clk50)
begin
	if rising_edge(clk50) then
		Drdy <= '1';
		RxDBuff <= RxDBuff(0) & RxD;
		counter <= counter + 1;
		if counter = 1048575 then
			currentState <= idle;
		end if;	
		case currentState is
		when unknown =>
			if RxDBuff = "00" then
				counter <= 0;
			end if;
		when idle =>
			if RxDBuff = "00" then -- at the start bit
				counter <= 0;       -- reset the counter
				currentState <= startBit;
			end if;
		when startBit =>
			if counter = 4096 then  -- half clock cycle into start bit
				currentState <= validData; -- data is valid
				counter <= 0;
				bitCount <= 0;
			end if;
			if RxDBuff = "01" then
				currentState <= error;   -- unless RxD goes high
			end if;
		when validData =>
			if counter = 5208 then   -- measure approx half clock cycle
				DoutSig <= RxDBuff(1) & DoutSig(7 downto 1); -- and sample RxD
				counter <= 0;  -- then reset count
				bitCount <= bitCount + 1;  --  and increment bit count
				if bitCount = 7 then
					currentState <= stopBit;  -- when 8 bits received
				end if;
			end if;
		when stopBit =>
			if counter = 5208 then  -- half clock cycle in
				if RxDBuff = "11" then  -- check stop bit received
					Drdy <= '0';  -- and indicate valid parallel data 
					currentState <= idle; 
				else
					currentState <= error;
				end if;
				counter <= 0;
			end if;
		when error =>
			DoutSig <= "10101110";
			Drdy <= '0';
			currentState <= unknown;
		end case;
	end if;
end process;

Dout <= DoutSig;

end Behavioral;

