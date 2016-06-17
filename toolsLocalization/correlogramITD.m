function [ ITD_m,lag_v ] = correlogramITD( signal_m , fs , maxDelay , Norm)
%
% [ output_args ] = correlogram( l_m , r_m , fs , maxDelay , Gwnin)
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

    Nband = size(signal_m,1);
    
    % maximum delai admissible entre les deux signaux en echantillons
    maxlag = round( maxDelay * fs );
    
    % init matrice ITDs
    ITD_m=zeros(Nband,(2*maxlag)+1); % 2N+1 points
    
    for iband = 1 : Nband

        [acorNorm,lag_v]=crossCorr(signal_m(iband,:,1),signal_m(iband,:,2),maxlag,Norm);

        % detection peak
        [k,v]=findpeaks(acorNorm);

        %positionnement sommets
        ITD_m(iband,k)=v;

    end

end

