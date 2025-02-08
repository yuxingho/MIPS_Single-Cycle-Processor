module MIPS_Singlecycle(clk, reset, ALUResult, Read_Data1, Read_Data2, Address_in_PC, Address_out_PC, Address_Add_PC, Inst, Read_Data_Mem, Jump_addr);
input clk, reset;
//ALU運算後的結果
output [31:0] ALUResult;
//暫存器讀出來的rs和rt
output [31:0] Read_Data1;
output [31:0] Read_Data2;
//PC暫存器in 和 out
output [31:0] Address_in_PC;
output [31:0] Address_out_PC;
//PC+4的結果
output [31:0] Address_Add_PC;
//Instruction memory讀出來的指令
output [31:0] Inst;
//Data memory讀出來的data
output [31:0] Read_Data_Mem;
//指令Jump_addr後的結果
output [31:0] Jump_addr;

wire [4:0]WriteReg;
//選擇rt or rd
wire RegDst;
//選擇 bus2或是sign-extentsion後的immediate
wire ALUSrc;
//選擇data memory讀出來的資料寫回register(lw) 或是 ALU的運算結果寫回register(r-format)
wire MemtoReg;
//控制register能不能寫入
wire RegWrite;
//控制data memory能不能讀出data
wire MemRead;
//控制data memory能不能寫入data
wire MemWrite;
//branch會和zero and後控制地址要不要跳
wire Branch;
//大哥控制小弟(Controller控制ALUCtrl)
wire [1:0] ALUop;
//控制要不要jump
wire jump;
//Zero
wire Zero;
//控制要不要branch
wire BranchZero;
//ALUResult 和 Read_Data_Mem MUX過後的結果
wire [31:0] WriteData;
//Sign extentsion過後的結果
wire [31:0] Sign_ext;
//左移兩位的結果
wire [31:0] Sign_out;
//Branch_Addr = pc+4 + sign_out
wire [31:0] Branch_Addr;
//選擇完branch address 或 pc+4後的結果
wire [31:0] Branch_PC4;
//ALU control 來控制 ALU的
wire [3:0] ALUctr;
//選擇完Read_Data2還是sign extentsion的結果
wire [31:0] ALUin;

//PC暫存器
PC PC1(.clk(clk), .reset(reset), .addr_in(Address_in_PC), .addr_out(Address_out_PC));
//PC+4
PC_Add PC_Add1(.pc_in(Address_out_PC), .pc_out(Address_Add_PC));
//Instruction Memory
Inst_Mem Inst_Mem1(.addr_in(Address_out_PC), .inst_out(Inst));
//Jump address
Shift_Left2_j j1(.Inst(Inst[25:0]), .PCAdd(Address_Add_PC[31:28]), .JAddr(Jump_addr));
//選擇rt or rd
MUX_6 MUX_6_1(.A(Inst[20:16]), .B(Inst[15:11]), .Sel(RegDst), .S(WriteReg));
//Controller
Controller C1(.op(Inst[31:26]), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .ALUop(ALUop), .jump(jump));
//Register
Registers Reg1(.clk(clk), .ReadReg1(Inst[25:21]), .ReadReg2(Inst[20:16]), .WriteReg(WriteReg), .WriteData(WriteData), .ReadData1(Read_Data1), .ReadData2(Read_Data2), .RegWrite(RegWrite));
//Sign extentsion
Sign_Extend S1(.Din(Inst[15:0]), .Dout(Sign_ext));
//Shift_Left2
Shift_Left2 SL1(.Din(Sign_ext), .Dout(Sign_out));
//pc+4 和 sign extentsion後的立即數相加
ADD_Addr ADD_Addr1(.Addr1(Address_Add_PC), .Addr2(Sign_out), .Addr_out(Branch_Addr));

assign BranchZero =  Branch & Zero;

//選擇要pc+4還是branch address
MUX_32 MUX_32_1(.A(Address_Add_PC), .B(Branch_Addr), .Sel(BranchZero), .S(Branch_PC4));
//選擇要jump還是Branch_PC4
MUX_32 MUX_32_2(.A(Branch_PC4), .B(Jump_addr), .Sel(jump), .S(Address_in_PC));
//選擇要Read_Data2還是sign extentsion後的結果
MUX_32 MUX_32_3(.A(Read_Data2), .B(Sign_out), .Sel(ALUSrc), .S(ALUin));
//ALU control unit
ALUCtrl ALUCtrl1(.ALUop(ALUop), .Func(Inst[5:0]), .ALUctr(ALUctr));
//ALU計算，會有判斷是不是全0
ALU ALU1(.A(Read_Data1), .B(ALUin), .ALUCtrl(ALUctr), .Zero(Zero), .ALUResult(ALUResult));
//Data memory
Data_Mem Data_Mem1(.clk(clk), .Addr_in(ALUResult), .WriteData(Read_Data2), .ReadData(Read_Data_Mem), .MemWrite(MemWrite), .MemRead(MemRead));
//選擇寫回暫存器是ALU運算結果還是ReadData的結果
MUX_32 MUX_32_4(.A(ALUResult), .B(Read_Data_Mem), .Sel(MemtoReg), .S(WriteData));

endmodule
