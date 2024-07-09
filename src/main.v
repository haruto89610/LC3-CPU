module main (
    //INSTRUCTION REGISTER
    input LDIR,
    output [15:0] IRout,

    //ADDR1MUX
    input [15:0] ADDR1in1,
    input ADDR1sel,
    output [15:0] ADDR1out,

    //ADDR2MUX
    input [1:0] ADDR2sel,
    output [15:0] ADDR2out,

    //PCMUX
    input [15:0] PCMUXin1,
    input [1:0] PCMUXsel,

    input LDPC,
    output [15:0] PCout,

    input PCENA,

    //MARMUX
    input MARMUXsel,
    input MARMUXENA,
    output [15:0] gateMARMUXout
);

//BUS
    wire [15:0] BUS;

//INSTRUCTION REGISTER
    register IRreg (
        .LD(LDIR),
        .in(BUS),
        .out(IRout)
    );

//ADDR1 MUX INPUTS
    MUX2X1 ADDR1 (
        .in1(ADDR1in1),
        .in0(PCMUXout),
        .MUXsel(ADDR1sel),
        .MUXout(ADDR1out)
    );

//ADDR2 MUX INPUTS
  //SEXT MUX INPUTS
    wire [15:0] ADDR2in3;
    wire [15:0] ADDR2in2;
    wire [15:0] ADDR2in1;

    assign ADDR2in3 = {{5{IRout[10]}}, IRout[10:0]};
    assign ADDR2in2 = {{7{IRout[8]}}, IRout[8:0]};
    assign ADDR2in1 = {{10{IRout[5]}}, IRout[5:0]};
  //MUX INPUTS
    MUX4X1 ADDR2 (
        .in3(ADDR2in3),
        .in2(ADDR2in2),
        .in1(ADDR2in1),
        .in0(16'b0),
        .MUXsel(ADDR2sel),
        .MUXout(ADDR2out)
    );

// ADDER
    wire [15:0] sum;
    assign sum = ADDR2out + ADDR1out;

// PC MUX INPUTS
    wire [15:0] PCMUXout;

    MUX4X1 PCMUX (
        .in2(sum),
        .in1(PCMUXin1),
        .in0(PCout + 1'b1),
        .MUXsel(PCMUXsel),
        .MUXout(PCMUXout)
    );

    register PCreg (
        .LD(LDPC),
        .in(PCMUXout),
        .out(PCout)
    );

    TRI gatePC (
        .in(PCout),
        .ENA(PCENA),
        .out(BUS)
    );

// MARMUX INPUTS
  //ZERO EXTEND INPUTS
    wire [15:0] MARMUXin0;
    wire [15:0] MARMUXout;
    assign MARMUXin0 = {8'b0, IRout[7:0]};
    
    MUX2X1 MARMUX (
        .in1(sum),
        .in0(MARMUXin0),
        .MUXsel(MARMUXsel),
        .MUXout(MARMUXout)
    );

    TRI gateMARMUX (
        .in(MARMUXout),
        .ENA(MARMUXENA),
        .out(BUS)
    );

endmodule