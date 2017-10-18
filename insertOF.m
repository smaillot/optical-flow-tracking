function Out=insertOF(Im,flow,mult,xspace,yspace)
    s=size(Im);
    X=repmat(1:s(2),s(1),1); % x coordinates
    Y=repmat((1:s(1))',1,s(2)); % y coordinates
    Z=X+i*Y;
    Vz=flow.Vx+i*flow.Vy;
    Z=Z(1:xspace:end,1:yspace:end); % resize
    Vz=Vz(1:xspace:end,1:yspace:end);
    s=size(Z);
    lines=[reshape(real(Z),prod(size(Z)),1) reshape(imag(Z),prod(size(Z)),1)]; % starting point of vectors
    lines=[lines lines]; % ending points
    lines(:,3)=lines(:,3)+reshape(real(Vz),prod(size(Vz)),1); % setting ending points
    lines(:,4)=lines(:,4)+reshape(imag(Vz),prod(size(Vz)),1);
    Out=insertShape(Im,'line',lines,'LineWidth',1,'Opacity',0.5,'Color','red');
end