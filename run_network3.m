clear all;
% All the parameters besides the internal diameter are defined inside the
T_initial = 350; %K


% production plant
TUpstream = 338.25735; % Plant Supply temperature (K)
TDownstream = 60 + 273.15; 
PUpstream = 1.01325*5; % bar

% Soil properties
kSoil = 1.6;   % (W/mK)
TSoil = 283;    % Soil temperature (K)
z = 1;        % Soil thickness (m)

% pipe model
length = 125;  % Length (m)
pipe_roughness = 2e-5; % steel pipe roughness (m)
kInsulant = 0.023; % (W/mK)
%rho0 = 998;  %water density

plant_node = 1;

edge = xlsread('network3_input.xlsx','edge');
node = xlsread('network3_input.xlsx','node');
node_mass_flow = xlsread('Node_MassFlow_DH.csv');
node_mass_flow(:,1)=[]; % delete the first column
node_mass_flow(:,plant_node) = 0; % set mass flow at plants to zero

% intializing parameters
Di = zeros(1,size(edge,1)); % inner diameter
Do = zeros(1,size(edge,1)); % outer diameter
Ac = zeros(1,size(edge,1)); % cross section area, inner diameter
Ai = zeros(1,size(edge,1)); % pipe surface area, inner diameter
Ao = zeros(1,size(edge,1)); % pipe surface area, outer diameter
Thi = zeros(1,size(edge,1)); % thickness of insulation
Tho = zeros(1,size(edge,1)); % thickness of soil
% read parameters
for j = 1:size(edge,1)
    Di(j) = edge(j,1);
    Do(j) = edge(j,2);
    Ac(j) = pi*Di(j)^2/4;
    Ai(j) = length * pi * Di(j);
    Ao(j) = length * pi * Do(j);
    Thi(j) = Di(j) / 2 * log(Do(j) / Di(j));
    Tho(j) = Do(j)/2*log(2*z/Do(j) + sqrt((2*z/Do(j))^2 - 1));
end
for t = 80
    % read node mass flow at each time-step
    mdot = zeros(1,size(node_mass_flow,2));  
    for j = 1:size(mdot,2)
        mdot(j) = node_mass_flow(t,j); % mass flow rate {kg/s)
    end

    % Initialization
    load_system('pipelines_network3');
    sim('pipelines_network3');
    % simlog.print  

    % Retrieve values from the Simscape data logging
    Pi(1) = simlog.E0.pipe_model.A.p.series.values* 1e5; % Pa
    Po(1) = simlog.E0.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(1) = simlog.E0.pipe_model.A.T.series.values; % K
    To(1) = simlog.E0.pipe_model.B.T.series.values; % K
    mdot_pipe(1) = simlog.E0.pipe_model.mdot_A.series.values;

    Pi(2) = simlog.E1.pipe_model.A.p.series.values* 1e5; % Pa
    Po(2) = simlog.E1.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(2) = simlog.E1.pipe_model.A.T.series.values; % K
    To(2) = simlog.E1.pipe_model.B.T.series.values; % K
    mdot_pipe(2) = simlog.E1.pipe_model.mdot_A.series.values;

    Pi(3) = simlog.E2.pipe_model.A.p.series.values* 1e5; % Pa
    Po(3) = simlog.E2.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(3) = simlog.E2.pipe_model.A.T.series.values; % K
    To(3) = simlog.E2.pipe_model.B.T.series.values; % K
    mdot_pipe(3) = simlog.E2.pipe_model.mdot_A.series.values;

    Pi(4) = simlog.E3.pipe_model.A.p.series.values* 1e5; % Pa
    Po(4) = simlog.E3.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(4) = simlog.E3.pipe_model.A.T.series.values; % K
    To(4) = simlog.E3.pipe_model.B.T.series.values; % K
    mdot_pipe(4) = simlog.E3.pipe_model.mdot_A.series.values;

    Pi(5) = simlog.E4.pipe_model.A.p.series.values* 1e5; % Pa
    Po(5) = simlog.E4.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(5) = simlog.E4.pipe_model.A.T.series.values; % K
    To(5) = simlog.E4.pipe_model.B.T.series.values; % K
    mdot_pipe(5) = simlog.E4.pipe_model.mdot_A.series.values;

    Pi(6) = simlog.E5.pipe_model.A.p.series.values* 1e5; % Pa
    Po(6) = simlog.E5.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(6) = simlog.E5.pipe_model.A.T.series.values; % K
    To(6) = simlog.E5.pipe_model.B.T.series.values; % K
    mdot_pipe(6) = simlog.E5.pipe_model.mdot_A.series.values;

    Pi(7) = simlog.E6.pipe_model.A.p.series.values* 1e5; % Pa
    Po(7) = simlog.E6.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(7) = simlog.E6.pipe_model.A.T.series.values; % K
    To(7) = simlog.E6.pipe_model.B.T.series.values; % K
    mdot_pipe(7) = simlog.E6.pipe_model.mdot_A.series.values;

    Pi(8) = simlog.E7.pipe_model.A.p.series.values* 1e5; % Pa
    Po(8) = simlog.E7.pipe_model.B.p.series.values* 1e5; % Pa
    Ti(8) = simlog.E7.pipe_model.A.T.series.values; % K
    To(8) = simlog.E7.pipe_model.B.T.series.values; % K
    mdot_pipe(8) = simlog.E7.pipe_model.mdot_A.series.values;

    dP(1) = Pi(1)-Po(1);
    dP(2) = Pi(2)-Po(2);
    dP(3) = Pi(3)-Po(3);
    dP(4) = Pi(4)-Po(4);
    dP(5) = Pi(5)-Po(5);
    dP(6) = Pi(6)-Po(6);
    dP(7) = Pi(7)-Po(7);
    dP(8) = Pi(8)-Po(8);

    dT(1) = Ti(1)-To(1);
    dT(2) = Ti(2)-To(2);
    dT(3) = Ti(3)-To(3);
    dT(4) = Ti(4)-To(4);
    dT(5) = Ti(5)-To(5);
    dT(6) = Ti(6)-To(6);
    dT(7) = Ti(7)-To(7);
    dT(8) = Ti(8)-To(8);

    % E = {'E0', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'};
    % Pi = zeros(1,size(edge,1));
    % Po = zeros(1,size(edge,1));
    % Ti = zeros(1,size(edge,1));
    % To = zeros(1,size(edge,1));
    % for i=1:8
    %     E = genvarname({E{i}});
    %     Pi(i) = simlog.E(i).pipe_model.A.p.series.values* 1e5; % Pa
    %     Po(i) = simlog.E(i).pipe_model.B.p.series.values* 1e5; % Pa
    %     Ti(i) = simlog.E(i).pipe_model.A.T.series.values; % K
    %     To(i) = simlog.E(i).pipe_model.B.T.series.values; % K
    % end

    T = table(transpose(Di), transpose(Do), transpose(mdot_pipe), transpose(Pi), transpose(Po), transpose(dP), transpose(Ti),transpose(To), transpose(dT),...
    'VariableNames', {'Di' 'Do' 'mdot_pipe' 'Pi' 'Po' 'dP' 'Ti' 'To' 'dT'});
end
writetable(T, 'network3_results.csv')




