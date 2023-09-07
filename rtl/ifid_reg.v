`include "defines.v"

module ifid_reg (
	input  wire 					   cpu_clk_50M,
	input  wire 					   cpu_rst_n,

	// ����ȡָ�׶ε���Ϣ  
	input  wire [`INST_ADDR_BUS]       if_pc,
	
	// ��������׶ε���Ϣ  
	output reg  [`INST_ADDR_BUS]       id_pc,
/************************ת��ָ����� begin*******************************/
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,
    output reg  [`INST_ADDR_BUS] 	   id_pc_plus_4,
/*********************** ת��ָ����� end*********************************/
/************************��ˮ����ͣ begin*********************************/
    input  wire [`STALL_BUS    ]       stall,
/************************��ˮ����ͣ end***********************************/
/************************�쳣���� begin*******************************/
	input  wire [`EXC_CODE_BUS ]       if_exccode,
    output reg  [`EXC_CODE_BUS ]       id_exccode,
    input  wire [`WORD_BUS     ]       if_badvaddr,
    output reg  [`WORD_BUS     ]       id_badvaddr,
	input  wire						   flush			// �����ˮ���ź�
/************************�쳣���� end*********************************/
	);

	always @(posedge cpu_clk_50M) begin
	    // ��λ�������ˮ��ʱ������������׶ε���Ϣ��0
/************************�쳣���� begin*******************************/
		if (cpu_rst_n == `RST_ENABLE || flush) begin
			id_exccode   <= `EXC_NONE;
			id_badvaddr  <= `ZERO_WORD;
/************************�쳣���� end*********************************/
			id_pc 	     <= `PC_INIT;
			id_pc_plus_4 <= `PC_INIT;
/************************��ˮ����ͣ begin*********************************/
		end 
		else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
		// ȡָ�׶���ͣʱpcΪ0
			id_exccode  <= `EXC_NONE;
			id_badvaddr  <= `ZERO_WORD;
			id_pc   	 <= `PC_INIT; 	
			id_pc_plus_4 <= `PC_INIT;
		end
		else if(stall[1] == `NOSTOP) begin
/************************��ˮ����ͣ end***********************************/
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
			id_exccode   <= if_exccode;
			id_badvaddr  <= if_badvaddr;
			id_pc	     <= if_pc;		
			id_pc_plus_4 <= if_pc_plus_4;
		end
	end

endmodule
