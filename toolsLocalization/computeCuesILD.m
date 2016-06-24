function [ ILD_m ]= computeCuesILD( signal_m,methode )
%
% [ILD_m] = computeCuesILD(signal_m)
%
% IN
%       signal_m : Matrice signal filtre 
%
% OUT
%       ITD_m    : Matrice des differences de temps interaural par bande
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Nband = size(signal_m,1);
    
    %init matrice ILDs
    ILD_m = zeros(Nband,1);

        for iband = 1:Nband
            rapport = 10*log10((abs(fft(signal_m(iband,:,1))).^2)./(abs(fft(signal_m(iband,:,2))).^2));
            ILD_m(iband)=mean(rapport(~isnan(rapport)& ~isinf(rapport)));

        end

end

