import qtpa_pkg::*;

module scalar_regfile (
    input  logic                  clk,
    input  logic                  rst_n, // Synchronous active-high reset per your spec, or active-low depending on your preference

    // Read Port 1 (Ss1)
    input  logic [3:0]            rs1_addr,
    output logic [DATA_WIDTH-1:0] rs1_data,

    // Read Port 2 (Ss2)
    input  logic [3:0]            rs2_addr,
    output logic [DATA_WIDTH-1:0] rs2_data,

    // Write Port (Sd)
    input  logic                  we,      // Write Enable
    input  logic [3:0]            rd_addr, // Destination address
    input  logic [DATA_WIDTH-1:0] rd_data, // Data to write

    // Dedicated Status Register Output (S15)
    output logic [DATA_WIDTH-1:0] status_reg_out
);
    logic [DATA_WIDTH:0]  regfile [15:0]; // 16 registers, each 32 bits wide

    always_ff @(posedge clk) begin : write
        if (!rst_n) begin
            // Initialize all registers to 0 on reset
            for (int i = 0; i < 16; i++) begin
                regfile[i] <= 'b0;
            end
        end else if (we) begin
            // Write to the register file if write enable is high and not writing to S0_IDX
            if (rd_addr != S0_IDX) begin
                regfile[rd_addr] <= rd_data;
            end
        end
    end

    always_comb begin : read
        status_reg_out = regfile[S15_IDX]; // status register output
        // Read from the register file, ensuring S0_IDX always reads as 0
        rs1_data = (rs1_addr == S0_IDX) ? 'b0 : regfile[rs1_addr];
        rs2_data = (rs2_addr == S0_IDX) ? 'b0 : regfile[rs2_addr];
    end

endmodule