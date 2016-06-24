function [ ITD_m,lag_v ]= computeCuesITD( signal_m , fs , maxDelay,methode)
%
% [ output_args ] = computeCuesITD( signal_m , fs , maxDelay )
%
% IN
%       signal_m : Signal gauche et droite
%       fs       : Fréquence d'echantillonnage des signaux
%       maxDelay : Delai maximum entre les signaux gauche et droite (en secondes)
%       Gwin_v   : valeurs limite des gaussiennes
%
% OUT
%       ITD_m    : Matrice ITD par bande de frequence
%       lag_v    : Vecteur retard en echantillon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % nombre de bande
    Nband = size(signal_m,1);
    
    % maximum delai admissible entre les deux signaux en echantillons
    maxlag = round( maxDelay * fs );
    
    % init ITD matrice
    ITD_m=zeros(Nband,(2*maxlag)+1); % 2N+1 points
    itdEst=zeros(Nband,1);
    
    for iband = 1 : Nband

        % correlation croisee
        [acor,lag_v]=xcorr(signal_m(iband,:,1),signal_m(iband,:,2),maxlag);

        % normalisation
        powL = sum(signal_m(iband,:,1).^2);
        powR = sum(signal_m(iband,:,2).^2);
        
        acorNorm=acor./ repmat(eps + sqrt(powL .* powR),[1 length(lag_v)]);
        
        % detection peak
        [k,v]=findpeaks(acorNorm);

        % positionnement des peaks
        ITD_m(iband,k)=v;
        
    end
   

end

