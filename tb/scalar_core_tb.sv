import qtpa_pkg::*;

module scalar_core_tb (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [31:0]  instruction,
    output logic [31:0]  status_out,
    output logic         illegal
);

    // Instantiate scalar core
    scalar_core dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .instruction   (instruction),
        .status_out    (status_out),
        .illegal       (illegal)
    );

endmodule
