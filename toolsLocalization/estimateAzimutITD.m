function [ theta_T ] = estimateAzimutITD( ITD_m,lag,fs,ITD_ref,az_range)
%
% [ theta_L ] = estimateAzimutILD(ILD_m,ILD_ref,Naz,Nband ,methode )
%
% estimateAzimutILD : estimation de l'azimut à partir de l'ILD et d'une carte
%
% IN
%          ITD_m     : vecteur d'ITD
%          lag       : vecteur d'echantillon de retard ou d'avance
%          fs        : frequence d'echantillonnage
%          ITD_ref   : carte issue d'HRTF   
% OUT
%          theta_T   : matrice d'azimut estimé par ITD

    % 
    [Naz Nband]=size(ITD_ref);

    % init matrice d'azimut estimés
    theta_T=zeros(Nband,Naz);
    
    % retard temporel
    tau = lag/fs;
    
   for iband=1:Nband
            
        % concordance azimut retard temporel en fonction de la frequence
        chgt_ech=interp1(ITD_ref(:,iband),az_range,tau,'nearest');
            
        for jj=1:length(tau)
                
            if (~isnan(chgt_ech(jj)) && ITD_m(iband,jj)>0)
                loc=find(az_range==chgt_ech(jj));
                theta_T(iband,loc)=theta_T(iband,loc)+ITD_m(iband,jj); %% peut etre a diviser par nombre d'element
            end
                
        end
       
	end

end

