function [ azEst_ILD,azEst_ITD,azEst_JOINT ] = Localization(x,fs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Localisation d'une source sonore en milieu realiste
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   carte    :  carte indices binauraux ('hole' 25az / 'full' 37az)

%   Nwin     :  nombre de point par frame
%   hop      :  nombre de point de décalage

%   threshold:  seuil silence en dB

%   Nfft     :  nombre de point de la TF
%   Nband    :  nombre de filtre et nombre d'indices par fenetre temporelle
%   fmin     :  frequence minimum d'etude
%   fmax     :  frequence maximum d'etude
%   filtrage :  méthode de filtrage (lineaire\gammatone)

%   ITD      :  méthode de calcul des ITDs
%   ILD      :  méthode de calcul des ILDs
%   maxDelay :  temps d'arrivé max entre les signaux entre G & D

%   azILD    :  methode assignation filtre HRTF ('independant','together')
%   new_az   :  azimut d'estimaion final
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    addpath('.\toolsLocalization');
    addpath('.\map');

%% PARAMETERS

    % carte offline
    type.carte='hole';

    % fenetrage
    Nwin =1024;
    hop =Nwin/2;
    
    %silent
    threshold=-40;
    
    % filtrage
    Nfft =Nwin;
    Nband = [32 32];
    fmin = [50 50];
    fmax = [8000 2500];
    type.filtrage = 'lineaire';

    % indices binauraux
    binaurale.ITD = 'Correlogram';
    binaurale.ILD = 'Basic';
    maxDelay = 0.001;
    
    % estimation azimut
    type.azILD = 'independant';
    new_az=-80:1:80;
    
    % affichage
    affiche=true;
    
    %% MAP CUES BINAURAL
    
    [Map_hrtf] = mapCuesBinaural (fs,type.carte);
    
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

         % detecion silence
        silent = detectSilence(x,frame_v,threshold);

        % choix du traitement
        if( silent == true )

            azEst_ILD(iframe) = nan;
            azEst_ITD(iframe) = nan;
            azEst_JOINT(iframe) = nan;

        else

%% FILTER

            [ signal_l_m , spec_l_m , freq_l_v ] = filterBank( frame_v , fs , Nfft ,Nband(1) , fmin(1) , fmax(1) , type.filtrage );
            [ signal_t_m , spec_t_m , freq_t_v ] = filterBank( frame_v , fs , Nfft ,Nband(2) , fmin(2) , fmax(2) , type.filtrage );

%% CUES BINAURAL

            [ ILD_m ]     = computeCuesILD( signal_l_m  , binaurale);
            [ ITD_m,lag ] = computeCuesITD( signal_t_m , fs , maxDelay , binaurale);
    
%% ADAPTATION MAP

            az_range = Map_hrtf.azimut;
            ITD_ref  = interp2(Map_hrtf.frequence,Map_hrtf.azimut,Map_hrtf.ITD,freq_t_v,Map_hrtf.azimut);
            ILD_ref  = interp2(Map_hrtf.frequence,Map_hrtf.azimut,Map_hrtf.ILD,freq_l_v,Map_hrtf.azimut);

%% AZIMUTH ESTIMATION

            [ theta_L ] = estimateAzimutILD( ILD_m,ILD_ref,type.azILD );
            [ theta_T ] = estimateAzimutITD( ITD_m,lag,fs,ITD_ref,az_range );

%% EXTRAPOLATION

            % allocation memoire
            theta_T_full=zeros(size(theta_T,1),numel(new_az));
            theta_L_full=zeros(size(theta_T,1),numel(new_az));
    
            % vecteur de passage
            [~,~,idx]=intersect(az_range,new_az);
            
            % recherche des votes
            [row_T,col_T,v_T]=find(theta_T);
            [row_L,col_L,v_L]=find(theta_L);
            
            % attribution aux nouvelles positions
            indT = sub2ind(size(theta_T_full), row_T,idx(col_T));
            indL = sub2ind(size(theta_L_full), row_L,idx(col_L));
            theta_T_full(indT)=v_T;
            theta_L_full(indL)=v_L;
            
%% PROBABILITY

        %THETA ILD
        P_azEst_ILD=fitGaussian(  theta_L_full,5,13 );
        marg_ILD=sum(P_azEst_ILD,1)./max(sum(P_azEst_ILD,1));

        %THETA ITD
        P_azEst_ITD=fitGaussian(  theta_T_full,13,5 );
        marg_ITD=sum(P_azEst_ITD,1)./max(sum(P_azEst_ITD,1));

%% JOINT ITD & ILD

        if (size(P_azEst_ITD,1)~=size(P_azEst_ILD,1))
            P_azEst_JOINT=[sum(P_azEst_ITD,1);sum(P_azEst_ILD,1)];
            marg_JOINT=sum(P_azEst_JOINT,1)./max(sum(P_azEst_JOINT,1));
        else
            P_azEst_JOINT=[P_azEst_ITD;P_azEst_ILD];
            marg_JOINT=sum(P_azEst_JOINT,1)./max(sum(P_azEst_JOINT,1));
        end
        
%% SELECTION

        [~,ind_L] = max(marg_ILD);
        azEst_ILD(iframe) = new_az(ind_L);

        [~,ind_T] = max(marg_ITD);
        azEst_ITD(iframe) = new_az(ind_T);

        [~,ind_J] = max(marg_JOINT);
        azEst_JOINT(iframe) = new_az(ind_J);
    
        end
    end
    
    if (affiche==true)
        
        figure;
        azRef=10;
        plot(abs(azEst_ILD-azRef*ones(size(azEst_ILD))),'g');hold on;
        plot(abs(azEst_ITD-azRef*ones(size(azEst_ILD))),'b');hold on;
        plot(abs(azEst_JOINT-azRef*ones(size(azEst_ILD))),'r');hold on;
        title('erreur absolue par trame')
        ylabel('erreur absolue en degre [°]');xlabel('indice de la trame')
        legend('ILD','ITD','JOINT');

        %figure;
        %[a,b]=hist(azEst_JOINT,-80:1:80);
        %polar(rad2deg(b),a)
    end
    
    
end

