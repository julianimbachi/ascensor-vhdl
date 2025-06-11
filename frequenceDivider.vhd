library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frequenceDivider is 
    generic(divider: integer := 25000000);
    port(
        clk: in std_logic;
        seg: out std_logic
    );
end entity frequenceDivider;

architecture arch of frequenceDivider is  
    signal seg_reg : std_logic := '0'; -- Señal interna para salida
begin 
    process(clk) 
        variable incount: integer range 0 to 50000000 := 0;
    begin
        if rising_edge(clk) then 
            incount := incount + 1; 
            if (incount = divider) then
                seg_reg <= not seg_reg;
                incount := 0; -- corregido para reiniciar bien
            end if;
        end if;
    end process;

    seg <= seg_reg;

end architecture arch;



