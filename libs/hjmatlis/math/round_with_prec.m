function [value] = round_with_prec(value, precision)
    %[outvalue] = round_with_prec(value, precision)
    %   simple wrapper to execute rounding with precision
    value=round(value*(10^precision))/(10^precision);
end

