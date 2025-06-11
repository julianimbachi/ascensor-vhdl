library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DECOSEN2BIN is
    Port (
        entrada : in STD_LOGIC_VECTOR(4 downto 0);
        salida  : out STD_LOGIC_VECTOR(2 downto 0)
    );
end DECOSEN2BIN;

architecture Behavioral of DECOSEN2BIN is
begin
    process(entrada)
    begin
        case entrada is
            when "00000" => salida <= "000";
            when "00001" => salida <= "001";
            when "00010" => salida <= "010";
            when "00100" => salida <= "011";
            when "01000" => salida <= "100";
            when "10000" => salida <= "101";
            when others => salida <= "000"; -- Valor por defecto
        end case;
    end process;
end Behavioral;

 
