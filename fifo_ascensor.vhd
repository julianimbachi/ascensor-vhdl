library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_ascensor is
  Port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    nueva_solicitud : in  std_logic;
    piso_solicitado : in  std_logic_vector(2 downto 0);
    leer_solicitud  : in  std_logic;
    piso_atender    : out std_logic_vector(2 downto 0);
    fifo_llena      : out std_logic;
    fifo_vacia      : out std_logic;
    hay_solicitud   : out std_logic
  );
end fifo_ascensor;

architecture Behavioral of fifo_ascensor is

  type memoria_tipo is array(0 to 4) of std_logic_vector(2 downto 0);
  signal memoria   : memoria_tipo := (others => "000");
  signal head      : integer range 0 to 4 := 0;
  signal tail      : integer range 0 to 4 := 0;
  signal ocupacion : integer range 0 to 5 := 0;

  function existe_piso(m : memoria_tipo; piso : std_logic_vector(2 downto 0); elementos : integer) return boolean is
  begin
    for i in 0 to elementos - 1 loop
      if m(i) = piso then
        return true;
      end if;
    end loop;
    return false;
  end function;

begin

  process(clk, reset)
  begin
    if reset = '1' then
      memoria     <= (others => "000");
      head        <= 0;
      tail        <= 0;
      ocupacion   <= 0;
      piso_atender <= "000";

    elsif rising_edge(clk) then

      -- Inserción de nuevo piso
      if nueva_solicitud = '1' and ocupacion < 5 then
        if not existe_piso(memoria, piso_solicitado, ocupacion) then
          memoria(tail) <= piso_solicitado;
          tail <= (tail + 1) mod 5;
          ocupacion <= ocupacion + 1;
        end if;
      end if;

      -- Lectura de solicitud
      if leer_solicitud = '1' and ocupacion > 0 then
        piso_atender <= memoria(head);
        head <= (head + 1) mod 5;
        ocupacion <= ocupacion - 1;
      end if;

    end if;
  end process;

  fifo_llena    <= '1' when ocupacion = 5 else '0';
  fifo_vacia    <= '1' when ocupacion = 0 else '0';
  hay_solicitud <= '1' when ocupacion > 0 else '0';

end Behavioral;
