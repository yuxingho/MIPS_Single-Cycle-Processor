module MUX_6(A, B, Sel, S);
input [5:0] A, B;
input Sel;
output [5:0] S;
//選擇 Register destination 是 rd還是rt
assign S = (Sel == 1'b0) ? A : B;

endmodule
