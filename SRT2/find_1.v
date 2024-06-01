module find_1#
(
    parameter WID=8
)
(
    d_i     ,
    pos_o   
);
input   [WID-1:0]    d_i;
output  reg[WID-1:0]     pos_o;

wire [WID-1:0] pos_oh;

reg [WID-1:0] op_t;//one hot
integer i;
always @(*) begin
	for(i=0; i<WID; i=i+1) begin
		if(d_i[WID-1]==1'b0) begin
			op_t[i] <= d_i[WID-1-i];
		end 
        else begin
			op_t[i] <= ~d_i[WID-1-i];
		end
	end
end

assign pos_oh = op_t & (~op_t+1);	// ripple carry

integer j;
always @(*) begin
	for(j=0; j<WID; j=j+1) begin
		if(pos_oh[j]==1) begin
			pos_o <= j-1;
		end
	end
end
endmodule