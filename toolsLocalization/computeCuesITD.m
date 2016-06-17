function [ ITD_m,lag ]= computeCuesITD( signal_m , fs , params)
%
% [ ITD_m,lag ]= computeCuesITD( signal_m , fs , binaurale , params)
%
% IN
%       signal_m : Matrice signal filtre 
%       fs       : Frequence d'echantillonnage
%       binaurale: Methode de calcul des indices (correlogram/may)
%       params   : parametres facultatifs
%
% OUT
%       ITD_m    : Matrice des differences de temps interaural par bande
%       lag      : vecteur temporel du nombre d'echantillon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (strcmp(params.ITD,'Correlogram'))

         [ITD_m,lag] = correlogramITD(signal_m , fs , params.maxDelay ,  params.normCorr );

    elseif (strcmp(params.ITD,'May'))

         [ITD_m,lag] = mayITD(signal_m,fs,params.maxDelay); 

    else
        
        disp('Erreur dans le choix de la methode de filtrage');
        
    end

end

