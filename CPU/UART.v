/* //1 start + 8 data + 1 stop + null


// clock é 125 MHZ 

module UART(rx, tx);
    input tx, rx;
    reg [10:0] data;
    
   ///111111111111111111111111111111111111 idle
    // a cada 0,000008681 manda um bit 
    //115,200, 9600, 
    // OLA 4F 4C 4A ->    idle ,bit start = 0   01001100 bit stop = 1, idle
    


endmodule
*/