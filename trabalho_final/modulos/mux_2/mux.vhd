library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
	port (
		A, B 	: 	in std_logic_vector(31 downto 0);
		M	: 	in std_logic;
		N	:	out std_logic_vector(31 downto 0)
	);
end mux;

architecture rtl of mux is
	signal A_s, B_s, N_s	:	std_logic_vector(31 downto 0);
	signal M_s	:	std_logic;

begin
	A_s <= A;
	B_s <= B;

	M_s <= M;
	N <= N_s;

	process(A_s, B_s)
	begin

	if (M_s = '0') then
		N_s <= A_s;
	else
		N_s <= B_s;
	end if;

	N <= N_s;
	end process;


end rtl;