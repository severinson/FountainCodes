using RaptorCodes, Base.Test

function init(k=10)
    p = RaptorCodes.R10Parameters(k)
    d = RaptorCodes.Decoder(p)
    C = Array{RaptorCodes.ISymbol,1}(p.L)
    for i = 1:p.K
        C[i] = RaptorCodes.ISymbol(i, Set([i]))
    end
    RaptorCodes.r10_ldpc_encode!(C, p)
    RaptorCodes.r10_hdpc_encode!(C, p)
    return p, d, C
end

function test_active_degree()
    p, d, C = init()
    s = RaptorCodes.lt_generate(C, 1, p)
    d = RaptorCodes.active_degree(s)
    d_correct = length(s.active_neighbours)
    if d != d_correct
        error("active_degree($s) is $d. should be length $d_correct")
    end
    return true
end
@test test_active_degree()

function test_select_row_1()
    p, d, C = init()
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(1, 0, [1]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(2, 0, [1, 2]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(3, 0, [1, 2, 3, 4]))
    i = RaptorCodes.select_row(d)
    if i != p.S + p.H + 1
        error("selected row $i. should have selected row $(p.S+p.H+1).")
    end
    return true
end
@test test_select_row_1()

function test_select_row_2()
    p, d, C = init()
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(1, 0, [1]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(2, 0, [1, 2]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(3, 0, [1, 2, 3, 4]))
    RaptorCodes.subtract!(d, p.S+p.H+3, p.S+p.H+1)
    i = RaptorCodes.select_row(d)
    correct = p.S + p.H + 2
    if i != correct
        error("selected row $i. should have selected row $correct.")
    end
    return true
end
@test test_select_row_2()

function test_select_row_3()
    p, d, C = init()
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(0, 0, [1, 2]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(0, 0, [1, 3]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(0, 0, [2, 4]))
    RaptorCodes.add!(d, RaptorCodes.R10Symbol(0, 0, [5, 6]))
    RaptorCodes.subtract!(d, p.S+p.H+3, p.S+p.H+1)
    i = RaptorCodes.select_row(d)
    correct = [1, 2, 3] + (p.S + p.H)
    if !(i in correct)
        error("selected row $i. should have selected one of $correct.")
    end
    return true
end
@test test_select_row_3()

function test_decoder_1()
    p, d, C = init()
    for i in 1:20
        s = RaptorCodes.lt_generate(C, i, p)
        RaptorCodes.add!(d, s)
    end
    output = RaptorCodes.decode!(d)
    for i in 1:p.K
        if output[i] != C[i].value
            error(
                "decoding failure. source[$i] is $(output[i]). should be $(C[i].value)."
            )
        end
    end
    return true
end
@test test_decoder_1()

function test_decoder_2()
    p, d, C = init()
    for i in 1:15
        s = RaptorCodes.lt_generate(C, i, p)
        RaptorCodes.add!(d, s)
    end
    output = RaptorCodes.decode!(d)
    for i in 1:p.K
        if output[i] != C[i].value
            error(
                "decoding failure. source[$i] is $(output[i]). should be $(C[i].value)."
            )
        end
    end
    return true
end
@test test_decoder_2()

function test_decoder_3()
    p, d, C = init(20)
    for i in 1:25
        s = RaptorCodes.lt_generate(C, i, p)
        RaptorCodes.add!(d, s)
    end
    output = RaptorCodes.decode!(d)
    for i in 1:p.K
        if output[i] != C[i].value
            error(
                "decoding failure. source[$i] is $(output[i]). should be $(C[i].value)."
            )
        end
    end
    return true
end
@test test_decoder_3()

function test_decoder_4()
    p, d, C = init(1024)
    for i in 1:1030
        s = RaptorCodes.lt_generate(C, i, p)
        RaptorCodes.add!(d, s)
    end
    output = RaptorCodes.decode!(d)
    for i in 1:p.K
        if output[i] != C[i].value
            error(
                "decoding failure. source[$i] is $(output[i]). should be $(C[i].value)."
            )
        end
    end
    return true
end
@test test_decoder_4()
