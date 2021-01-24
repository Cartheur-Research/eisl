//----------------DeepPipe2 my implementation of Deep-Learning in Elixir-----------
//   I will port DeepPipe2 code from Elixir to Easy-ISLisp in 2021
/*


  
  
  
  __global__ void sigmoid_kernel(float *a, float *b, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  b[tid] = SIGMOID(a[tid]);
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  static ERL_NIF_TERM
  activate_sigmoid(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n;
	  float *a,*b;
	  float *dev_a, *dev_b;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
  
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  sigmoid_kernel << <128, 128 >> >(dev_a, dev_b, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(b, dev_b, n * sizeof(float), cudaMemcpyDeviceToHost));
	  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
  
	  return(b_bin);
  }
  
  
  
  __global__ void tanh_kernel(float *a, float *b, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {
		  b[tid] = tanh(a[tid]);
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  
  static ERL_NIF_TERM
  activate_tanh(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n;
	  float *a,*b;
	  float *dev_a, *dev_b;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
  
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  tanh_kernel << <128, 128 >> >(dev_a, dev_b, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(b, dev_b, n * sizeof(float), cudaMemcpyDeviceToHost));
	  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
  
	  return(b_bin);
  }
  
  
  
  __global__ void relu_kernel(float *a, float *b, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  if(a[tid] >= 0)
			  b[tid] = a[tid];
		  else 
			  b[tid] = 0.0;
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  
  static ERL_NIF_TERM
  activate_relu(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n;
	  float *a,*b;
	  float *dev_a, *dev_b;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  relu_kernel << <128, 128 >> >(dev_a, dev_b, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(b, dev_b, n * sizeof(float), cudaMemcpyDeviceToHost));
	  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
  
	  return(b_bin);
  }
  
  static ERL_NIF_TERM
  activate_softmax(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int r1, c1, n, i, j, k;
	  float *a,*b;
	  float max,sum,delta;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  n = r1*c1;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
	  //calculate softmax
	  delta = 0.01;
	  for(i=0;i<r1;i++){
		  for(j=0;j<c1;j++){
			  max = -3.402823e38;
			  for(k=0;k<c1;k++){
				  if(a[IDX2C(i,k,r1)] > max)
					  max = a[IDX2C(i,k,r1)];
			  }
			  sum = 0.0;
			  for(k=0;k<c1;k++){
				  sum = sum + exp(a[IDX2C(i,k,r1)] - max);
			  }
			  b[IDX2C(i,j,r1)] = exp(a[IDX2C(i,j,r1)] - max) / (sum+delta);
			  
		  }
	  }
  
  
	  return(b_bin);
  }
  
  
  
  __global__ void differ_sigmoid_kernel(float *a, float *b, float *c, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  
		  c[tid] = a[tid] * ((1 - SIGMOID(b[tid])) * SIGMOID(b[tid]));
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  static ERL_NIF_TERM
  differ_sigmoid(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin, b_bin;
	  ERL_NIF_TERM  c_bin;
	  int n;
	  float *a,*b,*c;
	  float *dev_a, *dev_b, *dev_c;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n * sizeof(float), &c_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  differ_sigmoid_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(c, dev_c, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
  
	  return(c_bin);
  }
  
  
  __global__ void differ_tanh_kernel(float *a, float *b, float *c, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  c[tid] = a[tid] * (1/(cosh(b[tid]) * cosh(b[tid])));
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  static ERL_NIF_TERM
  differ_tanh(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin, b_bin;
	  ERL_NIF_TERM  c_bin;
	  int n;
	  float *a,*b,*c;
	  float *dev_a, *dev_b, *dev_c;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
	  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n * sizeof(float), &c_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  differ_tanh_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(c, dev_c, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
  
	  return(c_bin);
  }
  
  
  
  __global__ void differ_relu_kernel(float *a, float *b, float *c, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  if(b[tid] >= 0)
			  c[tid] = a[tid];
		  else 
			  c[tid] = 0.0;
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  static ERL_NIF_TERM
  differ_relu(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin, b_bin;
	  ERL_NIF_TERM  c_bin;
	  int n;
	  float *a,*b,*c;
	  float *dev_a, *dev_b, *dev_c;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,4);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n * sizeof(float), &c_bin);
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  differ_relu_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(c, dev_c, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
  
	  return(c_bin);
  }
  
  
  __global__ void smult_kernel(float d, float *a, float *b, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {
		  b[tid] = d * a[tid];
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  
  static ERL_NIF_TERM
  smult1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n;
	  float *a,*b;
	  float *dev_a, *dev_b;
	  double s;
  
	  if (!enif_get_double(env, argv[0], &s)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &n)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  smult_kernel << <128, 128 >> >((float)s,dev_a, dev_b, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(b, dev_b, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
  
	  return(b_bin);
  }
  
  
  static ERL_NIF_TERM
  trace1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  result;
	  int r1, c1, i, j;
	  float *a;
	  float trace;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  a = (float *) a_bin.data;
	  
	  trace = 0.0;
	  for(i=0;i<r1;i++){
		  for(j=0;j<c1;j++){
			  if(i==j)
				  trace = trace + a[IDX2C(i,j,r1)];
		  }
	  }
  
	  result = enif_make_double(env,trace);
  
	  return(result);
  }
  
  
  static ERL_NIF_TERM
  mean_square(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  ERL_NIF_TERM  result;
	  int r1, c1, i, j;
	  float *a, *b;
	  float d,s;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &b_bin )) return enif_make_int(env,4);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
  
	  s = 0.0;
	  for(i=0;i<r1;i++){
		  for (j=0;j<c1;j++){
			  d = a[IDX2C(i,j,r1)] -  b[IDX2C(i,j,r1)];
			  s = s + d*d;            
		  }
	  } 
	  s = s / (2.0*(float(r1)));
	  result = enif_make_double(env,s);
	  return(result);
  }
  
  static ERL_NIF_TERM
  cross_entropy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  ERL_NIF_TERM  result;
	  int r1, c1, i, j;
	  float *a, *b;
	  float d,s,delta;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &b_bin )) return enif_make_int(env,4);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
  
	  
	  delta = 1e-7;
	  s = 0.0;
	  for(i=0;i<r1;i++){
		  for (j=0;j<c1;j++){
			  d = a[IDX2C(i,j,r1)] + delta;
			  s = s + b[IDX2C(i,j,r1)] * log(d);
		  }
	  }
	  s = -1.0 * s / (float)r1;
	  result = enif_make_double(env,s);
	  return(result);
  }
  
  
  
  
  
  static ERL_NIF_TERM
  elt1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  result;
	  int r1, c1, i, j;
	  float *a;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &i)) enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &j)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &a_bin )) return enif_make_int(env,5);
	  a = (float *) a_bin.data;
	  
	  result = enif_make_double(env,(double)a[IDX2C(i,j,r1)]);
  
	  return(result);
  }
  
  static ERL_NIF_TERM
  set1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int r1, c1, n, i, j, x, y;
	  float *a,*b;
	  double val;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &x)) return enif_make_int(env,4);
	  if (!enif_get_int(env, argv[4], &y)) return enif_make_int(env,5);
	  if (!enif_get_double(env, argv[5], &val)) return enif_make_int(env,6);
  
  
	  n = r1*c1;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
	  for(i=0;i<r1;i++){
		  for(j=0;j<c1;j++){
			  if(i==x && j==y)
				  b[IDX2C(i,j,r1)] = (float)val;
			  else 
				  b[IDX2C(i,j,r1)] = a[IDX2C(i,j,r1)];
		  }
	  }
  
  
	  return(b_bin);
  }
  
  static ERL_NIF_TERM
  add_diff1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int r1, c1, n, i, j, x, y;
	  float *a,*b;
	  double val;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &x)) return enif_make_int(env,4);
	  if (!enif_get_int(env, argv[4], &y)) return enif_make_int(env,5);
	  if (!enif_get_double(env, argv[5], &val)) return enif_make_int(env,6);
  
  
	  n = r1*c1;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
	  for(i=0;i<r1;i++){
		  for(j=0;j<c1;j++){
			  if(i==x && j==y)
				  b[IDX2C(i,j,r1)] = a[IDX2C(i,j,r1)] + (float)val;
			  else 
				  b[IDX2C(i,j,r1)] = a[IDX2C(i,j,r1)];
		  }
	  }
  
  
	  return(b_bin);
  }
  
  static ERL_NIF_TERM
  add_diff2(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n1, c1, h1, w1, n, i, j, k, l, n2, c2, h2, w2;
	  float *a,*b;
	  double val;
  
	  if (!enif_get_int(env, argv[0], &n1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &h1)) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &w1)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &a_bin )) return enif_make_int(env,5);
	  if (!enif_get_int(env, argv[5], &n2)) return enif_make_int(env,6);
	  if (!enif_get_int(env, argv[6], &c2)) return enif_make_int(env,7);
	  if (!enif_get_int(env, argv[7], &h2)) return enif_make_int(env,8);
	  if (!enif_get_int(env, argv[8], &w2)) return enif_make_int(env,9);
	  if (!enif_get_double(env, argv[9], &val)) return enif_make_int(env,10);
  
  
	  n = n1*c1*h1*w1;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
  
	  
	  for(i=0;i<n1;i++){
		  for(j=0;j<c1;j++){
			  for(k=0;k<h1;k++){
				  for(l=0;l<w1;l++){
					  if(i==n2 && j==c2 && k==h2 && l==w2){
						  b[IDX4C(i,j,k,l,c1,h1,w1)] = a[IDX4C(i,j,k,l,c1,h1,w1)] + (float)val;
					  }
					  else {
						  b[IDX4C(i,j,k,l,c1,h1,w1)] = a[IDX4C(i,j,k,l,c1,h1,w1)];
					  }
				  }
			  }
		  }
	  }
  
  
	  return(b_bin);
  }
  
  
  
  static ERL_NIF_TERM
  average1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int r1, c1, i, j;
	  float *a,*b;
	  float sum;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, c1 * sizeof(float), &b_bin);
  
	  for(j=0;j<c1;j++){
		  sum = 0.0;
		  for(i=0;i<r1;i++){
			  sum = sum + a[IDX2C(i,j,r1)];
		  }
		  b[j] = sum / (float)r1;
	  }
  
  
	  return(b_bin);
  }
  
  /*
  1st arg row-size of matrix
  2nd arg col-size of matrix
  3rd arg matrix data binary
  */
  
  
  static ERL_NIF_TERM
  sum1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  result;
	  int r1, c1, i, j;
	  float *a;
	  float sum;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  a = (float *) a_bin.data;
	  
	  sum = 0.0;
	  for(i=0;i<r1;i++){
		  for(j=0;j<c1;j++){
			  sum = sum + a[IDX2C(i,j,r1)];
		  }
	  }
  
	  result = enif_make_double(env,sum);
  
	  return(result);
  }
  
  /*
  transfer 2 DIm matrix to list 
  */
  static ERL_NIF_TERM
  to_list1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  head,list;
	  int r1, c1, i, j;
	  float *a;
  
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  a = (float *) a_bin.data;
  
	  
	  list = enif_make_list(env, 0);
	  for(i=r1-1;i>=0;i--){
		  for(j=c1-1;j>=0;j--){
			  head = enif_make_double(env,(double)a[IDX2C(i,j,r1)]);
			  list = enif_make_list_cell(env,head,list);
		  }
	  }
  
	  return(list);
  }
  /*
  transfer 3 DIm matrix to list
  */
  
  static ERL_NIF_TERM
  to_list2(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  head,list;
	  int c, h, w, i, j, k;
	  float *a;
  
	  if (!enif_get_int(env, argv[0], &c)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &h)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &w)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &a_bin )) return enif_make_int(env,4);
	 
	  a = (float *) a_bin.data;
	  
	  list = enif_make_list(env, 0);
	  for(i=c-1;i>=0;i--){
		  for(j=h-1;j>=0;j--){
			  for(k=w-1;k>=0;k--){
				  head = enif_make_double(env,(double)a[IDX3C(i,j,k,h,w)]);
				  list = enif_make_list_cell(env,head,list);
			  }
		  }
	  }
  
	  return(list);
  }
  /*
  transfer 4 DIm matrix to list
  */
  static ERL_NIF_TERM
  to_list3(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  head,list;
	  int n, c, h, w, i, j, k, l;
	  float *a;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &h)) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &w)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &a_bin )) return enif_make_badarg(env);
	  a = (float *) a_bin.data;
  
	  
	  list = enif_make_list(env, 0);
	  for(i=n-1;i>=0;i--){
		  for(j=c-1;j>=0;j--){
			  for(k=h-1;k>=0;k--){
				  for(l=w-1;l>=0;l--){
					  head = enif_make_double(env,(double)a[IDX4C(i,j,k,l,c,h,w)]);
					  list = enif_make_list_cell(env,head,list);
				  }
			  }
		  }
	  }
  
	  return(list);
  }
  
  __global__ void dropout1_kernel(float *a, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {
		  a[tid] = 1.0;
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  /*
  1st arg size of mask tensor
  2nd arg rate of dropout
  
  return mask tensor
  element of mask tensor is basicaly 1.0.
  element of dropout rate is 0.0.
  when forward and backward, generate Hadamard product with mask tensor
  */
  static ERL_NIF_TERM
  dropout1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ERL_NIF_TERM  a_bin;
	  int n,count,i,j;
	  float *a,*dev_a;
	  double dropout_rate;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_get_double(env, argv[1], &dropout_rate)) return enif_make_int(env,2);
  
	  a = (float *) enif_make_new_binary(env, n * sizeof(float), &a_bin);
  
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  dropout1_kernel << <128, 128 >> >(dev_a, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(a, dev_a, n * sizeof(float), cudaMemcpyDeviceToHost));
  
  
	  // dropout
	  count = (int)(double(n)*dropout_rate);
	  for(i=0;i<count;i++){
		  j = rand() % n;
		  a[j] = 0.0;
	  }
  
	  // free 
	  cudaFree(dev_a);
  
	  return(a_bin);
  }
  
  
  __global__ void sgd1_kernel(float *a, float *b, float *c, float lr, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {
		  c[tid] = a[tid] - b[tid]*lr;
		  tid += blockDim.x * gridDim.x;
	  }
  }
  /*
  w - g*lr
  w is weight matrix.
  g is gradient matrix.
  when element of w is zero result is zero. This means dropout.
  return updated weight matrix.
  
  1st arg is size of vectorized matrix
  2nd arg is weight matrix or tensor
  3rd arg is gradient matrix or tensor
  4th arg is learning rate
  */
  static ERL_NIF_TERM
  sgd1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin, b_bin;
	  ERL_NIF_TERM  c_bin;
	  int n;
	  float *a,*b,*c,*dev_a, *dev_b, *dev_c;
	  float lr;
	  double learning_rate;
  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
	  if (!enif_get_double(env, argv[3], &learning_rate)) return enif_make_int(env,4);
  
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n * sizeof(float), &c_bin);
	  lr = (float) learning_rate;
  
		  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
  
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
  
	  sgd1_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, lr, n);
  
	  // copy to host c from GPU dev_c
	  CHECK(cudaMemcpy(c, dev_c, n * sizeof(float), cudaMemcpyDeviceToHost));
  
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);    
	  cudaFree(dev_c);
  
	  return(c_bin);
  }
  
  
  /*
	def momentum(v, g, lr) do
	  Matrex.apply(v, g, fn v, g -> 0.5 * v - lr * g end)
	end
  */
  __global__ void momentum_kernel(float *a, float *b, float *c, float *d, float *e, float lr, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  while (tid < n)
	  {   
		  
		  d[tid] = ((0.9 * b[tid]) - (lr * c[tid]));
		  e[tid] = a[tid] + d[tid];
		  
		  tid += blockDim.x * gridDim.x;
	  }
  }
  
  /*
  1st arg row-size of vectorized each-matrix
  2nd arg wight-matrix    (a)
  3rd arg v-matrix        (b)
  4th arg gradient-matrix (c)
  5th arg learning rate
  
  return tuple {next_v-mattrix,weight_matrix}
  */
  static ERL_NIF_TERM
  momentum1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin,c_bin;
	  ERL_NIF_TERM  d_bin,e_bin,tuple;
	  int n;
	  float *a,*b,*c,*d,*e;
	  float *dev_a, *dev_b, *dev_c ,*dev_d, *dev_e;
	  float lr;
	  double learning_rate;
	
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin )) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &c_bin )) return enif_make_int(env,4);
	  if (!enif_get_double(env, argv[4], &learning_rate)) return enif_make_int(env,5);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) c_bin.data;
	  d = (float *) enif_make_new_binary(env, n * sizeof(float), &d_bin);
	  e = (float *) enif_make_new_binary(env, n * sizeof(float), &e_bin);
	  lr = (float) learning_rate;
	  
	
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_d, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_e, n * sizeof(float)));
	
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_c, c, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_d, d, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_e, e, n * sizeof(float), cudaMemcpyHostToDevice));
	
	  momentum_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, dev_d, dev_e, lr, n);
	
	  // copy to host d from GPU dev_d
	  CHECK(cudaMemcpy(d, dev_d, n * sizeof(float), cudaMemcpyDeviceToHost));
	  CHECK(cudaMemcpy(e, dev_e, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
	  cudaFree(dev_d);
	  cudaFree(dev_e);
	  
	  tuple = enif_make_tuple2(env,d_bin,e_bin);
	  return(tuple);
  }
  
  /* ADAGRAD
	  h1 = h + grad*grad
	  lr1 = lr/(sqrt(h1))
	  w1 = w - lr1 * grad 
  
	  a[] = w
	  b[] = h
	  c[] = grad
	  d[] = h1
	  e[] = w1
  */
	
  __global__ void adagrad_kernel(float *a, float *b, float *c, float *d, float *e, float lr, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  float lr1;
	  while (tid < n)
	  {   
		  d[tid] = b[tid] + c[tid]*c[tid];
		  if(d[tid] != 0.0)
			  lr1 = lr/(sqrt(d[tid]));
		  else
			  lr1 = lr;
		  e[tid] = a[tid] - lr1 * c[tid];
  
		  tid += blockDim.x * gridDim.x;
	  }
  }
   
  /*
  1st arg row-size of vectorized each-matrix
  2nd arg wight-matrix (a_bin)
  3rd arg h-matrix     (b_bin)
  4th arg grad-matrix  (c_bin)
  5th arg learning rate
  return tuple {new-h,new-w}
  */
  static ERL_NIF_TERM
  adagrad1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin,c_bin;
	  ERL_NIF_TERM  d_bin,e_bin,tuple;
	  int n;
	  float *a,*b,*c,*d,*e;
	  float *dev_a, *dev_b, *dev_c, *dev_d, *dev_e;
	  float lr;
	  double learning_rate;
	  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &c_bin)) return enif_make_int(env,4);
	  if (!enif_get_double(env, argv[4], &learning_rate)) return enif_make_int(env,5);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) c_bin.data;
	  d = (float *) enif_make_new_binary(env, n * sizeof(float), &d_bin);
	  e = (float *) enif_make_new_binary(env, n * sizeof(float), &e_bin);
	  lr = (float) learning_rate;
	
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_d, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_e, n * sizeof(float)));
	
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_c, c, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_d, d, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_e, e, n * sizeof(float), cudaMemcpyHostToDevice));
	
	  adagrad_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, dev_d, dev_e, lr, n);
	
	  // copy to host d,e from GPU dev_d,dev_e
	  CHECK(cudaMemcpy(d, dev_d, n * sizeof(float), cudaMemcpyDeviceToHost));
	  CHECK(cudaMemcpy(e, dev_e, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
	  cudaFree(dev_d);
	  cudaFree(dev_e);
	  
	  tuple = enif_make_tuple2(env,d_bin,e_bin);
	  return(tuple);
  }
  
  /* RMSprop
	  h1 = alpha * h + (1 - alpha) * grad*grad
	  lr1 = lr /(sqrt(h) + epsilon)
	  w1 = w - lr1 * grad 
  
	  a[] = w
	  b[] = h
	  c[] = grad
	  d[] = h1
	  e[] = w1
  */
	
  __global__ void rms_kernel(float *a, float *b, float *c, float *d, float *e, float lr, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  float lr1,alpha,epsilon;
	  alpha = 0.99;
	  epsilon = 10.0e-7;
	  while (tid < n)
	  {   
		  d[tid] = alpha * b[tid] + (1-alpha)*c[tid]*c[tid];
		  lr1 = lr/(sqrt(d[tid])+epsilon);
		  e[tid] = a[tid] - lr1*c[tid];
  
		  tid += blockDim.x * gridDim.x;
	  }
  }
   
  /*
  1st arg row-size of vectorized each-matrix
  2nd arg wight-matrix (a_bin)
  3rd arg h-matrix     (b_bin)
  4th arg grad-matrix  (c_bin)
  5th arg learning rate
  return tuple {new-h,new-w}
  */
  static ERL_NIF_TERM
  rms1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin,c_bin;
	  ERL_NIF_TERM  d_bin,e_bin,tuple;
	  int n;
	  float *a,*b,*c,*d,*e;
	  float *dev_a, *dev_b, *dev_c, *dev_d, *dev_e;
	  float lr;
	  double learning_rate;
	  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &c_bin)) return enif_make_int(env,4);
	  if (!enif_get_double(env, argv[4], &learning_rate)) return enif_make_int(env,5);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) c_bin.data;
	  d = (float *) enif_make_new_binary(env, n * sizeof(float), &d_bin);
	  e = (float *) enif_make_new_binary(env, n * sizeof(float), &e_bin);
	  lr = (float) learning_rate;
	
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_d, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_e, n * sizeof(float)));
	
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_c, c, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_d, d, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_e, e, n * sizeof(float), cudaMemcpyHostToDevice));
	
	  rms_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, dev_d, dev_e, lr, n);
	
	  // copy to host d,e from GPU dev_d,dev_e
	  CHECK(cudaMemcpy(d, dev_d, n * sizeof(float), cudaMemcpyDeviceToHost));
	  CHECK(cudaMemcpy(e, dev_e, n * sizeof(float), cudaMemcpyDeviceToHost));
  
	  
  
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
	  cudaFree(dev_d);
	  cudaFree(dev_e);
	  
	  tuple = enif_make_tuple2(env,d_bin,e_bin);
	  return(tuple);
  }
  
  
  /* ADAM
	  beta1 = 0.9
	  beta2 = 0.999
	  epsilon = 10.0e-7
	  alpha = 0.001
	  m1 = beta1 * m + (1 - beta1) * grad
	  v1 = beta2 * v + (1 - beta2) * grad^2
	  m2 = m1/(1 - beta1)
	  v2 = v1/(1 - beta2)
	  w1 = w - alpha * m2/(sqrt(v2)+epsilon)
  
	  a[] is w
	  b[] is m
	  c[] is v
	  d[] is grad
	  e[] is m1
	  f[] is v1
	  g[] is w1
   */
	
  __global__ void adam_kernel(float *a, float *b, float *c, float *d, float *e, float *f, float *g, float lr, int n)
  {
	  int tid = threadIdx.x + blockIdx.x * blockDim.x;
	  float beta1,beta2,epsilon,m2,v2;
	  beta1 = 0.9;
	  beta2 = 0.999;
	  epsilon = 10.0e-7;
	  //alpha = 0.001;
  
	  while (tid < n){   
		  e[tid] = beta1 * b[tid] + (1 - beta1) * d[tid];
		  f[tid] = beta2 * c[tid] + (1 - beta2) * d[tid]*d[tid];
		  m2 = e[tid]/(1-beta1);
		  v2 = f[tid]/(1-beta2);
		  g[tid] = a[tid] - lr * (m2/(sqrt(v2)+epsilon));
		   
		  tid += blockDim.x * gridDim.x;
	  }
  }
	 
  /*
  1st arg row-size of vectorized each-matrix
  2nd arg w-matrix     (a_bin)
  3rd arg m-matrix     (b_bin)
  4th arg v-matrix     (c_bin)
  5th arg grad-matrix  (d_bin)
  6th arg learning rate
  
  return tuple {m1,v1,w1}
  */
  static ERL_NIF_TERM
  adam1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin,c_bin,d_bin;
	  ERL_NIF_TERM  e_bin,f_bin,g_bin,tuple;
	  int n;
	  float *a,*b,*c,*d,*e,*f,*g;
	  float *dev_a, *dev_b, *dev_c, *dev_d, *dev_e, *dev_f, *dev_g;
	  float lr;
	  double learning_rate;
		
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &c_bin)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &d_bin)) return enif_make_int(env,5);
	  if (!enif_get_double(env, argv[5], &learning_rate)) return enif_make_int(env,6);
	
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) c_bin.data;
	  d = (float *) d_bin.data;
	  e = (float *) enif_make_new_binary(env, n * sizeof(float), &e_bin);
	  f = (float *) enif_make_new_binary(env, n * sizeof(float), &f_bin);
	  g = (float *) enif_make_new_binary(env, n * sizeof(float), &g_bin);
	  lr = (float) learning_rate;
	  
	  // Allocate for GPU
	  CHECK(cudaMalloc((void**)&dev_a, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_b, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_c, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_d, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_e, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_f, n * sizeof(float)));
	  CHECK(cudaMalloc((void**)&dev_g, n * sizeof(float)));
  
	  // copy from host a,b to GPU dev_a, dev_b
	  CHECK(cudaMemcpy(dev_a, a, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_b, b, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_c, c, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_d, d, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_e, e, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_f, f, n * sizeof(float), cudaMemcpyHostToDevice));
	  CHECK(cudaMemcpy(dev_g, g, n * sizeof(float), cudaMemcpyHostToDevice));
	  
	  adam_kernel << <128, 128 >> >(dev_a, dev_b, dev_c, dev_d, dev_e, dev_f, dev_g, lr, n);
	  
	  // copy to host d,e from GPU dev_d,dev_e
	  CHECK(cudaMemcpy(e, dev_e, n * sizeof(float), cudaMemcpyDeviceToHost));
	  CHECK(cudaMemcpy(f, dev_f, n * sizeof(float), cudaMemcpyDeviceToHost));
	  CHECK(cudaMemcpy(g, dev_g, n * sizeof(float), cudaMemcpyDeviceToHost));
		
	
	  // free 
	  cudaFree(dev_a);
	  cudaFree(dev_b);
	  cudaFree(dev_c);
	  cudaFree(dev_d);
	  cudaFree(dev_e);
	  cudaFree(dev_f);
	  cudaFree(dev_g);
	  
		
	  tuple = enif_make_tuple3(env,e_bin,f_bin,g_bin);
	  return(tuple);
  }
	
	
  
  
  /*
  1st arg row-size of matrix
  2nd arg col-size of matris
  3rd arg predicted matrix
  4th arg list of label. each element is integer
  return accuracy rate
  */
  
  static ERL_NIF_TERM
  accuracy1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  head,list,result;
	  int r1, c1, i, j, n, index,sum;
	  float *a;
	  double max,rate;
	
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  
  
	  // calculate accuracy
	  sum = 0;
	  list = argv[3]; 
	  for(i=0;i<r1;i++){
		  max = 0.0;
		  enif_get_list_cell(env, list, &head, &list);
		  enif_get_int(env,head,&n);
		  for(j=0;j<c1;j++){
			  if(a[IDX2C(i,j,r1)] > max){
				  max = a[IDX2C(i,j,r1)];
				  index = j;
			  }
		  }
		  if(index == n)
			  sum++;
	  }
	  rate = (double)sum / (double)r1;
	  result = enif_make_double(env,rate);
	  return(result);
  }
  
  /*
  1st arg row-size of matrix
  2nd arg col-size of matris
  3rd arg predicted matrix
  4th arg list of label. each element is integer
  return correct number
  */
  
  static ERL_NIF_TERM
  correct1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  head,list,result;
	  int r1, c1, i, j, n, index,sum;
	  float *a;
	  float max;
	
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  
  
	  // calculate correct number
	  sum = 0;
	  list = argv[3]; 
	  for(i=0;i<r1;i++){
		  max = 0.0;
		  enif_get_list_cell(env, list, &head, &list);
		  enif_get_int(env,head,&n);
		  for(j=0;j<c1;j++){
			  if(a[IDX2C(i,j,r1)] > max){
				  max = a[IDX2C(i,j,r1)];
				  index = j;
			  }
		  }
		  if(index == n)
			  sum++;
	  }
  
	  result = enif_make_double(env,(double)sum);
	  return(result);
  }
  
  
  /*
  random_select for matrix data
  */
  static ERL_NIF_TERM
  random_select1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  ERL_NIF_TERM  c_bin,d_bin,tuple;
	  int r1, c1, r2, c2, i, j, n, r;
	  float *a, *b, *c, *d;
	
	  if (!enif_get_int(env, argv[0], &r1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &r2)) return enif_make_int(env,4);
	  if (!enif_get_int(env, argv[4], &c2)) return enif_make_int(env,5);
	  if (!enif_inspect_binary(env, argv[5], &b_bin )) return enif_make_int(env,6);
	  if (!enif_get_int(env, argv[6], &n)) return enif_make_int(env,7);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n*c1 * sizeof(float), &c_bin);
	  d = (float *) enif_make_new_binary(env, n*c2 * sizeof(float), &d_bin);
  
  
	  // random-select
	  for(i=0;i<n;i++){
		  r = rand() % r1;
		  for(j=0;j<c1;j++){
			  c[IDX2C(i,j,n)] = a[IDX2C(r,j,r1)];
		  }
		  for(j=0;j<c2;j++){
			  d[IDX2C(i,j,n)] = b[IDX2C(r,j,r2)];
		  }    
	  }
  
	  tuple = enif_make_tuple2(env,c_bin,d_bin);
	  return(tuple);
  }
  
  /*
  random_select for 4D-tensor data
  */
  static ERL_NIF_TERM
  random_select2(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  ERL_NIF_TERM  c_bin,d_bin,tuple;
	  int n1,c1,h1,w1,r2,c2, i, j, k, l, n, r;
	  float *a, *b, *c, *d;
	
	  if (!enif_get_int(env, argv[0], &n1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &c1)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &h1)) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &w1)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &a_bin )) return enif_make_int(env,5);
	  if (!enif_get_int(env, argv[5], &r2)) return enif_make_int(env,6);
	  if (!enif_get_int(env, argv[6], &c2)) return enif_make_int(env,7);
	  if (!enif_inspect_binary(env, argv[7], &b_bin )) return enif_make_int(env,8);
	  if (!enif_get_int(env, argv[8], &n)) return enif_make_int(env,9);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n*c1*h1*w1 * sizeof(float), &c_bin);
	  d = (float *) enif_make_new_binary(env, n*r2*c2 * sizeof(float), &d_bin);
  
	  // random-select
	  for(i=0;i<n;i++){
		  r = rand() % n1;
		  for(j=0;j<c1;j++){
			  for(k=0;k<h1;k++){
				  for(l=0;l<w1;l++){
					  c[IDX4C(i,j,k,l,c1,h1,w1)] = a[IDX4C(r,j,k,l,c1,h1,w1)];
				  }
			  }
		  }
		  for(j=0;j<c2;j++){
			  d[IDX2C(i,j,n)] = b[IDX2C(r,j,r2)];
		  }    
	  }
  
	  tuple = enif_make_tuple2(env,c_bin,d_bin);
	  return(tuple);
  }
  
  /*
  random_select for 3D-tensor data
  */
  static ERL_NIF_TERM
  random_select3(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  ERL_NIF_TERM  c_bin,d_bin,tuple;
	  int n1,h1,w1,r2,c2, i, j, k, n, r;
	  float *a, *b, *c, *d;
	
	  if (!enif_get_int(env, argv[0], &n1)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &h1)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &w1)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &a_bin )) return enif_make_int(env,4);
	  if (!enif_get_int(env, argv[4], &r2)) return enif_make_int(env,5);
	  if (!enif_get_int(env, argv[5], &c2)) return enif_make_int(env,6);
	  if (!enif_inspect_binary(env, argv[6], &b_bin )) return enif_make_int(env,7);
	  if (!enif_get_int(env, argv[7], &n)) return enif_make_int(env,8);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
	  c = (float *) enif_make_new_binary(env, n*h1*w1 * sizeof(float), &c_bin);
	  d = (float *) enif_make_new_binary(env, n*r2*c2 * sizeof(float), &d_bin);
  
	  // random-select
	  for(i=0;i<n;i++){
		  r = rand() % n1;
		  for(j=0;j<h1;j++){
			  for(k=0;k<w1;k++){
				  c[IDX3C(i,j,k,h1,w1)] = a[IDX3C(r,j,k,h1,w1)];
			  }
		  }
		  for(j=0;j<c2;j++){
			  d[IDX2C(i,j,n)] = b[IDX2C(r,j,r2)];
		  }    
	  }
  
	  tuple = enif_make_tuple2(env,c_bin,d_bin);
	  return(tuple);
  }
  
  
  
  static ERL_NIF_TERM
  is_near1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  int i, n, sw;
	  float *a, *b;
	
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
  
	  // near check
	  sw = 0;
	  for(i=0;i<n;i++){
		 if(fabsf(a[i]) > fabsf(b[i])*1.15 || fabsf(a[i]) < fabsf(b[i])*0.85){
			  printf("%f %f \r\n", a[i], b[i]);
			  sw = 1;
		  }
	  }
	  if(sw == 0)
		  return enif_make_int(env,1); //true
	  else
		  return enif_make_int(env,0); //false
  }
  
  static ERL_NIF_TERM
  is_equal1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin,b_bin;
	  int i, n;
	  float *a, *b;
	
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin )) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
	  b = (float *) b_bin.data;
  
	  // equal check
	  for(i=0;i<n;i++){
		 if(a[i] != b[i]){
			  return enif_make_int(env,0); //false
		  }
	  }
	  
	  return enif_make_int(env,1); //true
  }
  
  
  
  static ERL_NIF_TERM
  analizer1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  int i, n, id;
	  float *a;
	  float max,min,sum;
	
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &id)) return enif_make_int(env,3);
  
	  a = (float *) a_bin.data;
  
	  // near check
	  for(i=0;i<n;i++){
		  if(isnan(a[i])){
			  return enif_make_int(env,9999);
		  }
		  if(isinf(a[i])){
			  return enif_make_int(env,9998);
		  }
	  }
  
	  //find max min avarage
	  max = -999999999;
	  min = 999999999;
	  sum = 0;
	  for(i=0;i<n;i++){
		  if(a[i] > max)
			  max = a[i];
		  
		  if(a[i] < min)
			  min = a[i];
		  
		  sum = sum+a[i];
  
	  }
	  printf("id max min average\r\n");
	  printf("%d %f %f %f \r\n", id, max, min, sum/(float)n);
  
	  return enif_make_int(env,1);
  }
  
  
  
	
	/*
	1st arg in_n of tensor
	2nd arg in_c of tensor
	3rd arg in_h of tensor
	4th arg in_w of tensor
	5th arg binary of tensor
	
	*/
  static ERL_NIF_TERM
  standardize1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int in_n,in_c,in_h,in_w,n1,i,c1,h1,w1,count;
	  float *a,*b;
	  float sum,average;
	
	  if (!enif_get_int(env, argv[0], &in_n)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &in_c)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &in_h)) return enif_make_int(env,3);
	  if (!enif_get_int(env, argv[3], &in_w)) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &a_bin )) return enif_make_int(env,5);
  
	  n1 = in_n * in_c * in_h * in_w;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n1 * sizeof(float), &b_bin);
	 
	  
	  for(i=0;i<in_n;i++){
		  sum = 0.0;
		  for(c1=0;c1<in_c;c1++){
			  for(h1=0;h1<in_h;h1++){
				  for(w1=0;w1<in_w;w1++){
					  sum = sum + a[IDX4C(i,c1,h1,w1,in_c,in_h,in_w)];
				  }
			  }
		  }
		  count = in_c * in_h * in_w;
		  average = sum / (float)count;
		  for(c1=0;c1<in_c;c1++){
			  for(h1=0;h1<in_h;h1++){
				  for(w1=0;w1<in_w;w1++){
					  b[IDX4C(i,c1,h1,w1,in_c,in_h,in_w)] = a[IDX4C(i,c1,h1,w1,in_c,in_h,in_w)] - average;
				  }
			  }
		  }
	  }
	  
	  return(b_bin);
  }
  
  
	
  /*
  1st arg in_n of 3D tensor
  2rd arg in_r of 3D tensor
  3th arg in_c of 3D tensor
  4th arg binary of tensor
  5th arg nth in_r of 3D tensor
	
  */
  static ERL_NIF_TERM
  pickup1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int in_n,in_row,in_col,nth,n1,i,j;
	  float *a,*b;
	  
	  if (!enif_get_int(env, argv[0], &in_n)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &in_row)) return enif_make_int(env,2);
	  if (!enif_get_int(env, argv[2], &in_col)) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &a_bin )) return enif_make_int(env,4);
	  if (!enif_get_int(env, argv[4], &nth)) return enif_make_int(env,5);
  
	  n1 = in_n * in_col;
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n1 * sizeof(float), &b_bin);
	   
		
	  for(i=0;i<in_n;i++){
		  for(j=0;j<in_col;j++){
			  b[IDX2C(i,j,in_n)] = a[IDX3C(i,nth,j,in_row,in_col)];
		  }
	  }
		
	  return(b_bin);
  }
	
  
	
  /*
  1st arg size of tensor or matrix
  2rd arg binary of tensor or matrix
	
  */
  static ERL_NIF_TERM
  copy1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin;
	  int n,i;
	  float *a,*b;
	  
	  if (!enif_get_int(env, argv[0], &n)) return enif_make_int(env,1);
	  if (!enif_inspect_binary(env, argv[1], &a_bin )) return enif_make_int(env,2);
  
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
	   
		
	  for(i=0;i<n;i++){
		  b[i] = a[i];
	  }
		
	  return(b_bin);
  }
  
  
  static ERL_NIF_TERM
  slice1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  a_bin;
	  ERL_NIF_TERM  b_bin,c_bin,d_bin,e_bin,tuple;
	  int in_r,in_c,in_c1,i,j,n,bias;
	  float *a,*b,*c,*d,*e;
	  
	  if (!enif_get_int(env, argv[0], &in_r)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &in_c)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &a_bin )) return enif_make_int(env,3);
  
	  in_c1 = in_c / 4;
	  n = in_r * (in_c / 4);
	  a = (float *) a_bin.data;
	  b = (float *) enif_make_new_binary(env, n * sizeof(float), &b_bin);
	  c = (float *) enif_make_new_binary(env, n * sizeof(float), &c_bin);
	  d = (float *) enif_make_new_binary(env, n * sizeof(float), &d_bin);
	  e = (float *) enif_make_new_binary(env, n * sizeof(float), &e_bin);
	   
		
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c1;j++){
			  b[IDX2C(i,j,in_r)] = a[IDX2C(i,j,in_r)]; 
		  }
	  }
	  bias = in_c / 4;
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c1;j++){
			  c[IDX2C(i,j,in_r)] = a[IDX2C(i,j+bias,in_r)]; 
		  }
	  }
	  bias = 2 * (in_c / 4);
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c1;j++){
			  d[IDX2C(i,j,in_r)] = a[IDX2C(i,j+bias,in_r)]; 
		  }
	  }
	  bias = 3 * (in_c / 4);
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c1;j++){
			  e[IDX2C(i,j,in_r)] = a[IDX2C(i,j+bias,in_r)]; 
		  }
	  }
		
	  tuple = enif_make_tuple4(env,b_bin,c_bin,d_bin,e_bin);
	  return(tuple);
  }
  
  static ERL_NIF_TERM
  unslice1(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
	  ErlNifBinary  b_bin,c_bin,d_bin,e_bin;
	  ERL_NIF_TERM  a_bin;
	  int in_r,in_c,i,j,n,bias;
	  float *a,*b,*c,*d,*e;
	  
	  if (!enif_get_int(env, argv[0], &in_r)) return enif_make_int(env,1);
	  if (!enif_get_int(env, argv[1], &in_c)) return enif_make_int(env,2);
	  if (!enif_inspect_binary(env, argv[2], &b_bin )) return enif_make_int(env,3);
	  if (!enif_inspect_binary(env, argv[3], &c_bin )) return enif_make_int(env,4);
	  if (!enif_inspect_binary(env, argv[4], &d_bin )) return enif_make_int(env,5);
	  if (!enif_inspect_binary(env, argv[5], &e_bin )) return enif_make_int(env,6);
  
	  n = in_r * in_c * 4;
	  a = (float *) enif_make_new_binary(env, n * sizeof(float), &a_bin);
	  b = (float *) b_bin.data;
	  c = (float *) c_bin.data;
	  d = (float *) d_bin.data;
	  e = (float *) e_bin.data;
	  
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c;j++){
			  a[IDX2C(i,j,in_r)] = b[IDX2C(i,j,in_r)];
		  }
	  }
	  bias = in_c;
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c;j++){
			  a[IDX2C(i,j+bias,in_r)] = c[IDX2C(i,j,in_r)]; 
		  }
	  }
	  bias = 2 * in_c;
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c;j++){
			  a[IDX2C(i,j+bias,in_r)] = d[IDX2C(i,j,in_r)] ; 
		  }
	  }
	  bias = 3 * in_c;
	  for(i=0;i<in_r;i++){
		  for(j=0;j<in_c;j++){
			  a[IDX2C(i,j+bias,in_r)] = e[IDX2C(i,j,in_r)]; 
		  }
	  }
	  return(a_bin);
  }
  
  
  
  


*/