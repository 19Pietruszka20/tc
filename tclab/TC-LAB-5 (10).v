/* Autorzy : Adam Jagielski, Michał Siedlaczek */
/* Grupa : 2 */

module RS232(clk,rx,tx,SW0,SW1,SW2,SW3,LED1,LED1,LED2,LED3,LED4,LED5,LED6,LED7,LED8);  

/* inputs list*/  
input wire clk;   
input wire rx;  
input wire SW0;
input wire SW1;
input wire SW2;
input wire SW3;
/*outputs list*/  
output reg tx;
output reg LED1; 
output reg LED2; 
output reg LED3; 
output reg LED4; 
output reg LED5; 
output reg LED6; 
output reg LED7; 
output reg LED8;  
/*internal parameters*/  
reg tx_reg;  
reg[7:0] LED=0;
reg [80:0] encryption_key= 8'b10100100; 
reg [7:0]data; 
integer bit_counter=1;//zmienna licząca bity transmisji;
integer tact_counter=0;//zmienna licząca takty zegara;
reg tact=0;//zmienna umożliwiająca zmianę stanu transmisji; 
reg trasmission_release=0;//zmienna zezwalająca na transmisję; 
reg ekim=0;//encryption key input mode
reg cifer_counter=0;//dzielnik częstotliwości trybu wprowadzania cyfr
reg cifer_number=0;//licznik wprowadzonej cyfry
reg encryption_request=0;//żądanie zaszyfrowania danych
integer len=80;//długość żądanego klucza
reg led_assign_request=0;//żądanie zmiany statusu diód LED
reg[7:0] j;
reg[7:0] i;
reg [7:0] t;
reg [80:0] T=0;//wektor początkowy algorytmu RC4
reg RC4_flag1=0;
reg encryption_key_temp;

	
always@ (posedge clk) 
begin  
/* umożliwienie zmiany klucza przez wciśnięcie przycisku*/
/*!!!przed odkomentowaniem należy zmienić wielkość klucza szyfrującego i wywołanie algorytmu szyfrującego!!!*/
/*if(SW1==1) begin
encryption_key<=8'b10010011;
end
if(SW2==1) begin
encryption_key<=8'b11001100;
end
if(SW3==1) begin
encryption_key<=8'b10100100;
end*/
/*uwzględnienie baud-rate transmisji na poziomie 9600bps*/ 
/*zmiana stanu transmisji przy zegarze 50MHz następuje co ok. 104160 ns*/ 
/* transmisja 1 bit START o stanie niskim, 8 bitów danych, 2 bity stop o stanie wysokim */
if (tact_counter<5208)  
begin
	tact_counter<=tact_counter+1; 
end
if (tact_counter==5208) 
begin 
	tact_counter<=0;
	tact<=1;
end 
 
if(bit_counter==1&&tact==1)//odbiór bitu start 
begin 
	bit_counter<=bit_counter+1; 
	tact<=0;
	tact_counter<=2604;	
end 
if (bit_counter>=2&&bit_counter<=9&&tact==1)//odbiór danych i zapisanie do rejestru 
begin 
	data[bit_counter-2] <=rx; 
	bit_counter<=bit_counter+1;
	tact<=0; 
end 
if(bit_counter==10&&tact==1)//odbiór bitu stop 
begin 
	bit_counter<=bit_counter+1; 
	tact<=0; 
end 
if (bit_counter==11&&tact==1)//implementacja szyfrującego algorytmu szyfr Vigenere'a na bramce XOR 
begin 
	//data<=data^encryption_key; 
	encryption_request<=1;
	bit_counter<=bit_counter+1;
	tact<=0; 
	tact_counter<=-2604;
end 
if (bit_counter==12&&tact==1)//nadawnie bitu start
begin 
	tx_reg <= 1'b0; 
	bit_counter<=bit_counter+1 ; 
	trasmission_release<=1; 
	tact<=0; 
	
end 
if (bit_counter>=13 && bit_counter<=20&&tact==1)//nadawanie bitów danych 
begin 
	tx_reg <= data [bit_counter-13];  
	bit_counter<=bit_counter+1; 
	trasmission_release<=1; 
	tact<=0; 
end 
if(bit_counter>=21&&bit_counter<=22&&tact==1)  //nadawanie 2 bitów stopu 
begin 
	tx_reg <= 1'b1; 
	bit_counter<=bit_counter+1;
	trasmission_release<=1; 
	tact<=0; 
end 
if(bit_counter==23&&tact==1)//rozpoczęcie procedury odbioru/nadawania od początku; otrzymanie bitu start 
begin 
	bit_counter<=2;  
	tact<=0;
end 
if(trasmission_release==1) 
begin 
	tx<=tx_reg;//output 
	trasmission_release<=0; 
end 
//To begin encryption Key Input Procedure you have to click 4 button for once
if(SW0==1&&SW1==1&&SW2==1&&SW3==1)
begin
ekim<=1;
cifer_counter<=0;
cifer_number<=0;
end

//encryption procedure RC4 Alghorytm
//entering key
if(led_assign_request==1)
begin
 LED1<=LED[0];
 LED2<=LED[1];
 LED3<=LED[2];
 LED4<=LED[3];
 LED5<=LED[4];
 LED6<=LED[5];
 LED7<=LED[6];
 LED8<=LED[7];
led_assign_request<=0;
end
if(ekim==1)
begin
cifer_counter<=cifer_counter+1;
if(cifer_counter==1000)
begin
encryption_key[cifer_number]<=SW0;
encryption_key[cifer_number+1]<=SW1;
encryption_key[cifer_number+2]<=SW2;
encryption_key[cifer_number+3]<=SW3;
cifer_number<=cifer_number+4;
LED<=cifer_number/4;
led_assign_request<=1;
if(cifer_number==76)
begin
ekim<=0;
end
end
end
if(encryption_request==1)
begin
RC4_flag1<=1;
encryption_request<=0;
end
if(RC4_flag1==1)
begin
i <= (i + 1); 
j <= (j + encryption_key[i]); 
encryption_key_temp<=encryption_key[i];
encryption_key[i]<=encryption_key_temp^encryption_key[j];
t <= (encryption_key[i] + encryption_key[j]); 
encryption_key[i]<= encryption_key[t];
i<=i+1;
	if(i==80)
	begin
	RC4_flag1=0;
	data<=data^encryption_key;
	end
end
end
endmodule
	
	/* UCF z dokumentacji płytki
	NET "clk" LOC = "E12"| IOSTANDARD = LVCMOS33 ;
	NET "rx" LOC = "E16" | IOSTANDARD = LVTTL ;
	NET "tx" LOC = "F15" | IOSTANDARD = LVTTL | DRIVE = 4 | SLEW = SLOW ;
	NET "SW0" LOC = "V8" | IOSTANDARD = LVTTL | PULLUP ;
	NET "SW1" LOC = "U10"| IOSTANDARD = LVTTL | PULLUP ;
	NET "SW2" LOC = "U8" | IOSTANDARD = LVTTL | PULLUP ;
	NET "SW3" LOC = "T9" | IOSTANDARD = LVTTL | PULLUP ;
	NET "LED8" LOC = "W21" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED7" LOC = "Y22" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED6" LOC = "V20" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED5" LOC = "V19" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED4" LOC = "U19" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED3" LOC = "U20" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED2" LOC = "T19" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	NET "LED1" LOC = "R20" | IOSTANDARD = LVTTL | SLEW = QUIETIO | DRIVE = 4 ;
	*/