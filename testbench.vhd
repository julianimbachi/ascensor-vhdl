library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm_puerta is
end entity;

architecture sim of tb_fsm_puerta is

    -- Componentes para instanciar
    component fsm_puerta
        port (
            clk            : in  std_logic;
            rst            : in  std_logic;
            start          : in  std_logic;
            open_btn       : in  std_logic;
            close_btn      : in  std_logic;
            puerta_abierta : out std_logic;
            puerta_cerrada : out std_logic;
            alarma_out     : out std_logic
        );
    end component;

    -- Señales para conectar al DUT
    signal clk            : std_logic := '0';
    signal rst            : std_logic := '1';
    signal start          : std_logic := '0';
    signal open_btn       : std_logic := '0';
    signal close_btn      : std_logic := '0';
    signal puerta_abierta : std_logic;
    signal puerta_cerrada : std_logic;
    signal alarma_out     : std_logic;

    -- Generar reloj de 10ns (100MHz)
    constant clk_period : time := 10 ns;

begin

    -- Instancia del DUT
    dut: fsm_puerta
        port map (
            clk            => clk,
            rst            => rst,
            start          => start,
            open_btn       => open_btn,
            close_btn      => close_btn,
            puerta_abierta => puerta_abierta,
            puerta_cerrada => puerta_cerrada,
            alarma_out     => alarma_out
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

    -- Estímulos
    stim_proc : process
    begin
        -- Reset activo por 2 ciclos
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- Activar sistema
        start <= '1';
        wait for 10 ns;

        -- Simular apertura
        open_btn <= '1';
        wait for 20 ns;
        open_btn <= '0';

        -- Esperar y cerrar
        wait for 50 ns;
        close_btn <= '1';
        wait for 20 ns;
        close_btn <= '0';

        -- Esperar a que vuelva a estado inactivo
        wait for 100 ns;

        -- Finalizar simulación
        wait;
    end process;

end architecture;
