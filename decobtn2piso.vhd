library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decobtn2piso is
    Port (
        clk       : in  STD_LOGIC;
        btn_up    : in  STD_LOGIC_VECTOR(3 downto 0);
        btn_down  : in  STD_LOGIC_VECTOR(3 downto 0);
        no_piso   : out STD_LOGIC_VECTOR(2 downto 0)
    );
end decobtn2piso;

architecture Behavioral of decobtn2piso is
begin
    process(clk)
        variable piso_var : STD_LOGIC_VECTOR(2 downto 0) := "000";
    begin
        if rising_edge(clk) then
            -- Valor por defecto
            piso_var := "000";
            
            if (btn_up /= "0000") then
                case btn_up is
                    when "0001" => piso_var := "001";
                    when "0010" => piso_var := "010";
                    when "0100" => piso_var := "011";
                    when "1000" => piso_var := "100";
                    when others => piso_var := "000";
                end case;
            elsif (btn_down /= "0000") then
                case btn_down is
                    when "0001" => piso_var := "010";
                    when "0010" => piso_var := "011";
                    when "0100" => piso_var := "100";
                    when "1000" => piso_var := "101";
                    when others => piso_var := "000";
                end case;
            end if;
            
            -- Asignación inmediata a la salida
            no_piso <= piso_var;
        end if;
    end process;
end Behavioral;