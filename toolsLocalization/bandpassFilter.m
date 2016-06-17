function [ signal_m , spec_m,freq_v ] = bandpassFilter( frame_v,fs,params)
%
% [ signal_m , spec_m freq_v ] = bandpassFilter( frame_v,fs,Nband,fmin,fmax,filtrage )
%
% IN
%       frame_v  : Trame temporelle
%       fs       : Frequence d'echantillonnage du signal frame_v
%       Nband    : Nombre de filtre dans la gamme de frequence
%       fmin     : Borne inferieur de la plage de frequence
%       fmax     : Borne superieur de la plage de frequence
%       filtrage : Methode de filtrage ('gammatone'/'lineaire')
%
% OUT
%       signal_m : Matrice signal filtre 
%       spec_m   : Matrice frequences par bandes
%       freq_v   : Vecteur des frequences centrales des filtres
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(params.fmax>fs/2)
        error('fmax ne peut pas etre superieur à fs/2')
    end

    if (strcmp(params.methode,'gammatone'))

        % frequence selon ERB
         freq_v= MakeErbCFs(params.fmin,params.fmax,params.Nband);
         
         % filtrage gammatone
         [ signal_m(:,:,1) , ~ , ~ , spec_m ] = gammatoneFast(frame_v(:,1),fs,freq_v,true);
         [ signal_m(:,:,2) , ~ , ~ , ~ ]      = gammatoneFast(frame_v(:,2),fs,freq_v,true);
         
    elseif (strcmp(params.methode,'lineaire'))

        %filtrage lineaire
        [ signal_m(:,:,1) , spec_m , freq_v ] = bandPassFreqLinear (frame_v(:,1) , fs ,params.Nband , params.fmin , params.fmax );
        [ signal_m(:,:,2) , ~ , ~ ]           = bandPassFreqLinear (frame_v(:,2) , fs ,params.Nband , params.fmin , params.fmax );
        
    else
        disp('Erreur dans le choix de la methode de filtrage');
    end

end