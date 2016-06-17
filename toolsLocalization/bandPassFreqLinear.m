function [ x_f , spec_m , fc ] = bandPassFreqLinear(x , fs ,Nband , fmin , fmax )
%
% [ x_f , spec_m , fc ] = bandPassFreqLinear(x, fs ,Nband , fmin , fmax )
%
% bandPassFrequencyFilter : filtre les spectres des signaux G&D
% IN
%          x         : signal temporel
%          f         : vecteur frequentiel
%          Nband     : nombre de filtre
%          fmin      : frequence minimale
%          fmax      : fréquence maximale
% OUT
%          x_f       : matrice signal temporel filtré
%          spec_m    : matrice des frequences par bandes
%          fc        : frequences centrales de chaque filtre

    % TF
    X=fft(x);
    Nfft=length(X);
    
    % vecteur frequence
    f=(0:Nfft-1)*(fs/Nfft);
    
    % parametres
    Nfreq=numel( find(f >= fmin & f < fmax) );   %Nb frequence dans l'intervalle [fmin;fmax]
    NfreqPerBand=floor(Nfreq/ (Nband));          %Nb frequence par bande
    
    % nombre impair de frequence par bande
    if(mod(NfreqPerBand,2)==0)
        NfreqPerBand=NfreqPerBand-1;
    end
    
    % verification du nombre de frequence par bande suffisant
    if (NfreqPerBand<2)
        disp('attention le nombre de bande est trop eleve ou la bande passante est trop petite');
    end
    
    % indice premiere frequence
    offset=find(f >= fmin);                      
    
    % init des matrices en sorties
    X_F=zeros(Nband,ceil((1+Nfft)/2));
    spec_m=zeros(Nband,NfreqPerBand);
    
    % choix de la fenetre
    typeFen='rectwin';
    w = window(typeFen,NfreqPerBand);
    
    % spectres filtres
    for iband=1:Nband
        ind_i=offset(1)+(iband-1)*NfreqPerBand+1;
        ind_s=offset(1)+(iband-1)*NfreqPerBand+NfreqPerBand;
        X_F(iband,ind_i:ind_s)=X(ind_i:ind_s,1).*w; % ajout fenetre modulable
        spec_m(iband,:)=f(ind_i:ind_s);
    end
    
    % ajout de la symetrie frequentielle pour la reconstruction
    if(rem(Nfft,2)~=0)                  %(Attention à la symetrie et à la frequence de Nyquist)
        X_F=[X_F conj(X_F(:,end:-1:2))];
    else
        X_F=[X_F conj(X_F(:,end-1:-1:2))];
    end
    
    %frequence centrale des filtres
    fc=median(spec_m,2); % ou median à verifier
    
    %retour domaine temporel
    x_f=ifft(X_F,[],2);

end

