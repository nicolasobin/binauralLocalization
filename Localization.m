function [ azEst_ILD,azEst_ITD,azEst_JOINT ] = Localization(x,fs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Localisation de la source sonore à partir d'un enregistrement binaural
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Nwin     :  nombre de point par frame
%   hop      :  nombre de point de décalage

%   Nband    :  nombre de filtre et nombre d'indices par fenetre temporelle
%   fmin     :  frequence minimum d'etude
%   fmax     :  frequence maximum d'etude
%   filtrage :  méthode de filtrage (lineaire\gammatone)

%   ITD      :  méthode de calcul des ITDs
%   ILD      :  méthode de calcul des ILDs
%   maxDelay :  temps d'arrivé max entre les signaux entre G & D
%   normCorr :  correlatio normailisee (true/false)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PATH

    addpath('.\toolsLocalization');
    addpath('.\map');

%% PARAMETERS

    % fenetrage
    Nwin =1024;
    hop =Nwin/2;
    
    % filtrage
    filtrage.Nband = 32;
    filtrage.fmin = 60;
    filtrage.fmax = 8000;
    filtrage.methode = 'lineaire';

    % indices binauraux
    binaurale.ITD = 'Correlogram';
    binaurale.ILD = 'Basic';
    binaurale.maxDelay = 0.001;
    binaurale.normCorr='true';
    
    % estimation azimut
    azimut.ILD = 'full';
    
%% LOAD MAP BINAURAL CUES

    if(fs==44100)
        load('Map_hrtf_KL_44kHz.mat');
    elseif (fs==16000)
        load('Map_hrtf_KL_16kHz.mat');
    else
        disp('la carte associee a cette frequence d''echantillonnage n''existe pas');
    end
     
%% FRAMING

    frame_m=[];
    [frame_m(:,:,1), indices] = Fenframe(x(:,1),Nwin,hop);
    [frame_m(:,:,2), indices] = Fenframe(x(:,2),Nwin,hop);

%% PRE ALLOCATION

    azEst_ILD=zeros(1,size(frame_m,2));
    azEst_ITD=zeros(1,size(frame_m,2));
    azEst_JOINT=zeros(1,size(frame_m,2));
    
    for iframe= 1 : size(frame_m,2)
        
        % selection de la trame
        frame_v=squeeze(frame_m(:,iframe,:));

%% PRE-PROCESSING

        [ signal_m , spec_m , freq_v ] = bandpassFilter(frame_v,fs,filtrage);

%% CUES BINAURAL

        [ ILD_m ]     = computeCuesILD( signal_m , binaurale);
        [ ITD_m,lag ] = computeCuesITD( signal_m , fs , binaurale);
    
%% ADAPTATION MAP

        ITD_ref  = interp2(Map_hrtf.frequence,Map_hrtf.azimut,Map_hrtf.ITD,freq_v,Map_hrtf.azimut);
        ILD_ref  = interp2(Map_hrtf.frequence,Map_hrtf.azimut,Map_hrtf.ILD,freq_v,Map_hrtf.azimut);
        az_range = Map_hrtf.azimut;

%% AZIMUTH ESTIMATION

        %THETA ILD
        [ theta_L ] = estimateAzimutILD( ILD_m,ILD_ref,azimut.ILD );

        %THETA ITD
        [ theta_T ] = estimateAzimutITD( ITD_m,lag,fs,ITD_ref,az_range );

%% PROBABILITY

        %THETA ILD
        P_azEst_ILD=fitGaussian( theta_L,5,10 );
        marg_ILD=sum(P_azEst_ILD,1)./max(sum(P_azEst_ILD,1));

        %THETA ITD
        P_azEst_ITD=fitGaussian( theta_T,10,5 );
        marg_ITD=sum(P_azEst_ITD,1)./max(sum(P_azEst_ITD,1));

%% HISTO JOINT

        H_marg=zeros(1,length(az_range));
        H_joint=zeros(length(az_range),length(az_range));
        for ii=1:length(az_range)
            for jj=1:length(az_range)
                H_joint(ii,jj)=marg_ILD(ii)*marg_ILD(jj);
                if (ii==jj)
                    H_marg(ii)=H_joint(ii,jj);
                end
            end
        end
    
%% SELECTION

        [~,ind_L] = max(marg_ILD);
        azEst_ILD(iframe) = az_range(ind_L);

        [~,ind_T] = max(marg_ITD);
        azEst_ITD(iframe) = az_range(ind_T);

        [~,ind_J] = max(H_marg);
        azEst_JOINT(iframe) = az_range(ind_J);
    
    end
 
end

