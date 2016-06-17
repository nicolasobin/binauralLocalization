function [ILD_m,lag] = mayILD(signal_m)

Nband = size(signal_m,1);
ILD_m = zeros(Nband,1);
lag=-1;

    for iband = 1:Nband
        rapport = 20*log10(abs(fft(signal_m(iband,:,1)))./abs(fft(signal_m(iband,:,2))));
        ILD_m(iband)   =   mean(rapport(~isnan(rapport)))   ;
    end
    
end