library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ascensorfsm1 is 
    port(
        clkp, anomalia, no_personas : in std_logic;
        up_button, down_button      : in std_logic_vector(3 downto 0);
        sensor                      : in std_logic_vector(4 downto 0);
        destino                     : in std_logic_vector(2 downto 0);
        open_door, close_door       : in std_logic;
        motor_up, motor_down, opened_door, closed_door, alarma, led, pwm_puerta, pwm_ascensor: out std_logic;
        bcd                         : out std_logic_vector(6 downto 0)
    );
end entity;

architecture arch of ascensorfsm1 is 
    type state is (idle, moving, doors, atending, emergency);
    signal current_state, next_state : state;
	 signal prev_state : state;
	 
   --SEÑALES USADAS PARA TRABAJAR ENTRE MODULOS
    signal nopiso         : std_logic_vector(2 downto 0);
    signal sensor_signal  : std_logic_vector(2 downto 0);
    signal start_puertas  : std_logic;
    signal end_puertas    : std_logic;
	 signal piso_actual : std_logic_vector(2 downto 0) := "000";
	 signal start_motor : std_logic;
	 signal end_motor : std_logic;
	 signal start_motor1 : std_logic;
	 signal end_motor1 : std_logic;
	 signal motor_up_0, motor_up_1   : std_logic;
    signal motor_down_0, motor_down_1 : std_logic;
	 signal pwm_ascensor0, pwm_ascensor1 : std_logic;
	 signal opened_door_signal, closed_door_signal : std_logic;
	 

	 

	 
    -- Componente decodificador
    component decobtn2piso is
        port (
            clk       : in  std_logic;
            btn_up    : in  std_logic_vector(3 downto 0);
            btn_down  : in  std_logic_vector(3 downto 0);
            no_piso   : out std_logic_vector(2 downto 0)
        );
    end component;

    component DECOSEN2BIN is
        port (
            entrada : in  std_logic_vector(4 downto 0);
            salida  : out std_logic_vector(2 downto 0)
        );
    end component;
begin 

    -- Instancia 1
    U1 : decobtn2piso
        port map (
            clk      => clkp,
            btn_up   => up_button,
            btn_down => down_button,
            no_piso  => nopiso --indica en que piso esta el usuario, btn_up tiene prioridad 
        );

    -- Instancia 2
    U2 : DECOSEN2BIN
        port map (
            entrada => sensor,
            salida  => sensor_signal --indica en que piso esta el ascensor
        );

    -- FSM de puertas
    puertas: entity work.fsm_puerta
        port map(
            clk            => clkp,
            start          => start_puertas, -- inidca que el proceso de abrir y cerrar puertas ha iniciado
            open_btn       => open_door, --botones conectados directamente a la fsm
            close_btn      => close_door,
            puerta_abierta => open,      
            puerta_cerrada => open, 
		      pwm_control    => pwm_puerta,	
            alarma_out     => opened_door_signal, --proceso de apertura de la puerta (3 segundos)
            alarma_out1    => closed_door_signal, --proceso de cierre de la puerta (3 segundos)
            end_process    => end_puertas -- indica la finalizacion de la apertura y cierre de las puertas 
        );
	 motor : entity work.control_motordc
	 port map(
	     clk         => clkp,
        start       => start_motor, --indica la activacion de los motores
        destino     => destino, --valor de 3 bits ingresado por usuario desde cabina
        piso_actual => sensor_signal, --el sensor siempre indicara en que piso esta, es la referencia
        subiendo    => motor_up_0, --indica al motor que suba
        bajando     =>motor_down_0, --indica al motor que baje
		  pwm_control =>pwm_ascensor0, --control pwm de la señal del motor, evita gire demasiado rapido
        finalizado  =>end_motor --indica que los motores se desactivan
	 );
	 
	 --esta instanciacion es basicamente igual a la de arriba, pero con destino el numero de piso en que esta el usuario (nopiso)
	 
	 	 motor1 : entity work.control_motordc
	 port map(
	     clk         => clkp,
        start       => start_motor1, 
        destino     => nopiso,
        piso_actual => sensor_signal,
        subiendo    => motor_up_1,
        bajando     =>motor_down_1,
		  pwm_control =>pwm_ascensor1,
        finalizado  =>end_motor1
	 );


    -- Proceso de memoria de estado
    memory: process(clkp, anomalia, no_personas)
    begin
        if (anomalia = '1' or no_personas = '1') then --si hay anomalia o escede numero de personas, se inactiva el ascensor
            current_state <= emergency;
        elsif rising_edge(clkp) then --en caso de que no sea asi, se aactualiza el estado normalmente
		      prev_state<=current_state; --señal necesaria para verificar de que estado se viene 
            current_state <= next_state;
        end if;
    end process;

    -- Lógica de transición de estados
 next_state_logic : process(current_state, nopiso, sensor_signal, end_puertas, destino, anomalia, no_personas, prev_state)
begin
    start_puertas <= '0'; --asegura que la fsm de las puertas este inactiva
    start_motor <='0';--motores inicialmente desactivados
    case current_state is
        ------------------------------------------------------------------------
        when emergency =>
            if (no_personas = '0' and anomalia = '0') then
                next_state <= prev_state; --una vez pase la anomalia, se regresa al estado en el que estaba 
            else
                next_state <= emergency; 
            end if;

        ------------------------------------------------------------------------
        when idle =>
            if (no_personas = '1' or anomalia = '1') then
                next_state <= emergency;

            elsif (nopiso /= "000" or destino /="000") then
                 if (nopiso = sensor_signal) then
                    next_state <= doors;
                 else
                    next_state <= moving;
                 end if;
				else 
				next_state<=idle;
            end if;

        ------------------------------------------------------------------------
  when moving =>
    if (no_personas = '1' or anomalia = '1') then
        next_state <= emergency;
        start_motor <= '0';
        start_motor1 <= '0';

    elsif (destino /= "000") then
        start_motor <= '1';
        if end_motor = '1' then
            next_state <= doors;
            start_motor <= '0';
        else
            next_state <= moving;
        end if;

    elsif (nopiso /= "000") then
        start_motor1 <= '1';
        if end_motor1 = '1' then
            next_state <= doors;
            start_motor1 <= '0';
        else
            next_state <= moving;
        end if;

    else
        next_state <= idle;
        start_motor <= '0';
        start_motor1 <= '0';
    end if;

	   
        ------------------------------------------------------------------------
        when doors =>
          if (anomalia='1' or no_personas='1') then
			  next_state<=emergency;
			  start_puertas<='0';
			 else 
			   start_puertas<='1'; 
			  if (end_puertas = '1') then
                next_state <= atending;  -- ir a ingresar destino si se acaba de abrir/cerrar
                start_puertas <= '0';
				else 
				 next_state<=doors;
            end if;
			end if;

        ------------------------------------------------------------------------
        when atending =>
            if (no_personas = '1' or anomalia = '1') then
                next_state <= emergency;
					 
            elsif (destino = "000") then
                next_state <= idle;

            elsif (destino /= "000" or nopiso/="000") then
                next_state <= moving;
            else
                next_state <= idle;
            end if;

        ------------------------------------------------------------------------
        when others =>
            next_state <= idle;
    end case;
end process;



    -- ==LOGICA DE SALIDA TIPO MEALLY==
    output_logic : process(current_state, up_button, down_button, sensor_signal, destino)
    begin
        case current_state is
		 
			
			
        
            when idle =>
                if (up_button /= "0000" or down_button /= "0000") then
                    led <= '1';
                else
                    led <= '0';
                end if;
				  motor_up <='0';
			     motor_down <='0';
				  opened_door <='0';
			     closed_door <='0';
				  alarma <='0';
			     

            when moving =>
                if (destino/="000") then
					 motor_up <=motor_up_0;
					 motor_down<=motor_down_0;
					 pwm_ascensor<=pwm_ascensor0;
					 elsif (nopiso/="000") then
					 motor_up<=motor_up_1;
					 motor_down<=motor_down_1;
					 pwm_ascensor<=pwm_ascensor1;
					 else 
					 motor_down<='0';
					 motor_up<='0';
					 end if; 
					 led<='1';
					 opened_door <='0';
			       closed_door <='0';
					 alarma <='0';
			       
					 
            when atending =>
                motor_up   <= '0';
                motor_down <= '0';
                alarma     <= '1';
                led        <= '1';
					 opened_door <='0';
			       closed_door <='0';
					 

            when doors =>
                opened_door<=opened_door_signal;
					 closed_door<=closed_door_signal;
                led        <= '1';
					 motor_up   <= '0';
                motor_down <= '0';
					 alarma <='0';
			       led <='0';

            when emergency =>
                motor_up   <= '0';
                motor_down <= '0';
                alarma     <= '1';
                led        <= '1';
					 opened_door <='0';
			       closed_door <='0';

            when others =>
                motor_up   <= '0';
                motor_down <= '0';
                alarma     <= '0';
                led        <= '0';
					 opened_door <='0';
			       closed_door <='0';
        end case;
    end process;

end architecture;


