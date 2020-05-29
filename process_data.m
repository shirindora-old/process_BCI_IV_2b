clear;

% create a list of files to be read
subject = 1:9;
session = 1:3;
file = {};
file_count = 0;
for i = subject
    for j = session
        file_count = file_count + 1;
        file{file_count} = strcat('B0', int2str(i), '0', int2str(j), 'T.gdf');
    end
end

% initialize sampling parameters
freq            = 250; % recording frequency
n_channel       = 3; % number of channels to be extracted
extract_dur     = 4; % duration of extracted signal in seconds

% process each event
x               = zeros(0, 1000, 3);
y               = zeros(0, 1);
trial_count     = 0;
for f = 1:size(file, 2)
    [s, h]                  = sload(file{f}); % load data
    n_events                = size(h.EVENT.TYP, 1); % number of events
    
    for i = 1:n_events
        if (h.EVENT.TYP(i) == 769) || (h.EVENT.TYP(i) == 770)
            event_pos       = h.EVENT.POS(i); % position of the event
            event_end       = event_pos + (extract_dur * freq) - 1; % end of event

            sel_data        = s(event_pos:event_end, 1:n_channel);
            if sum(isnan(sel_data(:))) ~= 0
                continue;
            end
            
            trial_count     = trial_count + 1;
            x(trial_count, :, :) = sel_data;
            
            % save sample class
            if h.EVENT.TYP(i) == 769
                y(trial_count, 1) = 1;
            elseif h.EVENT.TYP(i) == 770
                y(trial_count, 1) = 2;
            end
        end
    end
end

save('x', 'x');
save('y', 'y');