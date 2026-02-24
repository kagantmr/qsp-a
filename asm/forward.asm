MOV_IMM S1, S0, #50    // S1 = 50
ADD_IMM S2, S1, #10    // S2 = 60 (Forward S1 from WB to EX)
SUB_REG S3, S2, S1     // S3 = 10 (Forward S2 and S1 from WB to EX)
ADD_REG S4, S3, S3     // S4 = 20 (Forward S3 from WB to EX)
NOP S0, S0, S0
NOP S0, S0, S0