library ieee;
use ieee.std_logic_1164.all;

entity hangman is

port(
	SW: in std_logic_vector(3 downto 0);
	LEDG: out std_logic_vector(13 downto 0):="00000000000000";
	CLOCK_50: in std_logic
			
);

end hangman;

--
architecture behavioral of hangman is


-- Definindo estados de vidas e estados de resultado final
type state_type is 
(
three_lives,
two_lives,
one_life,
win,
lost
);

signal pr_state, nx_state: state_type;
signal clk,enable: std_logic;
signal  rst,got_0,got_1,got_2,got_3,got_4,got_5,got_6,got_7,a,b: std_logic := '0';
signal value: std_logic_vector(2 downto 0);

Component lcd IS
     Port ( LCD_DB: out std_logic_vector(7 downto 0);	
           RS:out std_logic;  				--WE
           RW:out std_logic;				--ADR(0)
	   CLK:in std_logic;				--GCLK2
	    OE:out std_logic;				--OE
	   rsti,got_0i,got_1i,got_5i,got_6i,got_7i,wi,li:in std_logic := '0');	--BTN

End component; 
begin
	enable <= SW(3);
	clk <= CLOCK_50;
	process(clk,enable, rst,got_7,got_6,got_5,got_1,got_0)
	begin
	
	-- estrutura if/else para definir estado atual com base nas variáveis de status de cada número inserido (got_N)
		if (rst = '1') then
			got_0 <= '0';
			got_1 <= '0';
			got_2 <= '0';
			got_3 <= '0';
			got_4 <= '0';
			got_5 <= '0';
			got_6 <= '0';
			got_7 <= '0';
			a <= '0';
			b <= '0';
	    	pr_state <= three_lives;
		elsif(got_7 = '1' and got_6 = '1' and got_5= '1' and got_1= '1'  and got_0 = '1') then
			 pr_state <= win;
		elsif(clk'EVENT and clk = '1') then
          if(enable = '1' and rst ='0') then 
            value <= SW(2 downto 0);
          
          
          -- switch case pra atualizar variáveis de status de cada número inserido (got_N)
    	    case value is
    			when "000" =>
    			    got_0 <= '1';
    			when "001" =>
    			    got_1 <= '1';  		        
    			when "010" =>
    			    if (got_2 = '0') then
    			        pr_state <= nx_state;
    			    end if;
    			    got_2 <= '1';
    		      
    			when "011" => 
    			    if (got_3 = '0') then
    			        pr_state <= nx_state;
    			    end if;
    			    got_3 <= '1';
    		
    			when "100" =>
    			    if (got_4 = '0') then
    			        pr_state <= nx_state;
    			    end if;
    			    got_4 <= '1';

    		    when "101" =>
    			    got_5 <= '1';
    			when "110" =>
    			   got_6 <= '1';
    			when others =>
    			    got_7 <= '1';
    		    end case; 
    	end if;	 
		end if;
	end process;
	
	
	-- process que avalia os próximos estados/resultados a partir do estado atual 
	process(pr_state)
	begin
        case pr_state is
    			when three_lives =>
    			        rst <= '0';
    			        LEDG(2 downto 0) <= "111";
    		            nx_state <= two_lives;
    			when two_lives =>
    			       	  LEDG(2 downto 0) <= "011";
    			        nx_state <= one_life;
    			when one_life =>
    			       	  LEDG(2 downto 0) <= "001";
    			        nx_state <= lost;
    			when win => 
    			    a<='1';
            		 if(enable = '0') then 
            				    rst <= '1';
    				end if;
    			when lost =>
    		    	  LEDG(2 downto 0) <= "000";
    		    	  b<='1';
    		        if(enable = '0') then 
    				    rst <= '1';
    				end if;
    		end case;
	end process;
	
	-- Define-se um componente LCD para printar variáveis já selecionadas/resultado final
 l0: lcd port map(LEDG(10 downto 3),LEDG(11),LEDG(12),clk,LEDG(13),rst,got_0,got_1,got_5,got_6,got_7,'0','1');

end behavioral;
