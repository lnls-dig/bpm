function [window] = tukeywin2(len)
    ratio = 1;
    window = tukeywin(len,ratio);
end

