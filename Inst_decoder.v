module Inst_decoder(inst, zero, InstM_R, M3, M4, ALUCtrl, M2, RF_W, M5, M1,
						  DataM_CS, DataM_R, DataM_W, M6, signed16);

//指令輸入
input [31:0]inst;
//zero要跟branch_sel做and
input zero;
//Instruction Memory Read				
output InstM_R;
output M1;
output M2;
output M3;
output M4;
output M5;
output M6;
output [2:0] ALUCtrl;
output RF_W;
output DataM_CS;
output DataM_R;
output DataM_W;
output signed16;

// opcode
wire [5:0] op = inst[31:26];
// functional code
wire [5:0] func = inst[5:0];

// R_format opcode全為0
assign R_format = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
// addu R_format & func 100001
assign addu = R_format & (func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & func[0]);
// subu R_format & func 100011
assign subu = R_format & (func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & func[0]);
// sll  R_format & func 000000
assign sll = R_format & (~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0]);
// ori opcode 001101
assign ori = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & op[0];
// lw  opcode 100011
assign lw = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
// sw  opcode 101011
assign sw = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
// beq opcode 000100
assign beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
// j   opcode 000010
assign j = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];

// register write
assign RF_W = addu | subu | sll | ori | sw;
// instruction memory read
assign InstM_R = 1'b1;
// Data Memory Chip Select DM_CS 信號有效 data memory可以進行讀寫操作
assign DataM_CS = lw | sw;
// Data Memory read
assign DataM_R = lw;
// Data Memory write
assign DataM_W = sw;

// ALU control
assign ALUCtrl[2] = 0;	
assign ALUCtrl[1] = ori | sll;		
assign ALUCtrl[0] = subu | sll | beq;		

// Mux control
// M1 Jump
assign M1 = addu | subu | ori | sll | beq | lw | sw;
// M2 MemtoReg
assign M2 = addu | subu | ori | sll | beq | j | sw;
// M3 sll
assign M3 = addu | subu | ori | beq | lw | sw;
// M4 unsignedextention
assign M4 = lw | sw | ori;
// M5 branch
assign M5 = zero & beq;
// M6 RegDst
assign M6 = ori | lw;	

assign signed16 = lw | sw;

endmodule
