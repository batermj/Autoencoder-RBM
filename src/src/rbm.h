#include "utils.h"
#include "cifar10.h"

class RBM
{
protected:

	// member variables for the hyper-parameters in the RBM implementation
	unsigned int nEpochNum; // total number of epoches
	unsigned int nBatchNum; // total number of mini-batches
	unsigned int nVectorPerBatch; // the number of input vectors in each min-batch

	unsigned int nVisLayerSize; // The size of the visible layer in terms of the number of input neurons
	unsigned int nHidLayerSize; // The size of the hidden layer in terms of the number of hidden neurons
	bool linear; // true [for a linear RBM if it is used for the pre-training of an intermediate layer of a deep network], otherwise false [for a binary RBM��]

	string dataTag; // used to generate data file names	
	string logTag;  // used to generate log file names

	floatType weightCost; // for weight decay
	floatType momentum;
	floatType initialMomentum; // the momentum for first 5 epoches
	floatType finalMomentum; // the momentum for other epoches

	// member variables for the RBM parameters
	floatType eps_w; // learning rate for weights
	floatType eps_vb; // learning rate for visual bias
	floatType eps_hb; // learning rate for hidden bias

	vector<floatType*> batchData; // training data batches 

	floatType* weights; // weights between the visible layer and the hidden layer
	floatType* hidBias; // hidden bias
	floatType* visBias; // visual bias

	floatType* delta_weights; // the increment of weights for each iteration
	floatType* delta_hidBias; // the increment of hidden biases for each iteration
	floatType* delta_visBias; // the increment of visible biases for each iteration

	floatType* posData; // visible data in the positive phase, fetch from batchData
	floatType* posHidProbs; // hidden layer probability values in the positive phase [nHidLayerSize * nVectorPerBatch]
	floatType* negHidProbs; // hidden layer probability values in the negative phase [nHidLayerSize * nVectorPerBatch]
	floatType* posProds; // visible hidden products in the positive phase for updating weights [nHidLayerSize * nVisLayerSize]
	floatType* negProds; // visible hidden products in the negative phase for updating weights [nHidLayerSize * nVisLayerSize]
	floatType* negData; // visible data in the negative phase, built from hidden states in the positive phase [nVisLayerSize * nVectorPerBatch]
	floatType* posHidAct; // sum of posHidProbs in a batch for updating hidden biases [nHidLayerSize]
	floatType* posVisAct; // sum of batchData in a batch for updating visible biases [nVisLayerSize]
	floatType* negHidAct; // sum of negHidProbs in a batch for updating hidden biases [nHidLayerSize]
	floatType* negVisAct; // sum of negData in a batch for updating visible biases[nVisLayerSize]
	floatType* error;
	floatType* posHidStates; // hidden states for binary RBM [nHidLayerSize * nVectorPerBatch]

	vector<floatType*> batchPosHidProbs; // training data for next RBM

public:
	dataProvider* dataprovider;

	RBM(); // initialize the RBM, default settings
	RBM(unsigned int vis, unsigned int hid, bool linearity, unsigned numEpoch, unsigned numBatch, unsigned nVecPerBatch, floatType wCost, floatType initMom, floatType finalMom, string layertag); // optional settings
	virtual ~RBM(); // destroy an object

	virtual void setInputData(vector<floatType*> trainData);
	// positive phase: calculate pos*[namely, posHidProbs, posProds...] variables
	virtual void posProp(); 
	// determine posHidStates
	virtual void generateStates(); 
	// negative phase: calculate neg* variables
	virtual void negProp();
	// update weights as well as the biases of the visible and the hidden layer
	virtual void update(); 

	// RBM training entry
	virtual void train(); 

};

class RBM_GPU: public RBM
{
protected:
	// GPU memory objects
	cl_mem d_weights; // weights between the visual layer and the hidden layer
	cl_mem d_hidBias; // hidden bias
	cl_mem d_visBias; // visual bias
	
	cl_mem d_delta_weights; // the increment of weights for each iteration
	cl_mem d_delta_hidBias; // the increment of hidden biases for each iteration
	cl_mem d_delta_visBias; // the increment of visible biases for each iteration

	// vector<cl_mem> d_batchData;

	cl_mem d_posData;		// visible data in the positive phase, fetch from batchData 
	cl_mem d_posHidProbs;	// hidden layer probability in the positive phase
	cl_mem d_negHidProbs;	// hidden layer probability in the negative phase
	cl_mem d_posProds;	// visual hidden products in the positive phase
	cl_mem d_negProds;	// visual hidden products in the negative phase
	cl_mem d_negData;	// visual data in the negative phase
	cl_mem d_posHidAct; // sum of posHidProbs in a batch
	cl_mem d_posVisAct; // sum of batchData in a batch
	cl_mem d_negHidAct; // sum of negHidProbs in a batch
	cl_mem d_negVisAct; // sum of negData in a batch
	cl_mem d_error;		// sum of error square
	cl_mem d_posHidStates; // hidden states for binary RBM

	// vector<cl_mem> d_batchPosHidProbs;

	// OpenCL kernels
	cl_kernel squareError;
	cl_kernel sigmoid;
	cl_kernel addBias;
	cl_kernel addBias_noreset;
	cl_kernel sumBatch;
	cl_kernel add;
	cl_kernel getStates;
	cl_kernel updateWeights;
	cl_kernel updateBias;
	cl_kernel randNum;
	cl_kernel randn;
	cl_kernel reset;

public:
	// OpenCL objects
	CL_ENV gpu_env; 
	
	dataProvider_GPU* dataprovider;

	RBM_GPU(unsigned int deviceIndex, unsigned int vis, unsigned int hid, bool linearity, unsigned numEpoch, unsigned numBatch, unsigned nVecPerBatch, floatType wCost, floatType initMom, floatType finalMom, string layertag); 

	~RBM_GPU();		// clear the device memory

	// void setInputData(vector<floatType*> trainData);
	void posProp(); // positive phase: calculate pos* variables
	void generateStates(); // determine posHidStates
	void negProp(); // negative phase: calculate neg* variables
	void update();	// update weights and biases
	void train();
	void test();

	void gpu_release();
};
