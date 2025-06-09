library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_puerta is
    port (
        clk            : in  std_logic;
        start          : in  std_logic;
        open_btn       : in  std_logic;
        close_btn      : in  std_logic;
        puerta_abierta : out std_logic;
        puerta_cerrada : out std_logic;
		  pwm_control    : out std_logic;
        alarma_out     : out std_logic; --señal de abrir 
		  alarma_out1    : out std_logic; --señal de cerrar
		  end_process    : out std_logic
    );
end entity;

architecture behavioral of fsm_puerta is

    type state_type is (inactiva, esperando_abrir, abriendo, esperando_cerrar, cerrando);
    signal current_state : state_type:=inactiva;
	 signal next_state : state_type;

    -- Señales internas para temporizadores
    signal cuenta10           : std_logic_vector(3 downto 0);
    signal cuenta45           : std_logic_vector(5 downto 0);
    signal alarma10, alarma45 : std_logic;
    signal abriendo_mod10     : std_logic;  -- salida abriendo del MOD10
    signal cerrandofsm : std_logic;
	 signal enabletimer : std_logic :='0';
	 signal alarmatimer : std_logic;
	 signal enablemod10 : std_logic:='0';
	 signal enablemod45 : std_logic:='0';
	 signal enabletimer1: std_logic:='0';
	 signal alarmatimer1: std_logic:='0';
	 signal pwm_counter : integer range 0 to 999 := 0;
    signal pwm_out : std_logic := '0';
    signal duty_cycle : integer range 0 to 999 := 5 ; 

begin

    -- ====== Instancia MOD10 ======
    temporizador_abrir : entity work.MOD10
        port map (
            clk      => clk,
            enable   => enablemod10,
            abrir    => '0',
            cuenta   => cuenta10,
            alarma   => alarma10, 
            abriendo => abriendo_mod10
        );
   
    -- ====== Instancia MOD45 ======
    temporizador_cerrar : entity work.MOD45
        port map (
            clk        => clk,
            abriendoIn  => enablemod45,  -- Habilitado cuando MOD10 está activo
            cerrar     => '0',
            cuenta     => cuenta45,
				cerrando  => cerrandofsm,
            alarma     => alarma45
				     
        );
		  
	 timer_opening : entity work.timerpuertas
	 port map (
	 clk => clk,
	 rst => '0', -- usar si quiero reiniciar la cuenta de las puertas 
	 enable => enabletimer,
	 alarma => alarmatimer
	 
	 );
	 timer_closing : entity work.timerpuertas
	 port map (
	 clk => clk,
	 rst => '0', -- usar si quiero reiniciar la cuenta de las puertas 
	 enable => enabletimer1,
	 alarma => alarmatimer1
	 
	 );
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

    -- ====== Memory Process ======
    memory : process(clk)
    begin
    if rising_edge(clk) then
        if start = '1' then
            current_state <= next_state;
        else
            current_state <= inactiva;
        end if;
    end if;
end process;

    -- ====== Next State Logic ======
next_state_logic : process(current_state, start, open_btn, close_btn, alarma10, alarma45, alarmatimer, alarmatimer1)

begin

    case current_state is

        when inactiva =>		
            if start = '1' then
              if (open_btn='0') then 
				  next_state <= esperando_abrir;
				  elsif open_btn='1' then
				    next_state <=abriendo;
				  else 
				    next_state <=inactiva;
				  end if;
				else 
				 next_state<=inactiva;
				end if;

when esperando_abrir =>
    enablemod10 <= '1';  -- habilita temporizador MOD10

    if start = '1' then  -- solo opera si start sigue activo
        if (open_btn = '1') or (alarma10 = '1') then
            next_state <= abriendo;
            enablemod10 <= '0';  -- deshabilita temporizador al avanzar
        else
            next_state <= esperando_abrir;
        end if;
    else
        next_state <= inactiva;  -- si se desactiva start, vuelve a inactiva
        enablemod10 <= '0';
    end if;

				
  when abriendo =>
     enabletimer <= '1';  -- se empieza a abrir la puerta 
    if start ='1' then
        if close_btn = '1' then
            next_state <= cerrando; 
				enabletimer<='0'; -- se deja de abrir la puerta
        elsif alarmatimer = '1' then --si se termina de abrir la puerta 
            next_state <= esperando_cerrar; -- tiempo de apertura cumplido
            enabletimer<='0';
		  else
            next_state <= abriendo;  -- se mantiene abriendo hasta que pase el tiempo
        end if;
	 else 
        next_state <= inactiva;
		  enabletimer <='0';
    end if;



    when esperando_cerrar =>
	   enablemod45<='1';
		if start='1' then
        if (close_btn = '1') or (alarma45 = '1') then
            next_state <= cerrando;
				enablemod45<='0';	
		  else 
		      next_state<=esperando_cerrar;
        end if;
      else 
        next_state <= inactiva;
		  enablemod45<='0';  
      end if;


when cerrando =>
    enabletimer1 <= '1'; -- se empieza a cerrar la puerta
    
    if start ='1' then
        if open_btn = '1' then
            next_state <= abriendo; -- se interrumpe el cierre
            enabletimer1 <= '0';
        elsif alarmatimer1 = '1' then
            next_state <= inactiva; -- cierre finalizado
            enabletimer1 <= '0';
        else
            next_state <= cerrando; -- se mantiene cerrando
            -- enabletimer1 se mantiene en '1'
        end if;
	 else
        next_state <= inactiva;
        enabletimer1 <= '0'; -- detener el temporizador
    end if;


    end case;
end process;



  -- ====== Output Logic tipo Moore ======
output_logic : process(current_state)
begin
    -- Valores por defecto (más explícito)
    puerta_abierta <= '0';
    puerta_cerrada <= '0';
    alarma_out     <= '0';
	 alarma_out1   <= '0';
	 end_process <='0';
    



    case current_state is
        when inactiva =>
            puerta_abierta <= '0';
            puerta_cerrada <= '1';
            alarma_out     <= '0';
				alarma_out1<='0';
				end_process<='0';
				 pwm_control <= '0';

        when esperando_abrir =>
            puerta_abierta <= '0';
            puerta_cerrada <= '1';
            alarma_out     <= '0';
				alarma_out1 <='0';
				end_process<='0';
				 pwm_control <= '0';

        when abriendo =>
            puerta_abierta <= '1';
            puerta_cerrada <= '0';
            alarma_out     <= '1';
				alarma_out1 <='0';
				end_process<='0';
             pwm_control <= pwm_out;
         
            
         
        when esperando_cerrar =>
            puerta_abierta <= '1';
            puerta_cerrada <= '0';
            alarma_out     <= '0';
				alarma_out1 <='0';
				end_process<='0';
				 pwm_control <= '0';
				

        when cerrando =>
            puerta_abierta <= '0';
            puerta_cerrada <= '1';
            alarma_out     <= '0';
				alarma_out1 <='1';
				 pwm_control <= pwm_out;
				if (alarmatimer1='1') then
				end_process<='1';
				else 
				end_process<='0';
				end if;
				

        when others =>
            puerta_abierta <= '0';
            puerta_cerrada <= '1';
            alarma_out     <= '0';
				 pwm_control <= '0';
				
    end case;
end process;
end architecture;