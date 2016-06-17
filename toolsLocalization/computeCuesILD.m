function [ ILD_m ]= computeCuesILD( signal_m, params )
%
% [ ILD_m,lag ]= computeCuesILD( signal_m , fs , binaurale , params)
%
% IN
%       signal_m : Matrice signal filtre 
%
% OUT
%       ILD_m    : Matrice des differences de niveux interaural par bande
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (strcmp(params.ILD,'Basic'))
         [ ILD_m ] = correlogramILD(signal_m);
    else  
        disp('Erreur dans le choix de la methode de filtrage');  
    end

end

