library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_dc is
end testbench_dc;

architecture behavior of testbench_dc is

    component control_motordc
        Port (
            clk         : in  std_logic;
            start       : in  std_logic;
            destino     : in  std_logic_vector(2 downto 0);
            piso_actual : in  std_logic_vector(2 downto 0);
            subiendo    : out std_logic;
            bajando     : out std_logic;
            finalizado  : out std_logic
        );
    end component;

    -- Señales
    signal clk         : std_logic := '0';
    signal start       : std_logic := '1';  -- ACTIVO EN BAJO
    signal destino     : std_logic_vector(2 downto 0) := (others => '0');
    signal piso_actual : std_logic_vector(2 downto 0) := (others => '0');
    signal subiendo    : std_logic;
    signal bajando     : std_logic;
    signal finalizado  : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- Instancia del DUT
    uut: control_motordc
        Port map (
            clk         => clk,
            start       => start,
            destino     => destino,
            piso_actual => piso_actual,
            subiendo    => subiendo,
            bajando     => bajando,
            finalizado  => finalizado
        );

    -- Generador de reloj
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Estímulos de prueba
    stim_proc : process
    begin
        wait for 20 ns;

        -- CASO 1: Subir de 2 a 5
        piso_actual <= std_logic_vector(to_unsigned(2, 3));
        destino     <= std_logic_vector(to_unsigned(5, 3));

        -- Pulso en START (ACTIVO EN BAJO)
        start <= '0';
        wait for clk_period;
        start <= '1';

        -- Simula que se sube de piso poco a poco
        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(3, 3));
        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(4, 3));
        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(5, 3)); -- destino

        wait for 40 ns;

        -- CASO 2: Bajar de 6 a 3
        piso_actual <= std_logic_vector(to_unsigned(6, 3));
        destino     <= std_logic_vector(to_unsigned(3, 3));

        start <= '0';
        wait for clk_period;
        start <= '1';

        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(5, 3));
        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(4, 3));
        wait for 30 ns; piso_actual <= std_logic_vector(to_unsigned(3, 3)); -- destino

        wait for 40 ns;

        -- CASO 3: Mismo piso (4 a 4)
        piso_actual <= std_logic_vector(to_unsigned(4, 3));
        destino     <= std_logic_vector(to_unsigned(4, 3));

        start <= '0';
        wait for clk_period;
        start <= '1';

        wait for 50 ns;

        -- Fin de simulación
        wait;
    end process;

end behavior;


