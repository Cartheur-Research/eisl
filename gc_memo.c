/*  idea memo */

int concurrent_flag;
int concurrent_exit_flag;

pthread_mutex_t mutex;
pthread_cond_t cond_gc;
pthread_t concurrent_thread;

void *concurrent(void *arg){
    while(1){
        pthread_mutex_lock(&mutex);
        pthread_cond_wait(&cond_gc, &mutex); 
        pthread_mutex_unlock(&mutex);
        if(concurrent_exit_flag)
            goto exit;
        concurrent_flag = 1;
        /* GCを実行するコードをここに追加 */
        concurrent_flag = 0;
    }

exit:
    pthread_exit(NULL);
}

void init_concurrent(void){
    pthread_create(&concurrent_thread, NULL, concurrent, NULL); 
}

void gbc_concurrent(void){
    pthread_mutex_lock(&mutex);
    pthread_cond_signal(&cond_gc);
    pthread_mutex_unlock(&mutex);
}

void exit_concurrent(void){
    pthread_mutex_lock(&mutex);
    concurrent_exit_flag = 1;
    pthread_cond_signal(&cond_gc); 
    pthread_mutex_unlock(&mutex);
}

//---thread pooling-----------------------------------------------
int queue[10];
int queue_pt;
int input[10];
int output[10];
struct para d[10];
pthread_t para_thread[10]
pthread_cond_t cond_para[10];

void enqueue(int n){
    queue[queue_pt] = n;
    queue_pt++;
}

void dequeue(int arg1){
    int th,i;

    th = queue[0];
    for(i=0;i<queue_pt;i++){
        queue[i] = queue[i+1];
    }
    pthread_mutex_lock(&mutex);
    d[th].in = arg1;
    d[th].num = th;
    pthread_cond_signal(&cond_para[th]);
    pthread_mutex_unlock(&mutex);
}

struct para {
    int in;
    int num;
    int out;
};


void *parallel(void *arg);
void *parallel(void *arg)
{
    struct para *pd = (struct para *) arg;
    while(1){
    pthread_mutex_lock(&mutex);
    pthread_cond_wait(&cond_para[pd->num], &mutex); 
    pthread_mutex_unlock(&mutex);
    if(parallel_exit_flag)
        goto exit;
    output[pd->num] = eval(input[pd->num], pd->num);
    }
    exit:
    pthread_exit(NULL);
}


void init_para(void){
    int i;

    for(i=0;i<10;i++){
        pthread_create(para_thread[i],NULL,parallel,&d[i]);
        queue[i] = i+1;
    }
    queue_pt = 0;
}

void exit_para(void){
    int i;
    pthread_mutex_lock(&mutex);
    parallel_exit_flag = 1;
    for(i=0,i<10;i++){
        pthread_cond_signal(&cond_para[i]);
    } 
    pthread_mutex_unlock(&mutex);
}