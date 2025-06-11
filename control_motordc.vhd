library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_motordc is
    Port (
        clk         : in  std_logic;
        start       : in  std_logic;
        destino     : in  std_logic_vector(2 downto 0);
        piso_actual : in  std_logic_vector(2 downto 0);
        subiendo    : out std_logic;
        bajando     : out std_logic;
		  pwm_control : out std_logic;
        finalizado  : out std_logic
    );
end control_motordc;

architecture behavioral of control_motordc is

    type state_type is (inactivo, moviendo_up, moviendo_down, done);
    signal current_state : state_type := inactivo;
    signal next_state    : state_type;

    signal dest_int, piso_int : integer range 0 to 7;
	 signal pwm_counter : integer range 0 to 999 := 0;
    signal pwm_out : std_logic := '0';
    signal duty_cycle : integer range 0 to 999 := 5 ; 

begin
	 -- Generador PWM
    PWM_Process : process(clk)
    begin
      if rising_edge(clk) then
       if pwm_counter = 999 then
        pwm_counter <= 0;
      else
       pwm_counter <= pwm_counter + 1;
      end if;

      if pwm_counter < duty_cycle then
       pwm_out <= '1';
      else
        pwm_out <= '0';
      end if;
     end if;
end process;

    -- Conversión de entrada (fuera de FSM para claridad)
    process(destino, piso_actual)
    begin
        dest_int  <= to_integer(unsigned(destino));
        piso_int  <= to_integer(unsigned(piso_actual));
    end process;

    -- Registro de estado (secuencial)
   memory_process : process(clk)
    begin
        if rising_edge(clk) then
        if start = '1' then
            current_state <= next_state;
        else
            current_state <= inactivo;
        end if;
        end if;
    end process;

-- Lógica de transición de estados (combinacional)
   next_state_logic: process(current_state, start, dest_int, piso_int)
    begin
    case current_state is
        when inactivo =>
            if start = '1' then
                if dest_int = piso_int then
                    next_state <= done;
                elsif dest_int > piso_int then
                    next_state <= moviendo_up;
                elsif dest_int < piso_int then
                    next_state <= moviendo_down;
                end if;
				else 
				  next_state<=inactivo;
            end if;

        when moviendo_up =>
		   if start='1' then 
            if dest_int = piso_int then
                next_state <= done;
            elsif dest_int > piso_int then
                next_state <= moviendo_up;
				else 
				   next_state<=inactivo; -- en caso de que se genere una confusion, se inactivara 
            end if;
			else 
			  next_state<=inactivo;
			  end if;

        when moviendo_down =>
		  if start='1' then
            if dest_int = piso_int then
                next_state <= done;
            elsif dest_int < piso_int then
                next_state <= moviendo_down;
				else
				   next_state<=inactivo;
            end if;
			else 
			next_state<=inactivo;
			end if;

        when done =>
    if start = '0' then
        next_state <= inactivo;
    else 
        next_state <= done;  -- permanece en done hasta que start baje
    end if;


        when others =>
            next_state <= inactivo;

    end case;
end process;


    -- Salidas tipo Moore (basadas solo en estado actual)
   output_logic: process(current_state)
    begin
        subiendo   <= '0';
        bajando    <= '0';
        finalizado <= '0';
		  pwm_control <= '0';

        case current_state is
            when moviendo_up =>
                subiendo <= '1';
					  pwm_control <= '1';
            when moviendo_down =>
                bajando <= '1';
					  pwm_control <= '0';
            when done =>
                finalizado <= '1';
            when others =>
                null;
        end case;
    end process;

end architecture;


