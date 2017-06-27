function standardised = canonicalRxn(rxnFile, mappedDir, standardDir)
% Standarize atom mapped RXNS files into a canonical format. ChemAxon
% installed is required (needed to compute the atom transition network)
%
% USAGE:
%
%    standardised = canonicalRxn(rxnFile, mappedDir, standardDir)
%
% INPUTS:
%     rxnFile       Name of the RXN file to standarize.
%     mappedDir     Path to directory containg the RXN files with atom
%                   mappings.
%     standardDir	Path to directory containg the standard RXN files
%                   (generated by obtainAtomMappingsRDT function).
%
% OUTPUTS:
%     standardised  Logical value indicating if the RXN file is balanced
%                   or not (true, or false).
%     A standarised RXN file in: 'mappedDir/rxnFile.rxn'
%
% EXAMPLE:
%
%    rxnFile = 'DOPACCL.rxn';
%    mappedDir = ['mapped' filesep];
%    standardDir = ['standard' filesep];
%    standardised = canonicalRxn(rxnFile, mappedDir, standardDir)
%
% .. Author: - German A. Preciat Gonzalez 25/05/2017

separatedMet = false;
rxnFlieVersion = 2000;
balanced = false;

% Add RXN indentifier and formula deleted by RDT algorithm
mappedFile = regexp( fileread([mappedDir filesep rxnFile]), '\n', 'split')';
standardFile = regexp( fileread([standardDir filesep rxnFile]), '\n', 'split')';
mappedFile{4}=standardFile{4};
mappedFile{2}=standardFile{2};
begmolMapped=strmatch('$MOL',mappedFile);
fid2 = fopen([mappedDir filesep rxnFile], 'w');
fprintf(fid2, '%s\n', mappedFile{:});
fclose(fid2);

% Arrange RXN files acording to the formula
sortRDTfiles([mappedDir filesep rxnFile])

% Canonicalise predictions
% convert smiles
command = ['molconvert smiles ' mappedDir filesep rxnFile ' -o '  mappedDir filesep rxnFile(1:end-4) '.smiles'];
[status, result] = system(command);
if status ~= 0
    fprintf(result);
    error('Command %s could not be run.\n', command);
end

% convert rxn
command = ['molconvert rxn ' mappedDir filesep rxnFile(1:end-4) '.smiles' ' -o ' mappedDir filesep rxnFile];
[status, result] = system(command);
if status ~= 0
    fprintf(result);
    error('Command %s could not be run.\n', command);
end
delete([mappedDir filesep rxnFile(1:end-4) '.smiles'])


% Add missing data
mappedFile = regexp( fileread([mappedDir filesep rxnFile]), '\n', 'split')';
if ~isequal(mappedFile{1},'$RXN V3000')
    if numel(strmatch('$MOL',mappedFile)) == numel(begmolMapped)
        mappedFile{4}=standardFile{4};
        mappedFile{2}=standardFile{2};
        begmolMapped=strmatch('$MOL',mappedFile);
        begmolStandard=strmatch('$MOL',standardFile);
        for j=1:length(begmolMapped)
            mappedFile{begmolMapped(j)+1}=standardFile{begmolStandard(j)+1};
            mappedFile{begmolMapped(j)+3}=standardFile{begmolStandard(j)+3};
        end
        fid2 = fopen([mappedDir filesep rxnFile], 'w');
        fprintf(fid2, '%s\n', mappedFile{:});
        fclose(fid2);
        balanced = acsendingAtomMaps([mappedDir filesep rxnFile]);
    else
        separatedMet = true;
    end
else
    rxnFlieVersion = 3000;
end

if balanced == true && separatedMet == false && rxnFlieVersion == 2000
    standardised = true;
else
    standardised = false;
end
