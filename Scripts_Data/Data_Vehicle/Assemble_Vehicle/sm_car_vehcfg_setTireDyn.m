function Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,tiredyn_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
%VDatabase = evalin('base','VDatabase');

% Select fieldname for front/rear
if(strcmpi(frontRear,'front'))
    tirefield = 'TireF';
elseif(strcmpi(frontRear,'rear'))
    tirefield = 'TireR';
end

% Find field that has tire model type
if(sum(strcmp(Vehicle.Chassis.(tirefield).class.Value,{'Tire2x'})))
    % Axle with multiple tires - switch for various classes
    switch Vehicle.Chassis.(tirefield).class.Value
        case 'Tire2x'
            % Assumes inner and outer tires have same setting
            tireType = Vehicle.Chassis.(tirefield).TireInner.class.Value;
    end
else
    % Case with single tire
    tireType = Vehicle.Chassis.(tirefield).class.Value;
end

% Set dynamics setting based on tire model type
% Tire models use different names for same option
if (strcmpi(tireType,'MFEval'))
    switch tiredyn_opt
        case 'steady', dyn_class = '1 steady state';
        case 'lintra', dyn_class = '2 linear transients';
        case 'nonlin', dyn_class = '3 non-linear transients';
        case 'ring'
            dyn_class = '1 steady state';
            warning('sm_car:Vehicle_Config:TireDynamics',...
                ['Tire type ' tireType ' does not support dynamics option ' tiredyn_opt '.']);
    end
elseif(strcmpi(tireType,'Delft'))
    switch tiredyn_opt
        case 'steady', dyn_class = '(xx0x) steady-state';
        case 'lintra', dyn_class = '(xx1x) relaxation behaviour';
        case 'nonlin', dyn_class = '(xx2x) relaxation behaviour - non-linear';
        case 'ring',   dyn_class = '(xx3x) rigid ring';
        case 'ringic', dyn_class = '(xx4x) rigid ring + initial statics';
    end
elseif(strcmpi(tireType,'MFSwift'))
    switch tiredyn_opt
        case 'steady', dyn_class = '(xxx0x) steady-state';
        case 'lintra', dyn_class = '(xxx1x) relaxation behaviour';
        case 'nonlin', dyn_class = '(xxx2x) relaxation behaviour - non-linear';
        case 'ring',   dyn_class = '(xxx3x) rigid-ring';
        otherwise
            dyn_class = '(xxx0x) steady-state';
            warning('sm_car:Vehicle_Config:TireDynamics',...
                ['Tire type ' tireType ' does not support dynamics option ' tiredyn_opt '.']);
    end
end

% Set field for dynamics setting
if(sum(strcmp(Vehicle.Chassis.(tirefield).class.Value,{'Tire2x'})))
    % Axle with multiple tires - switch for various classes
    switch Vehicle.Chassis.(tirefield).class.Value
        case 'Tire2x'
            % Assumes inner and outer tires have same setting
            Vehicle.Chassis.(tirefield).TireInner.Dynamics.Value = dyn_class;
            Vehicle.Chassis.(tirefield).TireOuter.Dynamics.Value = dyn_class;
    end
else
    % Case with single tire
    Vehicle.Chassis.(tirefield).Dynamics.Value = dyn_class;
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end