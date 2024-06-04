module q_sel #(
    parameter WIDTH = 8
) (
    rem     ,
    d       ,
    q       ,
    neg
);
input[5:0]   rem;
input[3:0]   d;
output[1:0]  q;
output       neg;

wire    table_8,table_9,table_10,table_11,table_12,table_13,table_14,table_15;

assign table_8  = d==4'b1000;
assign table_9  = d==4'b1001;
assign table_10 = d==4'b1010;
assign table_11 = d==4'b1011;
assign table_12 = d==4'b1100;
assign table_13 = d==4'b1101;
assign table_14 = d==4'b1110;
assign table_15 = d==4'b1111;
wire   q2       ;
wire   q0       ;

assign neg = 
            table_8 &&(rem>=6'b110100&&rem<6'b111110)
            ||table_9 &&(rem>=6'b110010&&rem<6'b111101)
            ||table_10&&(rem>=6'b110001&&rem<6'b111101)
            ||table_11&&(rem>=6'b110000&&rem<6'b111101)
            ||table_12&&(rem>=6'b101110&&rem<6'b111100)
            ||table_13&&(rem>=6'b101101&&rem<6'b111100)
            ||table_14&&(rem>=6'b101100&&rem<6'b111100)
            ||table_15&&(rem>=6'b101010&&rem<6'b111100);
assign q2 = 
            table_8 &&((rem>=6'b110100&&rem<6'b111010)||(rem>=6'b000110&&rem<=6'b001011))
            ||table_9 &&((rem>=6'b110010&&rem<6'b111001)||(rem>=6'b000111&&rem<=6'b001101))
            ||table_10&&((rem>=6'b110001&&rem<6'b111000)||(rem>=6'b001000&&rem<=6'b001110))
            ||table_11&&((rem>=6'b110000&&rem<6'b110111)||(rem>=6'b001000&&rem<=6'b001111))
            ||table_12&&((rem>=6'b101110&&rem<6'b110110)||(rem>=6'b001001&&rem<=6'b010001))
            ||table_13&&((rem>=6'b101101&&rem<6'b110110)||(rem>=6'b001010&&rem<=6'b010010))
            ||table_14&&((rem>=6'b101100&&rem<6'b110101)||(rem>=6'b001010&&rem<=6'b010011))
            ||table_15&&((rem>=6'b101010&&rem<6'b110100)||(rem>=6'b001011&&rem<=6'b010101));
assign q0 = 
            table_8 &&((rem>=6'b111110&&rem<=6'b111111)||  (rem>=0&&rem<6'b000010))
            ||table_9 &&((rem>=6'b111101&&rem<=6'b111111)||(rem>=0&&rem<6'b000010))
            ||table_10&&((rem>=6'b111101&&rem<=6'b111111)||(rem>=0&&rem<6'b000010))
            ||table_11&&((rem>=6'b111101&&rem<=6'b111111)||(rem>=0&&rem<6'b000010))
            ||table_12&&((rem>=6'b111100&&rem<=6'b111111)||(rem>=0&&rem<6'b000011))
            ||table_13&&((rem>=6'b111100&&rem<=6'b111111)||(rem>=0&&rem<6'b000011))
            ||table_14&&((rem>=6'b111100&&rem<=6'b111111)||(rem>=0&&rem<6'b000011))
            ||table_15&&((rem>=6'b111100&&rem<=6'b111111)||(rem>=0&&rem<6'b000100));
assign q =   q2 ? 2'b10 
            :q0 ? 2'b00
            :2'b01;
endmodule