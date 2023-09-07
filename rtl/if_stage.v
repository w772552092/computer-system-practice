`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    
    output  wire                    ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr,
    
/************************ת��ָ����� begin*******************************/
    output  wire [`INST_ADDR_BUS] 	pc_plus_4,
    // ������׶λ�õ���ת��ַ
    input   wire [`INST_ADDR_BUS]   jump_addr_1,
    input   wire [`INST_ADDR_BUS]   jump_addr_2,
    input   wire [`INST_ADDR_BUS]   jump_addr_3,
    input   wire [`JTSEL_BUS    ]   jtsel,
/*********************** ת��ָ����� end*********************************/
/************************��ˮ����ͣ begin*********************************/
    input   wire [`STALL_BUS    ]   stall,
/************************��ˮ����ͣ end***********************************/
/************************�쳣���� begin*******************************/
    output  wire [`EXC_CODE_BUS ] 	if_exccode_o,
	output  wire [`INST_ADDR_BUS] 	if_badvaddr_o,
    input   wire                    flush,          // �����ˮ���ź�
    input   wire [`INST_ADDR_BUS]   cp0_excaddr     // �쳣���������ڵ�ַ
/************************�쳣���� end*********************************/
    );
                  
    assign pc_plus_4 = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : pc + 4;
/************************ת��ָ����� begin*******************************/
    wire [`INST_ADDR_BUS] pc_next;
    assign pc_next = (jtsel == 2'b00) ? pc_plus_4 :              // ������һ��ָ��ĵ�ַ
                     (jtsel == 2'b01) ? jump_addr_1 :            // j, jalָ��ת�Ƶ�ַ
                     (jtsel == 2'b10) ? jump_addr_3 :            // jrָ��ת�Ƶ�ַ
                     (jtsel == 2'b11) ? jump_addr_2 : `PC_INIT;  // beq, bneָ��ת�Ƶ�ַ
/*********************** ת��ָ����� end*********************************/

/************************��ˮ����ͣ begin*********************************/
    reg ce;
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE)
			ce <= `CHIP_DISABLE;		      // ��λ��ʱ��ָ��洢������  
		else begin
			ce <= `CHIP_ENABLE; 		      // ��λ������ָ��洢��ʹ��
		end
	end

    assign iaddr = pc;    // ��÷���ָ��洢���ĵ�ַ
    wire word_aligned = iaddr[1:0] == 2'b00;

    assign ice = (stall[1] == `TRUE_V || flush || !word_aligned) ? 0 : ce; // ��stall[1]��flush����Ϊ1��δ�������ַ�쳣ʱ�����ܷ���ָ��洢��

    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // ָ��洢�����õ�ʱ��PC���ֳ�ʼֵ��MiniMIPS32������Ϊ0x00000000��
        else begin
/************************�쳣���� begin*******************************/
            if(flush == `TRUE_V)        
                pc <= cp0_excaddr;            // �������쳣ʱ��PC�����쳣���������ڵ�ַ
/************************�쳣���� end*********************************/
            else if (stall[0] == `NOSTOP) begin
                pc <= pc_next;                // ��stall[0]ΪNOSTOPʱ��pc����pc_next�����򣬱���pc����	
            end
        end
    end
/************************��ˮ����ͣ end***********************************/
    
    assign if_badvaddr_o 	= (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                              (!word_aligned) 	 ? iaddr	:
                              (ice == `CHIP_DISABLE) ? `ZERO_WORD :  `ZERO_WORD;
	assign if_exccode_o 	= (cpu_rst_n == `RST_ENABLE) ? `EXC_NONE  : 
                              (!word_aligned) 	 ? `EXC_ADEL  : 
                              (ice == `CHIP_DISABLE) ? `EXC_NONE  : `EXC_NONE;

endmodule
