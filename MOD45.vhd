library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MOD45 is
    Port (
        clk        : in  STD_LOGIC;
        cerrar     : in  STD_LOGIC;
        abriendoIn : in  STD_LOGIC;
        cuenta     : out STD_LOGIC_VECTOR (5 downto 0);  -- Hasta 44
        cerrando   : out STD_LOGIC;
        alarma     : out STD_LOGIC
    );
end MOD45;

architecture Behavioral of MOD45 is
    signal contador       : unsigned(5 downto 0) := (others => '0');  -- 6 bits
    signal S_cerrando     : STD_LOGIC := '0';
    signal S_alarma       : STD_LOGIC := '0';
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
        port map (clk => clk, seg => clkseg);

    process(clkseg)
    begin
        if rising_edge(clkseg) then

            -- Si cerrar está activo mientras se está abriendo, reiniciar
            if cerrar = '1' and abriendoIn = '1' then
                contador    <= (others => '0');
                S_cerrando  <= '1';
                S_alarma    <= '1';

            -- Si abriendoIn está activo y cerrar no, entonces contar
            elsif abriendoIn = '1' and cerrar = '0' then
                if contador = to_unsigned(16, 6) then
                    contador    <= (others => '0');
                    S_cerrando  <= '1';
                    S_alarma    <= '1';
                else
                    contador    <= contador + 1;
                    S_cerrando  <= '0';
                    S_alarma    <= '0';
                end if;

            else
                -- No contarc
					 contador<=(others=>'0');
                S_cerrando <= '0';
                S_alarma   <= '0';
            end if;

        end if;
    end process;

    cuenta   <= std_logic_vector(contador);
    cerrando <= S_cerrando;
    alarma   <= S_alarma;

end Behavioral;

