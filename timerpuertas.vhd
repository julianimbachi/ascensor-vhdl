library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timerpuertas is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic; 		  -- Habilita el conteo
        count1 : out std_logic_vector(2 downto 0);
		  alarma  : out std_logic                        -- Se activa cuando se cumplen 5 segundos
    );
end entity;

architecture behavioral of timerpuertas is

    -- ===== Componente divisor de frecuencia =====
    component frequenceDivider is 
        generic(divider: integer := 25000000);  -- Divide para obtener 1 Hz si clk = 50 MHz
        port(
            clk : in  std_logic;
            seg : out std_logic
        );
    end component;

    -- ===== Señales internas =====
    signal contador : unsigned(2 downto 0) := (others => '0');  -- Cuenta hasta 5
    signal clkseg   : std_logic;

begin

    -- ===== Instancia del divisor de frecuencia =====
    U1: frequenceDivider 
        port map (
            clk => clk,
            seg => clkseg
        );

    -- ===== Proceso principal del temporizador =====
    process(clkseg, rst)
    begin
        if rst = '1' then
            contador <= (others => '0');
            alarma   <= '0'; 
        elsif rising_edge(clkseg) then
            if enable = '1' then
                if contador < 3 then
                    contador <= contador + 1;
                    alarma <= '0';
                else
                    alarma <= '1';  -- Se activa la alarma al llegar a 2
                end if;
            else
                contador <= (others => '0'); -- Reset si no hay enable
                alarma   <= '0';
            end if;
        end if;
		count1<=std_logic_vector(contador);
    end process;



end architecture;
