function [ outMat ] = fitGaussian( inMat,lmin,lmax )

    % dimensions 
    [Nband Naz] = size(inMat);
    
    %init matrice sotie
    outMat=zeros(Nband,Naz);
    
    %largeur des gaussian en fonction de la bande
    width=linspace(lmin,lmax,Nband);
    
    %fit gaussienne
    for iband=1:Nband
        G=gausswin(round(width(iband)))';
        tmp=conv(inMat(iband,:),G,'same');
        outMat(iband,:)=tmp;%./sum(tmp);
    end

end

