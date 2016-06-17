function [acor,lag]=crossCorr(sig1,sig2,maxlag,type)
%
% [acor,lag]=crossCorrNorm(sig1,sig2,maxlag,type)
%
% crossCorr : correlation croisee des signaux 
% IN
%          sig1       : signal 1
%          sig2       : signal 2
%          maxlag   : delai en nombre d'echantillon calculé
%          type       : 'Norm'
% OUT
%          acor       : correlation des 2 signaux
%          lag         : vecteur fréquence des fft

    [acor,lag] = xcorr(sig1,sig2,maxlag);
    
    if(type==true)
        powL = sum(sig1.^2);
        powR = sum(sig2.^2);
        acor = acor / (sqrt(powL .* powR));
    end
    
end
    