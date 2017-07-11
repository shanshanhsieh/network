clear all;
% All the parameters besides the internal diameter are defined inside the
Cpw = 4.184; %kJ/kgK


% production plant 
plant_node = [1,7];
PUpstream = 1.01325*5; % bar
[num,text,T_supply] = xlsread('network2_input.xlsx','T_Supply_DH');
T_Upstream_array = T_supply(2:end,plant_node(1));

% Soil properties
kSoil = 1.6;   % (W/mK)
TSoil = 283;    % Soil temperature (K)
z = 1;        % Soil thickness (m)

% pipe model
length = 125;  % Length (m)
pipe_roughness = 2e-5; % steel pipe roughness (m)
kInsulant = 0.023; % (W/mK)
%rho0 = 998;  %water density


% Read pipe properties and substation flow rates
edge = xlsread('network2_input.xlsx','Edge_DH');
% node = xlsread('network2_input.xlsx','node');
node_mass_flow = xlsread('network2_input.xlsx','Node_MassFlow_DH');
node_mass_flow(:,1)=[]; % delete the first column
node_mass_flow(:,plant_node) = 0; % set mass flow at plants to zero



Di = zeros(1,size(edge,1)); % inner diameter
Do = zeros(1,size(edge,1)); % outer diameter
Ac = zeros(1,size(edge,1)); % cross section area, inner diameter
Ai = zeros(1,size(edge,1)); % pipe surface area, inner diameter
Ao = zeros(1,size(edge,1)); % pipe surface area, outer diameter
Thi = zeros(1,size(edge,1)); % thickness of insulation
Tho = zeros(1,size(edge,1)); % thickness of soil
for j = 1:size(edge,1)
    Di(j) = edge(j,1);
    Do(j) = edge(j,2);
    Ac(j) = pi*Di(j)^2/4;
    Ai(j) = length * pi * Di(j);
    Ao(j) = length * pi * Do(j);
    Thi(j) = Di(j) / 2 * log(Do(j) / Di(j));
    Tho(j) = Do(j)/2*log(2*z/Do(j) + sqrt((2*z/Do(j))^2 - 1));
end


T_node_supply = zeros(8760,size(node_mass_flow,2));
q_loss_supply = zeros(8760,size(edge,1));
Phi_W_supply = zeros(8760,size(edge,1));
Phi_A_supply = zeros(8760,size(edge,1));
Phi_B_supply = zeros(8760,size(edge,1));
k_supply = zeros(8760,size(edge,1));
%nu_supply = zeros(8760,size(edge,1));
%F_A_supply = zeros(8760,size(edge,1));
%F_B_supply = zeros(8760,size(edge,1));
Nu_A_supply = zeros(8760,size(edge,1));
Nu_B_supply = zeros(8760,size(edge,1));
dP_supply = zeros(8760,1);
load_system('pipelines_network2');
for t=10:12 
    TUpstream = T_Upstream_array{t};
    T_initial = min([T_supply{t+1,:}]);
%     T_initial = min(num(8661,:));  % for t = 8668, read from num to ignore nan 
    TDownstream = mean([T_supply{t+1,:}]); 
    if isnumeric(TUpstream)
        mdot = zeros(1,size(node_mass_flow,2));  
        for j = 1:size(node_mass_flow,2)
            mdot(j) = node_mass_flow(t,j); % mass flow rate {kg/s)
        end

        % Initialization
        % load_system('pipelines_network2');
        max_T_diff = peak2peak([T_supply{t+1,:}]);
        if  max_T_diff > 10
            set_param('pipelines_network2','StopTime','30000')
        else set_param('pipelines_network2','StopTime','8000')
        end
        sim('pipelines_network2');
        %simlog.print  

        % Retrieve values from the Simscape data logging
        Pi(1) = simlog.E0.pipe_model.A.p.series.values* 1e6; % Pa
        Po(1) = simlog.E0.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(1) = simlog.E0.pipe_model.A.T.series.values; % K
        To(1) = simlog.E0.pipe_model.B.T.series.values; % K
        mdot_pipe(1) = simlog.E0.pipe_model.mdot_A.series.values;

        Pi(2) = simlog.E1.pipe_model.A.p.series.values* 1e6; % Pa
        Po(2) = simlog.E1.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(2) = simlog.E1.pipe_model.A.T.series.values; % K
        To(2) = simlog.E1.pipe_model.B.T.series.values; % K
        mdot_pipe(2) = simlog.E1.pipe_model.mdot_A.series.values;

        Pi(3) = simlog.E2.pipe_model.A.p.series.values* 1e6; % Pa
        Po(3) = simlog.E2.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(3) = simlog.E2.pipe_model.A.T.series.values; % K
        To(3) = simlog.E2.pipe_model.B.T.series.values; % K
        mdot_pipe(3) = simlog.E2.pipe_model.mdot_A.series.values;

        Pi(4) = simlog.E3.pipe_model.A.p.series.values* 1e6; % Pa
        Po(4) = simlog.E3.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(4) = simlog.E3.pipe_model.A.T.series.values; % K
        To(4) = simlog.E3.pipe_model.B.T.series.values; % K
        mdot_pipe(4) = simlog.E3.pipe_model.mdot_A.series.values;

        Pi(5) = simlog.E4.pipe_model.A.p.series.values* 1e6; % Pa
        Po(5) = simlog.E4.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(5) = simlog.E4.pipe_model.A.T.series.values; % K
        To(5) = simlog.E4.pipe_model.B.T.series.values; % K
        mdot_pipe(5) = simlog.E4.pipe_model.mdot_A.series.values;

        Pi(6) = simlog.E5.pipe_model.A.p.series.values* 1e6; % Pa
        Po(6) = simlog.E5.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(6) = simlog.E5.pipe_model.A.T.series.values; % K
        To(6) = simlog.E5.pipe_model.B.T.series.values; % K
        mdot_pipe(6) = simlog.E5.pipe_model.mdot_A.series.values;

        Pi(7) = simlog.E6.pipe_model.A.p.series.values* 1e6; % Pa
        Po(7) = simlog.E6.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(7) = simlog.E6.pipe_model.A.T.series.values; % K
        To(7) = simlog.E6.pipe_model.B.T.series.values; % K
        mdot_pipe(7) = simlog.E6.pipe_model.mdot_A.series.values;

        Pi(8) = simlog.E7.pipe_model.A.p.series.values* 1e6; % Pa
        Po(8) = simlog.E7.pipe_model.B.p.series.values* 1e6; % Pa
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
        
        q_loss(1) = mdot_pipe(1) * Cpw * dT(1);
        q_loss(2) = mdot_pipe(2) * Cpw * dT(2);
        q_loss(3) = mdot_pipe(3) * Cpw * dT(3);
        q_loss(4) = mdot_pipe(4) * Cpw * dT(4);   
        q_loss(5) = mdot_pipe(5) * Cpw * dT(5);
        q_loss(6) = mdot_pipe(6) * Cpw * dT(6);
        q_loss(7) = mdot_pipe(7) * Cpw * dT(7);  
        q_loss(8) = mdot_pipe(8) * Cpw * dT(8);

        T_node(1) = simlog.N0.A.T.series.values; % K
        T_node(2) = simlog.N1.A.T.series.values; % K
        T_node(3) = simlog.N2.A.T.series.values; % K
        T_node(4) = simlog.N3.A.T.series.values; % K
        T_node(5) = simlog.N4.A.T.series.values; % K
        T_node(6) = simlog.N5.A.T.series.values; % K
        T_node(7) = simlog.N6.A.T.series.values; % K
        T_node(8) = simlog.N7.A.T.series.values; % K
        T_node(9) = simlog.N8.A.T.series.values; % K
        
        Phi_W(1) = simlog.E0.pipe_model.Q_H.series.values*(-1);
        Phi_W(2) = simlog.E1.pipe_model.Q_H.series.values*(-1);
        Phi_W(3) = simlog.E2.pipe_model.Q_H.series.values*(-1);
        Phi_W(4) = simlog.E3.pipe_model.Q_H.series.values*(-1);
        Phi_W(5) = simlog.E4.pipe_model.Q_H.series.values*(-1);
        Phi_W(6) = simlog.E5.pipe_model.Q_H.series.values*(-1);
        Phi_W(7) = simlog.E6.pipe_model.Q_H.series.values*(-1);
        Phi_W(8) = simlog.E7.pipe_model.Q_H.series.values*(-1);
        
        Phi_A(1) = simlog.E0.pipe_model.Phi_A.series.values;
        Phi_A(2) = simlog.E1.pipe_model.Phi_A.series.values;
        Phi_A(3) = simlog.E2.pipe_model.Phi_A.series.values;
        Phi_A(4) = simlog.E3.pipe_model.Phi_A.series.values;
        Phi_A(5) = simlog.E4.pipe_model.Phi_A.series.values;
        Phi_A(6) = simlog.E5.pipe_model.Phi_A.series.values;
        Phi_A(7) = simlog.E6.pipe_model.Phi_A.series.values;
        Phi_A(8) = simlog.E7.pipe_model.Phi_A.series.values;
        
        Phi_B(1) = simlog.E0.pipe_model.Phi_B.series.values;
        Phi_B(2) = simlog.E1.pipe_model.Phi_B.series.values;
        Phi_B(3) = simlog.E2.pipe_model.Phi_B.series.values;
        Phi_B(4) = simlog.E3.pipe_model.Phi_B.series.values;
        Phi_B(5) = simlog.E4.pipe_model.Phi_B.series.values;
        Phi_B(6) = simlog.E5.pipe_model.Phi_B.series.values;
        Phi_B(7) = simlog.E6.pipe_model.Phi_B.series.values;
        Phi_B(8) = simlog.E7.pipe_model.Phi_B.series.values;
        
                Nu_A_fluid(1) = simlog.E0.pipe_model.Nu_A.series.values;
        Nu_A_fluid(2) = simlog.E1.pipe_model.Nu_A.series.values;
        Nu_A_fluid(3) = simlog.E2.pipe_model.Nu_A.series.values;
        Nu_A_fluid(4) = simlog.E3.pipe_model.Nu_A.series.values;
        Nu_A_fluid(5) = simlog.E4.pipe_model.Nu_A.series.values;
        Nu_A_fluid(6) = simlog.E5.pipe_model.Nu_A.series.values;
        Nu_A_fluid(7) = simlog.E6.pipe_model.Nu_A.series.values;
        Nu_A_fluid(8) = simlog.E7.pipe_model.Nu_A.series.values;
        
        Nu_B_fluid(1) = simlog.E0.pipe_model.Nu_B.series.values;
        Nu_B_fluid(2) = simlog.E1.pipe_model.Nu_B.series.values;
        Nu_B_fluid(3) = simlog.E2.pipe_model.Nu_B.series.values;
        Nu_B_fluid(4) = simlog.E3.pipe_model.Nu_B.series.values;
        Nu_B_fluid(5) = simlog.E4.pipe_model.Nu_B.series.values;
        Nu_B_fluid(6) = simlog.E5.pipe_model.Nu_B.series.values;
        Nu_B_fluid(7) = simlog.E6.pipe_model.Nu_B.series.values;
        Nu_B_fluid(8) = simlog.E7.pipe_model.Nu_B.series.values;
        
        T_wall(1) = simlog.E0.pipe_model.H.T.series.values;
        T_wall(2) = simlog.E1.pipe_model.H.T.series.values;
        T_wall(3) = simlog.E2.pipe_model.H.T.series.values;
        T_wall(4) = simlog.E3.pipe_model.H.T.series.values;
        T_wall(5) = simlog.E4.pipe_model.H.T.series.values;
        T_wall(6) = simlog.E5.pipe_model.H.T.series.values;
        T_wall(7) = simlog.E6.pipe_model.H.T.series.values;
        T_wall(8) = simlog.E7.pipe_model.H.T.series.values;
       
        
        T_fluid(1) = simlog.E0.pipe_model.T.series.values;
        T_fluid(2) = simlog.E1.pipe_model.T.series.values;
        T_fluid(3) = simlog.E2.pipe_model.T.series.values;
        T_fluid(4) = simlog.E3.pipe_model.T.series.values;
        T_fluid(5) = simlog.E4.pipe_model.T.series.values;
        T_fluid(6) = simlog.E5.pipe_model.T.series.values;
        T_fluid(7) = simlog.E6.pipe_model.T.series.values;
        T_fluid(8) = simlog.E7.pipe_model.T.series.values;
        
% only in matlab 2015
%         viscous_friction_A(1) = simlog.E0.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(2) = simlog.E1.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(3) = simlog.E2.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(4) = simlog.E3.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(5) = simlog.E4.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(6) = simlog.E5.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(7) = simlog.E6.pipe_model.viscous_friction_A.series.values;
%         viscous_friction_A(8) = simlog.E7.pipe_model.viscous_friction_A.series.values;
%         
%         viscous_friction_B(1) = simlog.E0.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(2) = simlog.E1.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(3) = simlog.E2.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(4) = simlog.E3.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(5) = simlog.E4.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(6) = simlog.E5.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(7) = simlog.E6.pipe_model.viscous_friction_B.series.values;
%         viscous_friction_B(8) = simlog.E7.pipe_model.viscous_friction_B.series.values;
        
%         T_wall(1) = simlog.E0.pipe_model.W.T.series.values;
%         T_wall(2) = simlog.E1.pipe_model.W.T.series.values;
%         T_wall(3) = simlog.E2.pipe_model.W.T.series.values;
%         T_wall(4) = simlog.E3.pipe_model.W.T.series.values;
%         T_wall(5) = simlog.E4.pipe_model.W.T.series.values;
%         T_wall(6) = simlog.E5.pipe_model.W.T.series.values;
%         T_wall(7) = simlog.E6.pipe_model.W.T.series.values;
%         T_wall(8) = simlog.E7.pipe_model.W.T.series.values;

%         k_fluid(1) = simlog.E0.pipe_model.k.series.values;
%         k_fluid(2) = simlog.E1.pipe_model.k.series.values;
%         k_fluid(3) = simlog.E2.pipe_model.k.series.values;
%         k_fluid(4) = simlog.E3.pipe_model.k.series.values;
%         k_fluid(5) = simlog.E4.pipe_model.k.series.values;
%         k_fluid(6) = simlog.E5.pipe_model.k.series.values;
%         k_fluid(7) = simlog.E6.pipe_model.k.series.values;
%         k_fluid(8) = simlog.E7.pipe_model.k.series.values;
        

        
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

        T_node_supply(t,:) = vec2mat(T_node,size(T_node_supply,2));
        q_loss_supply(t,:) = vec2mat(q_loss,size(q_loss_supply,2));
        Phi_W_supply(t,:) = vec2mat(Phi_W,size(Phi_W_supply,2));
        Phi_A_supply(t,:) = vec2mat(Phi_A,size(Phi_A_supply,2));
        Phi_B_supply(t,:) = vec2mat(Phi_B,size(Phi_B_supply,2));
%         k_supply(t,:) = vec2mat(k_fluid,size(Phi_A_supply,2));
%         nu_supply(t,:) = vec2mat(nu_fluid,size(nu_supply,2));
%         F_A_supply(t,:) = vec2mat(viscous_friction_A,size(F_A_supply,2));
%         F_B_supply(t,:) = vec2mat(viscous_friction_B,size(F_B_supply,2));
        Nu_A_supply(t,:) = vec2mat(Nu_A_fluid,size(Nu_A_supply,2));
        Nu_B_supply(t,:) = vec2mat(Nu_B_fluid,size(Nu_B_supply,2));
        dP_supply(t) = sum(dP);
    else
        T_node_supply(t,:) = str2double(T_supply(t+1,:));
        q_loss_supply(t,:) = 0;
        Phi_W_supply(t,:) = 0;
        Phi_A_supply(t,:) = 0;
        Phi_B_supply(t,:) = 0;
        Nu_A_supply(t,:) = 0;
        Nu_B_supply(t,:) = 0;
        dP_supply(t) = 0;
%         k_supply(t,:) = 0;
%         nu_supply(t,:) = 0;
%         F_A_supply(t,:) = 0;
%         F_B_supply(t,:) = 0;
    end
end
%writetable(T, 'network2_results.csv')
csvwrite('network2_T_node_supply.csv', T_node_supply)
csvwrite('network2_qloss_supply.csv', q_loss_supply)
csvwrite('network2_Phi_W_supply.csv', Phi_W_supply)
csvwrite('network2_Phi_A_supply.csv', Phi_A_supply)
csvwrite('network2_Phi_B_supply.csv', Phi_B_supply)
csvwrite('network2_Nu_A.csv', Nu_A_supply)
csvwrite('network2_Nu_B.csv', Nu_B_supply)
csvwrite('network2_dP_supply.csv', dP_supply)

% csvwrite('network2_k_supply.csv', k_supply)
%csvwrite('network2_nu_supply.csv', nu_supply)
% csvwrite('network2_F_A_supply.csv', F_A_supply)
% csvwrite('network2_F_B_supply.csv', F_B_supply)



