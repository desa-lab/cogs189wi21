% perform 2-class CSP on input data
%
% INPUTS
% input_data: Data divided into classes by cell array or matrix form
%                each cell contains - N cells with CxT matrices
%                each matrix is size CxTxN
%                (C:# channels, T: # samples, N: # trials)
% varagin: various parameters for CSP
%   | csp_dim | regularization parameter |...
%             
%
% OUTPUTS
% csp_coeff: result of CSP analysis(output varies by csp type)
%            (n_csp by n_channel) matrix
%            for filtering do: csp_coeff*X
%
% 02/06/20: modified by Kueida

function [ csp_coeff all_coeff] = csp_analysis(input_data, varargin)


  if(nargin < 1)
      disp('Error: Incorrect number of input variables.')
      return
  end

  % extract useful values
  n_classes = length(input_data);

  % if input_data has matrix format change to cell format
  if(~isstruct(input_data))
      if(~iscell(input_data{1}))
          input_classes = cell(1,n_classes);
          for class = 1:n_classes
              input_classes{class} = mat_to_cell(input_data{class});
          end
      else
          input_classes = input_data;
      end
      
      if (length(input_classes) ~= 2)
          disp('Must have 2 classes for CSP!')
          return
      end

  n_classes = length(input_classes);

  end

  csp_dim = varargin{1};
  
  % get parameters
  if(nargin < 3)
      C = 0;
  elseif(nargin == 3)
      C = varargin{2};
  else
      disp('Error: Incorrect number of input variables.')
      return
  end
    
  % if input_data has matrix format change to cell format
  if(~iscell(input_data{1}))
      input_classes = cell(1,n_classes);
      for class = 1:n_classes
          input_classes{class} = mat_to_cell(input_data{class});
      end
  else
      input_classes = input_data;
  end
    
  [ n_channels n_samples ]  = size(input_classes{1}{1});

  n_trials = zeros(1,n_classes);

  for class = 1:n_classes
      n_trials(class) = length(input_classes{class});
  end

  cov_classes = cell(1,n_classes);

  for i = 1:n_classes
      for j = 1:n_trials(i)
          cov_classes{i}{j} = cov(input_classes{i}{j}',1)/trace(cov(input_classes{i}{j}',1));
      end
  end

  R = cell(1,n_classes);

  for i = 1:n_classes
      R{i} = zeros(n_channels, n_channels);
      for j = 1:n_trials(i)
          R{i} = R{i}+cov_classes{i}{j};
      end
      R{i} = R{i}/n_trials(i);
  end

  Rsum = R{1} + R{2};

  for i = 1:n_classes
      d_C = mean(diag(Rsum)) * C;
      R{i} = R{i} + d_C*eye(n_channels);
  end
  %R{1} = R{1}/trace(R{1});
  %R{2} = R{2}/trace(R{2});
  Rsum = R{1} + R{2};

  % Regularize the common Cov matrix(L2 regularization)
  % if C=0, normal CSP


  % find the rank of Rsum
  rank_Rsum = rank(Rsum);

  % do an eigenvector/eigenvalue decomposition
  [V, D] = eig(Rsum);

  if(rank_Rsum < n_channels)
  %     disp(['pre_CSP_train: WARNING -- reduced rank data']);

      % keep only the non-zero eigenvalues and eigenvectors
      d = diag(D);
      d = d(end - rank_Rsum+ 1 : end);
      D = diag(d);

      V = V(:, end - rank_Rsum + 1 : end);

      % create the whitening transform
      W_T = D^(-.5) * V';

  else

      % create the whitening transform
      W_T = D^(-.5) * V';

  end



  % Whiten Data Using Whiting Transform
  for k = 1:n_classes
      S{k} = W_T * R{k} * W_T';

  end

  %generalized eigenvectors/values
  [B, D] = eig(S{1},S{2});
  % Simultanous diagonalization
  % Should be equivalent to [B,D]=eig(S{1});

  %verify algorithim
  %disp('test1:Psi{1}+Psi{2}=I')
  %Psi{1}+Psi{2}

  %sort
  [D, ind]=sort(diag(D), 'descend');
  B = B(:,ind);

  %Resulting Projection Matrix-these are the spatial filter coefficients
  % result = (W*B)'
  result = B'*W_T;

  % resort CSP coefficients
  dimm = n_classes*csp_dim;

  [m n] = size(result);

  %check for valid dimensions
  if(m<dimm)
      disp('Cannot reduce to a higher dimensional space!');
      return
  end

  %instantiate filter matrix
  csp_coeff = zeros(dimm,n);

  % create the n-dimensional filter by sorting
  % each row is a filter
  i=0;
  for d = 1:dimm

      if(mod(d,2)==0)
          csp_coeff(d,:) = result(m-i,:);
          i=i+1;
      else
          csp_coeff(d,:) = result(1+i,:);
      end

  end
   
  all_coeff = result';

end
    
    