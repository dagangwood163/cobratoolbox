function [charge,chargeWithoutProtons]=getChargeFromInChI(InChI)
%return the charge from a given InChI string
%
%INPUT
% InChI string
%
% OUTPUT
% charge
%
% Ronan Fleming 23 Sept 09
% Updated May 2017 Thomas Pfau

%InChI Charge is defined in the charge layer and can be modified in the
%proton layer. If nothing is defined, the compound is uncharged

%First: Discard any "Reconnected" parts, as those don't influence the
%charges
InChI = regexprep(InChI,'/r.*','');

%Charge Layer: (either at the end or at the start)
q_layer = regexp(InChI,'/q(.*?)/|/q(.*?)$','tokens');
%proton layer
p_layer = regexp(InChI,'/p(.*?)/|/p(.*?)$','tokens');

chargeWithoutProtons = 0;

if ~isempty(q_layer)
    %Get individual charges from splitted reactions. 
    individualCharges = cellfun(@(x) {strsplit(x{1},';')},q_layer);
    %And calculate the charge by evaluating the individual components.
    chargeWithoutProtons = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualCharges);    
end

proton_charges = 0;
if ~isempty(p_layer)
    individualProtons = cellfun(@(x) {strsplit(x{1},';')},p_layer);
    proton_charges = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualProtons);
end
charge = proton_charges + chargeWithoutProtons;


% k = strfind(InChI, '/q');
% if isempty(k)
%     charge=0;
% else
%     %disp(InChI)
%     %check if it has a composite formula
%     indDots=findstr('.',getFormulaFromInChI(InChI));
%     if isempty(indDots)
%         if strcmp(InChI(k+2),'+')
%             %positive charge
%             sgn=1;
%         else
%             sgn=-1;
%         end
%         if length(InChI)<k+4
%             charge=sgn*str2num(InChI(k+3:k+3));
%         else
%             if strcmp(InChI(k+4),'/')
%                 charge=sgn*str2num(InChI(k+3:k+3));
%             else
%                 if length(InChI)<k+5
%                     charge=sgn*str2num(InChI(k+3:k+4));
%                 else
%                     if strcmp(InChI(k+5),'/')
%                         charge=sgn*str2num(InChI(k+3:k+4));
%                     else
%                         disp(InChI)
%                         error('Charge too high')
%                     end
%                 end
%             end
%         end
%     else
%         %todo - cleanup, this code is a bit messy but seems to work
%         totalCharge=0;
%         for d=1:length(indDots)+1
%             while  strcmp(InChI(k+2),';')
%                 k=k+1;
%             end
%             if strcmp(InChI(k+2),'+') || strcmp(InChI(k+2),'-')
%                 if strcmp(InChI(k+2),'+')
%                     %positive charge
%                     sgn=1;
%                 else
%                     sgn=-1;
%                 end
%             else
%                 if strcmp(InChI(k+2),'/')
%                     break;
%                 else
%                     disp(InChI)
%                     sgn=0;
%                     warning(['Not valid charge: ' InChI(k+2)])
%                     break;
%                     %error(InChI(k+2))
%                 end
%             end
%             if length(InChI)<k+4
%                 charge=sgn*str2num(InChI(k+3:k+3));
%                 k=k+2;
%             else
%                 if strcmp(InChI(k+4),'/') || strcmp(InChI(k+4),';')
%                     charge=sgn*str2num(InChI(k+3:k+3));
%                     k=k+2;
%                 else
%                     if length(InChI)<k+5 
%                         charge=sgn*str2num(InChI(k+3:k+4));
%                         k=k+3;
%                     else
%                         if strcmp(InChI(k+5),'/')  || strcmp(InChI(k+5),';')
%                             charge=sgn*str2num(InChI(k+3:k+4));
%                             k=k+3;
%                         else
%                             disp(InChI)
%                             error('Charge too high')
%                         end
%                     end
%                 end
%             end
%             d=d+1;
%             totalCharge=totalCharge+charge;
%         end
%         charge=totalCharge;
%     end
% end

%Also look at the proton layer (removed protons, change the charge as well)

