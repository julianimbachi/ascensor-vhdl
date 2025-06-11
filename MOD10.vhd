library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MOD10 is
    Port (
        clk     : in  STD_LOGIC;
        enable  : in  STD_LOGIC;
        abrir   : in  STD_LOGIC;
        cuenta  : out STD_LOGIC_VECTOR (3 downto 0);
		  alarma  : out std_logic;
        abriendo: out STD_LOGIC 		  
    );
end MOD10;

architecture Behavioral of MOD10 is
    signal contador       : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal S_abrir        : STD_LOGIC := '0';
    signal S_alarma       : std_logic := '0';
    signal clkseg         : STD_LOGIC;

    component frequenceDivider is 
        generic(divider: integer := 25000000);
        port(
            clk: in std_logic;
            seg: out std_logic
        );
    end component;

begin
    U1 : frequenceDivider
        port map(clk => clk, seg => clkseg);

    process(clk)
    begin
        if rising_edge(clkseg) then

            -- Si 'abrir' está activo y enable = '1', reiniciamos el contador
            if (abrir = '1' and enable = '1') then
                contador  <= "0000";
                S_abrir   <= '1';
                S_alarma  <= '1';

            -- Solo contar si enable está activo y abrir no está activo
            elsif enable = '1' and abrir = '0' then
                if contador = "1001" then
                    contador  <= "0000";
                    S_abrir   <= '1';
                    S_alarma  <= '1';
                else
                    contador  <= contador + 1;
                    S_abrir   <= '0';
                    S_alarma  <= '0';
                end if;

            else
                -- Si enable = '0', no hacer nada (no contar)
                S_abrir   <= '0';
                S_alarma  <= '0';
					 contador <="0000";
            end if;

        end if;
    end process;

    cuenta   <= contador;
    abriendo <= S_abrir;
    alarma   <= S_alarma;

end Behavioral;



