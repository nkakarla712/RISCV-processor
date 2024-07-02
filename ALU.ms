// Don't change signature of existing functions. You may write additional helper functions if you want.


// Description: 32-bit right barrel shifter
// Arguments: in (value to be shifted); sftSz (shift size); sft_in (the bit shifted in)
// Return: {sft_in's, in[31:sftSz]}
function Bit#(32) barrelRShift(Bit#(32) in, Bit#(5) sftSz, Bit#(1) sft_in);
    Bit #(32) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(16) in16 = signExtend(sft_in);
    Bit#(8) in8 = signExtend(sft_in);
    Bit#(4) in4 = signExtend(sft_in);
    Bit#(2) in2 = signExtend(sft_in);

    Bit#(32) r4 = (sftSz[4] == 0) ? in : {in16, in[31:16]};
    Bit#(32) r3 = (sftSz[3] == 0) ? r4 : {in8, r4[31:8]};
    Bit#(32) r2 = (sftSz[2] == 0) ? r3 : {in4, r3[31:4]};
    Bit#(32) r1 = (sftSz[1] == 0) ? r2 : {in2, r2[31:2]};
    Bit#(32) r0 = (sftSz[0] == 0) ? r1 : {sft_in, r1[31:1]};

    return r0;
endfunction

// Description: 32-bit arithmetic/logic right shifter
// Arguments: in (value to be shifted); sftSz (shift size); arith (1 = arithmetic, 0 = logic)
// Return: in >> sftSz
function Bit#(32) sr32(Bit#(32) in, Bit#(5) sftSz, Bit#(1) arith);
    Bit #(32) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) sft_in = (arith == 1)? in[31] : 0;
    ret = barrelRShift(in,sftSz,sft_in);

    return ret;
endfunction


// Description: 32-bit logic left shifter
// Arguments: in (values to be shifted); sftSz (shift size)
// Return: a << b
function Bit#(32) sll32(Bit#(32) in, Bit#(5) sftSz);
    Bit #(32) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////
    Bit#(32) revIn = 0;
    for (Integer i = 0; i <= 31; i = i + 1) begin
        revIn[31-i] = in[i];
    end

    Bit#(32) revRet = barrelRShift(revIn,sftSz,0);
    for (Integer i = 0; i <= 31; i = i + 1) begin
        ret[31-i] = revRet[i];
    end

    return ret;
endfunction


// Description: 32-bit FULL shifter
// Arguments: in (value to be shifted); sftSz (shift size);
// ShiftTypes:
// LogicalRightShift
// ArithmeticRightShift
// LeftShift
//
// Return: in >> sftSz when right shift; in << sftSz otherwise
typedef enum {LogicalRightShift, ArithmeticRightShift, LeftShift} ShiftType;

function Bit#(32) sft32(Bit#(32) in, Bit#(5) sftSz, ShiftType shiftType);
    Bit#(32) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) sft_in = 0;
    Bit#(32) to_input = in;

    if (shiftType == LogicalRightShift) sft_in = 0;
    else if (shiftType == ArithmeticRightShift) sft_in = in[31];
    else begin
        for (Integer i = 0; i <= 31; i = i + 1) begin
            to_input[31-i] = in[i];
        end
    end

    let to_return = barrelRShift(to_input,sftSz,sft_in);

    if (shiftType == LeftShift) begin
        for (Integer i = 0; i <= 31; i = i + 1) begin
            ret[31-i] = to_return[i];
        end
    end
    else ret = to_return;

    return ret;
endfunction



// Description: one-bit less-than comparator
// Arguments: a, b (1-bit values), eq, lt (eq and lt from previous comparator)
// Return: {eq_i, lt_i}
function Bit#(2) cmp(Bit#(1) a, Bit#(1) b, Bit#(1) eq, Bit#(1) lt);
    Bit#(2) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) eq_i = (eq & ~a & ~b & ~lt) | (eq & ~lt & a & b);
    Bit#(1) lt_i = (eq & ~lt & ~a & b) | (~eq & lt);

    ret = {eq_i, lt_i};
    return ret;
endfunction

// Description: unsigned 32-bit less-than comparator
// Arguments: a, b unsigned 32-bit values
// Return: 1 if a < b
function Bit#(1) ltu32(Bit#(32) a, Bit#(32) b);
    Bit#(1) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) eq = 1'b1;
    Bit#(1) lt = 1'b0;

    for (Integer i = 31; i >= 0; i = i - 1) begin
        let ans = cmp(a[i],b[i],eq,lt);
        eq = ans[1];
        lt = ans[0];
    end

    return lt;
endfunction

// Description: Signed/Unsigned 32-bit less-than comparator
// Arguments: a b (32-bit values); isSigned (signed comparator when 1, unsigned otherwise)
// Return: 1 if a < b
function Bit#(1) lt32(Bit#(32) a, Bit#(32) b, Bit#(1) isSigned);
    Bit#(1) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) eq = 1'b1;
    Bit#(1) lt = 1'b0;

    if (isSigned == 1) begin
        let ans = cmp(b[31],a[31],eq,lt);
        eq = ans[1];
        lt = ans[0];
        
        for (Integer i = 30; i >= 0; i = i - 1) begin
            ans = cmp(a[i],b[i],eq,lt);
            eq = ans[1];
            lt = ans[0];
        end

    end
    else begin
        for (Integer i = 31; i >= 0; i = i - 1) begin
            let ans = cmp(a[i],b[i],eq,lt);
            eq = ans[1];
            lt = ans[0];
        end
    end

    return lt;
endfunction

// Description: one-bit full adder
// Arguments: a, b, carry in
// Return: {carry out, sum}
function Bit#(2) fullAdder(Bit#(1) a, Bit#(1) b, Bit#(1) carryIn);
    Bit#(2) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) s = (a ^ b ^ carryIn);
    Bit#(1) c_out = (carryIn & (a ^ b) | (a & b));
    
    return {c_out,s};
endfunction

// Description: n-bit ripple-carry adder with a carry-in
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) rca#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////
    
    for (Integer i = 0; i < n; i = i + 1) begin
        let res = fullAdder(a[i],b[i], carryIn);
        ret[i] = res[0];
        carryIn = res[1];
    end

    return ret;
endfunction

// Description: n-bit ripple-carry adder/subractor
// Arguments: a, b (n-bit operands); isSub (1 => subtract, 0 => add)
// Return: isSub == 0 ? a + b : a - b
function Bit#(n) addSub#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) isSub);
    Bit#(n) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    Bit#(1) carryIn = 0;

    if (isSub == 1) begin
        carryIn = 1;
        b = ~b;
    end
    
    ret = rca#(n)(a,b,carryIn);


    return ret;
endfunction


// Alu Functions:
// Add: 32-bit Addition         (a + b)
// Sub: 32-bit Subtraction      (a - b)
// And: 32-bit Bitwise And      (a & b)
// Or: 32-bit Bitwise Or        (a | b)
// Xor: 32-bit Bitwise Xor      (a ^ b)
// Slt: Set less than           (a <u b ? 1 : 0)
// Sltu: Set less than unsigned (a <s b ? 1:0)
// Sll: Left logic shfit        (a << b)
// Srl: Right logic shift       (a >>u b)
// Sra: Right arithmetic shift  (a >>s b)
typedef enum {Add, Sub, And, Or, Xor, Slt, Sltu, Sll, Srl, Sra} AluFunc;


//Sll, Srl, Sra



// Description: Arithmetic Logic Unit (ALU)
// Arguments: a, operand a; b, operand b; func, ALU operation
// Return: output of ALU
function Bit#(32) alu(Bit#(32) a, Bit#(32) b, AluFunc func);
    Bit #(32) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    if (func == And) ret = a & b;
    else if (func == Or) ret = a | b;
    else if (func == Xor) ret = a ^ b;

    if (func == Add || func == Sub) begin
        Bit#(1) isSub = 0;
        if (func == Sub) isSub = 1;
        ret = addSub#(32)(a,b,isSub);
    end

    if (func == Slt || func == Sltu) begin
        Bit#(1) isSigned = 1;
        if (func == Sltu) isSigned = 0;
        ret = zeroExtend(lt32(a, b, isSigned));
    end


    if (func == Sll || func == Srl || func == Sra) begin
        let shifter = ArithmeticRightShift;
        if (func == Sll) shifter = LeftShift;
        else if (func == Srl) shifter = LogicalRightShift;

        ret = sft32(a,b[4:0],shifter);
    end

    return ret;
endfunction


// Description: Alternative shifter implementation (Discussion Question)
function Bit#(32) sft32_alt(Bit#(32) in, Bit#(5) sftSz, ShiftType shiftType);
    return (shiftType == LeftShift) ? sft32(in, sftSz, LeftShift) : ((shiftType == ArithmeticRightShift)? sft32(in, sftSz, ArithmeticRightShift) : sft32(in, sftSz, LogicalRightShift));
endfunction


// Description: N-bit fast adder with a carry-in (Design Exercise)
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) fastAdd#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n) ret = 0;
    //////////////////
    // YOUR CODE HERE
    /////////////////

    return recAdd#(n)(a,b,carryIn)[n-1:0];
endfunction


function Bit#(n+1) recAdd#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n+1) ret = 0;
    
    if (n == 1) begin
        ret = fullAdder(a,b,carryIn);
    end

    else begin
        Bit#(n/2 + 1) back_half = recAdd#(n/2)(a[n/2 - 1:0],b[n/2 - 1:0],carryIn);
        
        let c_cur = back_half[n/2];
        let s_back_half = back_half[n/2-1:0];

        Bit#(n/2 + 1) front_half = 0;
        if (c_cur == 0) begin
            front_half = recAdd#(n/2)(a[n - 1: n/2], b[n - 1: n/2], 0);
        end
        else begin
            front_half = recAdd#(n/2)(a[n -1: n/2], b[n-1:n/2], 1);
        end

        let s_front_half = front_half[n/2-1:0];
        let c_ret = front_half[n/2];

        ret = {c_ret, s_front_half, s_back_half};
    end

    return ret;



endfunction