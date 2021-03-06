classdef batch
    properties
        batteries = struct('policy', ' ', 'barcode', ' ', 'cycles', ...
            struct('discharge_dQdVvsV', struct('V', [], 'dQdV', []), ...
            'Qvst', struct('t', [], 'Q', [], 'C', []), 'VvsQ', struct('V', [], ...
            'Q', []), 'TvsQ', struct('T', [], 'Q', [])), ...
            'summary', struct('cycle', [], 'QDischarge', [], 'QCharge', ...
            [], 'IR', [], 'Tmax', [], 'Tavg', [], 'Tmin', [], ...
            'chargetime', []));
        contour_plot = [];
    end
    methods
        
    end
end