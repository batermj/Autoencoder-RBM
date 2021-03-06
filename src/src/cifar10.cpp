#include<cstdlib>
#include<cmath>
#include<cstring>
#include<utility>
#include<algorithm>
#include "cifar10.h"

/*
 * Generate a file name: prefix + number
 * nDigitNum is the number of the digits
*/
string generateFileName(const string& prefix, unsigned index, unsigned nDigitNum){
	// new method to generate file names
	string fname 	= prefix;	
	string reversed	= "";

	for(unsigned i = 0; i < nDigitNum; i++){
		char unitDigit = '0' + index % 10;
		reversed.push_back(unitDigit);
		index /= 10;
	}
	
	for(unsigned i = 0; i < nDigitNum; i++){
		fname.push_back(reversed[nDigitNum - 1 - i]);
	}

	return fname;
}

/*
 * An alternative approach to generating a filename in a recurrent way
*/
void generateFileName(string* prefix, unsigned index, unsigned nDigitNum){
	if(nDigitNum == 0)
		return;

	char postfix = '0' + index % 10;
	generateFileName(prefix, index / 10, nDigitNum - 1);
	prefix->push_back(postfix);
}

/*
 * The function generates a 112-dim retina image vector from a 16x16 pixels region
 * Notice: this function is for ONE CHANNEL ONLY!
*/

void retinaPermutation(unsigned char* odata, unsigned char* idata, unsigned int imageWidth, unsigned int imageHeight){
	unsigned char* p, *q;
	unsigned int iavg;

	// the 1st and 2nd line of the input data array
	q = idata;
	for(int itr = 0; itr < 16; itr += 2){
		p = q + itr;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);
	}

	// the 3rd and 4th line of the input data array
	q = idata + 2 * imageWidth;
	for(int itr = 0; itr < 16; itr += 2){
		p = q + itr;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);
	}

	// Line 5 to Line 12 of the input data array
	q = idata + 4 * imageWidth;
	for(int itr = 0; itr < 4; itr++){
		p = q;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);

		p = q + 2;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);

		p = q + 4;
		memcpy(odata, p, 8);
		odata += 8;

		p += imageWidth;
		memcpy(odata, p, 8);
		odata += 8;

		p = q + 12;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);

		p = q + 14;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);

		q += 2 * imageWidth;
	}

	// the 13th and 14th line of the input data array
	q = idata + 12 * imageWidth;
	for(int itr = 0; itr < 16; itr += 2){
		p = q + itr;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);
	}

	// the 15th and 16th line of the input data array
	q = idata + 14 * imageWidth;
	for(int itr = 0; itr < 16; itr += 2){
		p = q + itr;
		iavg = *p + *(p + 1);
		p += imageWidth;
		iavg += *p + *(p + 1);
		*(odata++) = (unsigned char)(iavg >> 2);
	}
	return;
}

cifarPreProcessor::cifarPreProcessor(string rawfile, string patchfile){
	rawDataFileName = rawfile;
	patchDataFileName = patchfile;

	nPixelPerRow = 32;
	nPixelPerColumn = 32;
	nImageNum = 68000 * 30;
	nPatchLength = 112;
	nPatchFileNum = 400;
	nPatchNum = nImageNum * 81;
}

/*
 * Make one single patch file from a raw image file
 * This function is used for CIFAR-10 dataset
*/
void cifarPreProcessor::makePatchData(){
	ifstream fin;
	ofstream fout;

	fin.open(rawDataFileName.c_str(), ios_base::binary);
	fout.open(patchDataFileName.c_str(), ios_base::trunc);

	unsigned int nPixelPerImage = 3 * nPixelPerColumn * nPixelPerRow;

	rawData = new unsigned char[nPixelPerImage * nImageNum];
	patchData = new unsigned char[3 * nPatchLength * 81 * nImageNum];
	labels = new unsigned char[nImageNum];

	// read the raw image file from file
	for(int image = 0; image < nImageNum; image++){
		unsigned char label;
		fin.read((char*)&label, 1);
		labels[image] = label;
		unsigned char temp[4096];
		fin.read((char*)temp, nPixelPerImage);
		for(int pixel = 0; pixel < nPixelPerImage; pixel++){
			rawData[image * nPixelPerImage + pixel] = temp[pixel];
		}
	}

	// make patches in memory
	for(int image = 0; image < nImageNum; image++){
		unsigned int patchId = 0;
		for(int row = 0; row <= nPixelPerColumn / 2; row += 2){
			for(int col = 0; col <= nPixelPerRow / 2; col += 2){
				// Red Channel
				unsigned int patchOffset = (81 * 3 * image + patchId) * nPatchLength;
				unsigned int rawOffset = row * nPixelPerRow + col;
				retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
				patchId++;
				// Green Channel
				patchOffset = (81 * 3 * image + patchId) * nPatchLength;
				rawOffset = nPixelPerRow * nPixelPerColumn + row * nPixelPerRow + col;
				retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
				patchId++;
				// Blue Channel
				patchOffset = (81 * 3 * image + patchId) * nPatchLength;
				rawOffset = 2 * nPixelPerRow * nPixelPerColumn + row * nPixelPerRow + col;
				retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
				patchId++;
			}
		}
	}
	
	// write patch images to file
	fout.write((char*)patchData, 3 * nPatchLength * 81 * nImageNum);

	fin.close();
	fout.close();
	delete[] rawData;
	delete[] patchData;
	delete[] labels;
	return;
}

/* 
 *This function return the retina-formatted vectors of training source
 * images. The file of raw images keeps these image in its row vectors.
 * The width of row vectors is equal to the bytes of these files, and
 * the number of vectors is the number of images.
*/

void cifarPreProcessor::makePatchDataFiles(){
	ifstream fin;
	ofstream fout;

	// open the src file which contains the training image set
	fin.open(rawDataFileName.c_str(), ios_base::binary);

	// return the number of pixels in each training image set
	unsigned int nPixelPerImage = 3 * nPixelPerColumn * nPixelPerRow;
	
	// return the number of images whose retina-formatted derives kept within the same file
	unsigned int nImagePerFile = nImageNum / nPatchFileNum;

	rawData = new unsigned char[nPixelPerImage * nImagePerFile]; 		// product(#images, #pixels)
	patchData = new unsigned char[nImagePerFile * 3 * 81 * nPatchLength];	// product(#images, #channels, #vectors, #vector-size)
	labels = NULL;

	for(int fileId = 0; fileId < nPatchFileNum; fileId++){
		// return the file name of the raw image file
		string patchName = patchDataFileName;
		generateFileName(&patchName, fileId, 3);

		// open this file by the given mode
		fout.open(patchName.c_str(), ios_base::binary | ios_base::trunc);

		// read data from raw data file
		fin.read((char*)rawData, nPixelPerImage * nImagePerFile);

		// construct the retina-formatted vecoter
		for(int image = 0; image < nImagePerFile; image++){
			// set the patch counter equal to zero
			unsigned int patchId = 0;

			// set the patch window's center in a row, and move the center in the next iteration into the next two rows
			for(int row = 0; row <= nPixelPerColumn / 2; row += 2){
				// move the patch window from left to right in the stride of 2 pixels
				for(int col = 0; col <= nPixelPerRow / 2; col += 2){
					// Red Channel
					// return the head of this patch window in the raw data buffer
					unsigned int patchOffset = (81 * 3 * image + patchId) * nPatchLength;
					// return the head of this data block in the destination buffer
					unsigned int rawOffset = row * nPixelPerRow + col;
					// return the retina-formartted vector of this patch image
					retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
					// update the patch counter
					patchId++;

					// Green Channel
					patchOffset = (81 * 3 * image + patchId) * nPatchLength;
					rawOffset = nPixelPerRow * nPixelPerColumn + row * nPixelPerRow + col;
					retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
					patchId++;

					// Blue Channel
					patchOffset = (81 * 3 * image + patchId) * nPatchLength;
					rawOffset = 2 * nPixelPerRow * nPixelPerColumn + row * nPixelPerRow + col;
					retinaPermutation(patchData + patchOffset, rawData + rawOffset, nPixelPerRow, nPixelPerColumn);
					patchId++;
				}
			}
		}

		// dump the contructed retina-formatted vectors into the specified file
		fout.write((char*)patchData, 3 * nPatchLength * 81 * nImagePerFile);
		// close the dst file
		fout.close();
	}
	// close the src file
	fin.close();
	delete[] rawData;
	delete[] patchData;
	return;
}

/*
 * The constructor of the datashuffler class
*/
datashuffler::datashuffler(const string& fileNamePrefix, unsigned numVec, unsigned numFile, unsigned vecLen){

	// the prefix of the input file, e.g. "../data/patch"
	inputPrefix 	= fileNamePrefix;
	medPrefix	= "../data/med";
	outputPrefix	= "../data/shuffledPatch";

	totalVectorCount	= numVec;
	fileCount			= numFile;
	vectorLength		= vecLen;
	
	vectorCountPerFile	= totalVectorCount / fileCount;
	
	newGlobalIndex	= new unsigned[totalVectorCount];
	vecIndexInFile	= new unsigned[totalVectorCount];
	fileIndex		= new unsigned[totalVectorCount];
	
	inputBuffer		= new byte[vectorCountPerFile * vectorLength];
	outputBuffer	= new byte[vectorCountPerFile * vectorLength];
}

/*
 * release the allocated resources 
*/
datashuffler::~datashuffler(){
	delete[] 	newGlobalIndex;
	delete[] 	vecIndexInFile;
	delete[]	fileIndex;
	delete[]	inputBuffer;
	delete[]	outputBuffer;
}

/*
 * permute the vector id array in a random order using the knuth algorithm 
*/
void datashuffler::genNewPerm(void){
	// default ascending order
	for(unsigned i = 0; i < totalVectorCount; i++){
		newGlobalIndex[i] = i;
	} 

	time_t t;
	srand((unsigned)time(&t));

	// the main loop of Knuth shuffling algorithm
	for(unsigned i = 1; i < totalVectorCount; i++){
		//  return a pseudo-random integral number
		unsigned j = rand() % i;
		
		// swap the contents of the elements p[i] and p[j]
		newGlobalIndex[i] = newGlobalIndex[j];
		newGlobalIndex[j] = i;
	}

	// compute the vecIndexInFile and fileIndex according to newGlobalIndex
	for(unsigned i = 0; i < totalVectorCount; i++){
		//vecIndexInFile[i] 	= newGlobalIndex[i] % vectorCountPerFile;	
		fileIndex[i]		= newGlobalIndex[i] / vectorCountPerFile;
	}
	
	return;
}

/*
 * load all the data in a src file into the memory to which inputBuffer points 
*/
void datashuffler::loadInputFile(const string& fname){
	// load the file fname into the memory inputBuffer
	ifstream fin;
	// open the file in binary mode
	fin.open(fname.c_str(), ios_base::binary);

	// load the data from file to memory
	fin.read((char*)inputBuffer, vectorCountPerFile * vectorLength * sizeof(byte));

	// close the file
	fin.close();

	return;
}


/*
 * Each dst file has the same number of vectors as raw files.
 * In each dst file, the vectors come from all raw files, and
 * the vectors from the same raw file are arranged together.
 * In other words, all the vectors in the dst file are grouped
 * for the moment. These vectors will be permuted in another
 * function.
*/
void datashuffler::generateMedFile(void){

	for(unsigned medId = 0; medId < fileCount; medId++){
		// open a medium file
		string medfile = generateFileName(medPrefix, medId, 3);
			
		// the pointer to the medium file buffer
		byte* medPtr = outputBuffer;

		// the number of vectors saved in the medium file
		unsigned vectorCountInMed = 0;

		for(unsigned srcId = 0; srcId < fileCount; srcId++){
			// open an input file
			string srcfile = generateFileName(inputPrefix, srcId, 3);
			
			// load an input file to memory inputBuffer
			loadInputFile(srcfile);	

			// the offset is the index of the first vector of the srcfile
			unsigned offset = vectorCountPerFile * srcId;

			byte* srcPtr = inputBuffer;
			
			for(unsigned vecId = 0; vecId < vectorCountPerFile; vecId++){
				// save the lines that belong to the medium file in the outputBuffer
				if(fileIndex[vecId + offset] == medId){
					// copy a vector from srcfile buffer to medfile buffer
					memcpy((char*)medPtr, (char*)srcPtr, vectorLength * sizeof(byte));

					medPtr = medPtr + vectorLength;

					// record the intra index of the vector in the medium file
					vecIndexInFile[medId * vectorCountPerFile + vectorCountInMed] = newGlobalIndex[vecId + offset] % vectorCountPerFile;
					vectorCountInMed++;
					
				}
				srcPtr = srcPtr + vectorLength;
			}	
		}

		// write the medium file to disk
		ofstream fout;
		fout.open(medfile.c_str(), ios_base::trunc);
		fout.write((char*)outputBuffer, vectorCountPerFile * vectorLength * sizeof(byte));
		fout.close();
	}

	return;
}


/*
 * This function carries out the intra-file permutation,
 * according to the order given by the global vector id
 * array newGlobalIndex[].
*/
void datashuffler::procMedFile(void){

	for(unsigned medId = 0; medId < fileCount; medId++){
		// open a medium file
		string medfile = generateFileName(medPrefix, medId, 3);
		// load the medium file to memory inputBuffer
		loadInputFile(medfile);
		// the offset is the index of the first vector of the medfile
		unsigned offset = vectorCountPerFile * medId;

		byte* medPtr = inputBuffer;

		// the main loop of medium file processing
		for(unsigned vecId = 0; vecId < vectorCountPerFile; vecId++){
			// the pointer to the destination of the vector
			byte* outputPtr = outputBuffer + vecIndexInFile[vecId + offset] * vectorLength;
			// copy the vector to the address in the output buffer
			memcpy((char*)outputPtr, (char*)medPtr, vectorLength * sizeof(byte));

			medPtr = medPtr + vectorLength;
		}

		// write the output file to disk
		string outputfile = generateFileName(outputPrefix, medId, 3);
		ofstream fout;
		fout.open(outputfile.c_str(), ios_base::trunc);
		fout.write((char*)outputBuffer, vectorCountPerFile * vectorLength * sizeof(byte));
		fout.close();
	}
}

/*
 * permute the vectors in a random order
*/
void datashuffler::run(void){
	printf("shuffling data...\n");

	// generate a new permutation
	printf("generating new permutaion...\n");
	genNewPerm();

	// generate medium files using input files 
	printf("creating medium files...\n");
	generateMedFile();

	// convert medium files to final output files
	printf("creating final output files...\n");
	procMedFile();

	printf("done!\n");
	return;
}


dataProvider::dataProvider(string prefix, unsigned pixelperdata, unsigned batchSize, bool floatpoint){
	dataFileNamePrefix = prefix;
	nPixelPerData = pixelperdata;
	nDataPerBatch = batchSize;
	// true - float-point file provider / false - byte file provider
	// true for GB-RBM and autoencoder and false for BB-RBM
	floatPoint = floatpoint;

	nDataPerFile = 68000 * 30 * 81;
	nBatchNum = 68000 * 30 * 81 / 128;

	// select buffer size according to data size
	nBatchInBuffer = 2500;
	if(nPixelPerData > 336)
		nBatchInBuffer = 1600;
	if(nPixelPerData > 512)
		nBatchInBuffer = 800; 

	batchDataBuffer = new floatType[nPixelPerData * nDataPerBatch * nBatchInBuffer];

	// the counters for locating the next batch in the patch files
	currentDataId = 0;
	currentBatchId = 0;
	currentFileId = 0;
	
	// the means of the data
	mean = new floatType[nPixelPerData];
	// the standard variance of the data
	variance = new floatType[nPixelPerData];

	// the shuffled indices for shuffling in buffer
	shuffledId = new unsigned[nBatchInBuffer * nDataPerBatch];
	// default ascending order
	for(unsigned i = 0; i < nBatchInBuffer * nDataPerBatch; i++){
		shuffledId[i] = i;
	} 

	// load the means and the second moments from file
	getStat();
}

void dataProvider::reset(){
	currentDataId = 0;
	currentBatchId = 0; 
	currentFileId = 0;
	return;
}

/*
 * Calculate the means and second moments of the data and save them in files
*/
void dataProvider::getExpectation(){
	// the means of the data
	floatType expectation[nPixelPerData];
	// the second moments of the data
	floatType secondMoment[nPixelPerData];

	// clear the memory
	memset(expectation, 0, nPixelPerData * sizeof(floatType));
	memset(secondMoment, 0, nPixelPerData * sizeof(floatType));
	
	// calculate the means and the second moments by file in order to minimize the float-point error
	for(int fileId = 0; fileId < 400; fileId++){
		string dataFileName = dataFileNamePrefix;
		generateFileName(&dataFileName, fileId, 3);
		
		// temp buffers for means and second moments of each file
		floatType tempSum[nPixelPerData];
		floatType tempQuadSum[nPixelPerData];
		
		// clear the temp buffer
		memset(tempSum, 	0, nPixelPerData * sizeof(floatType));
		memset(tempQuadSum, 0, nPixelPerData * sizeof(floatType));

		// temp buffer for the data
		unsigned char tempBuffer[nPixelPerData];

		ifstream fin;
		// open one data file and sum up the data values and the square of data values
		fin.open(dataFileName.c_str(), ios_base::binary);
		const unsigned nPatchPerFile = 68000 * 30 * 81 / 400;

		for(unsigned patchId = 0; patchId < nPatchPerFile; patchId++){
			// read one line of data to buffer
			fin.read((char*)tempBuffer, sizeof(unsigned char) * nPixelPerData);
			
			for(unsigned i = 0; i < nPixelPerData; i++){
				// second moment
				tempQuadSum[i] += ((floatType)tempBuffer[i]) * ((floatType)tempBuffer[i]) / 255.0 / 255.0;
				// mean
				tempSum[i] += ((floatType)tempBuffer[i]) / 255.0;
			}
		}
		
		fin.close();
		
		// add the sum of one file to the total sum
		for(int i = 0; i < nPixelPerData; i++){
			expectation[i] += tempSum[i];
			secondMoment[i] += tempQuadSum[i];
		}
	}

	// means and second moments normalization
	for(int i = 0; i < nPixelPerData; i++){
		expectation[i] /= 68000 * 30 * 81;
		secondMoment[i] /= 68000 * 30 * 81;
	}


	// save the means and second moments to files
	ofstream fout;
	fout.open("../data/means.dat", ios_base::binary | ios_base::trunc);
	fout.write((char*)expectation, nPixelPerData * sizeof(floatType));
	fout.close();

	fout.open("../data/secondmoment.dat", ios_base::binary | ios_base::trunc);
	fout.write((char*)secondMoment, nPixelPerData * sizeof(floatType));
	fout.close();
}

/*
 * Load the means and second moments of the data from files to memory
*/
void dataProvider::getStat(){
	ifstream fin;

	// open the file containing the means of the data
	fin.open("../data/means.dat", ios_base::binary);
	fin.read((char*)mean, nPixelPerData * sizeof(floatType));
	fin.close();

	// open the file containing the second moments of the data
	fin.open("../data/secondmoment.dat", ios_base::binary);
	fin.read((char*)variance, nPixelPerData * sizeof(floatType));
	fin.close();
	
	// calculate the standard variance of the data using the second moments and the means
	for(int i = 0; i < nPixelPerData; i++){
		variance[i] = sqrt(variance[i] - mean[i] * mean[i]);
	}
	
	return;
}

/*
 * Load training data from files to memory
 * This function is for BB-RBM, which processes the float-point files
*/
void dataProvider::loadFloatFileToBuffer()
{
	// the nextLoadIndex indicates the index of the first vector not included in this loading
	int nextLoadIndex = currentDataId + nDataPerBatch * nBatchInBuffer;

	// if the end of the training data is reached, the nextLoadIndex is set to the end
	nextLoadIndex = (nextLoadIndex > 68000 * 30 * 81) ? 68000 * 30 * 81 : nextLoadIndex;
	
	// the total number of vectors to be loaded into memory
	unsigned nLoadVecNum = nextLoadIndex - currentDataId;

	// the float-point data has only one file
	string dataFileName = dataFileNamePrefix;

	// open the training data file
	ifstream fin;
	fin.open(dataFileName.c_str(), ios_base::binary);

	// locate the first vector to load in the file
	fin.seekg((currentDataId % nDataPerFile) * nPixelPerData * sizeof(floatType));	

	// load the vectors until the buffer is filled or the end is reached
	fin.read((char*)batchDataBuffer, sizeof(floatType) * nPixelPerData * nLoadVecNum);

	// update the index of vector counter
	currentDataId += nLoadVecNum;

	fin.close();
}


/*
 * Load training data from files to memory
 * This function is for GB-RBM and autoencoder, which processes the byte files
*/
void dataProvider::loadByteFileToBuffer(){

	// the nextLoadIndex indicates the index of the first vector not included in this loading
	int nextLoadIndex = currentDataId + nDataPerBatch * nBatchInBuffer;

	// if the end of the training data is reached, the nextLoadIndex is set to the end
	nextLoadIndex = (nextLoadIndex > 68000 * 30 * 81) ? 68000 * 30 * 81 : nextLoadIndex;

	// open the corresponding patch file
	string dataFileName = dataFileNamePrefix;
	generateFileName(&dataFileName, currentFileId, 3);
	ifstream fin;
	fin.open(dataFileName.c_str(), ios_base::binary);

	// the index of the first vector in the memory buffer
	unsigned int localDataId = 0;

	// the temp buffer to cache a vector
	unsigned char tempBuffer[nPixelPerData];

	while(currentDataId < nextLoadIndex){
		// locate the vector to be loaded in the file
		fin.seekg((currentDataId % nDataPerFile) * nPixelPerData * sizeof(unsigned char));

		// read one vector from the file
		fin.read((char*)tempBuffer, sizeof(unsigned char) * nPixelPerData);

		// transfer byte to float
		// here goes the preprocessing code, normalization, followed by x = (x - mean) / stdvar
		for(int i = 0; i < nPixelPerData; i++){
			batchDataBuffer[localDataId * nPixelPerData + i] = ((((floatType)tempBuffer[i]) / 255.0) - mean[i]) / variance[i];
		}

		// handle the end of files
		if((currentDataId + 1) % nDataPerFile == 0){
			// close the current file
			fin.close();
			// update the file counter
			currentFileId++;
			// get the new file name
			dataFileName = dataFileNamePrefix;
			generateFileName(&dataFileName, currentFileId, 3);
			// open the next file to read
			fin.open(dataFileName.c_str(), ios_base::binary);
		}
		// update the counter of vector
		currentDataId++;
		localDataId++;
	}
	// close the input file
	fin.close();
}

/*
 * This function returns the pointer to a memory buffer which contains the next mini-batch to be processed.
 * The function automatically read the subsequent batches. The user can call dataProvider::reset() to read from the beginning.
*/

floatType* dataProvider::getNextBatch(){
	
	// If the end of data is reached, return NULL.
	if(currentBatchId >= nBatchNum){
		return NULL;
	}

	// Compute the local index of the batch to be returned in the buffer
	unsigned localBatchId = currentBatchId % nBatchInBuffer;

	// If the batch is not in the buffer, load subsequent batches from files to the buffer
	if(localBatchId == 0){
		// floatPoint - true for BB-RBM / false for GB-RBM and autoencoder
		if(floatPoint){
			loadFloatFileToBuffer();
		}
		else{
			loadByteFileToBuffer();
		}
	}

	// return the pointer to the mini-batch in the buffer
	floatType* batch = batchDataBuffer + localBatchId * nDataPerBatch * nPixelPerData;

	// update the mini-batch counter
	currentBatchId++;

	// return the pointer
	return batch;
}

/*
 * This function is used for shuffling the vectors in the host buffer.
 * An extra buffer is allocated in the function and released before it terminates.
*/

void dataProvider::shuffleDataInBuffer(){
	time_t t;
	srand((unsigned)time(&t)); 

	// the main loop of Knuth shuffling algorithm
	for(unsigned i = 1; i < nBatchInBuffer * nDataPerBatch; i++){
		//  return a pseudo-random integral number
		unsigned j = rand() % i;
		
		// swap the contents of the elements p[i] and p[j]
		shuffledId[i] = shuffledId[j];
		shuffledId[j] = i;
	}
	
	// allocate host memory for shuffling data
	floatType* shuffleBuffer = new floatType[nBatchInBuffer * nDataPerBatch * nPixelPerData];
	
	// the main loop of shuffling data
	for(unsigned i = 0; i < nBatchInBuffer * nDataPerBatch; i++){
		floatType* dst = shuffleBuffer + shuffledId[i] * nPixelPerData;
		floatType* src = batchDataBuffer + i * nPixelPerData;
		memcpy((char*)dst, (char*)src, nPixelPerData * sizeof(floatType));
	}

	// copy the shuffled data back to the buffer
	memcpy((char*)batchDataBuffer, (char*)shuffleBuffer, nBatchInBuffer * nDataPerBatch * nPixelPerData * sizeof(floatType));

	// free the host memory for shuffling data
	delete[] shuffleBuffer;

	return;
}

/*
 * The constructor of the data provider for GPU, which is derived from the data provider for CPU.
*/
dataProvider_GPU::dataProvider_GPU(CL_ENV env, string prefix, unsigned pixelperdata, unsigned batchSize, bool floatpoint)
	:dataProvider(prefix, pixelperdata, batchSize, floatpoint){
		// initialize the OpenCL environment
		cl_env = env;
		// create a device buffer on GPU
		batchDataDeviceBuffer = clCreateBuffer(cl_env.ctx, CL_MEM_READ_WRITE, nBatchInBuffer * nDataPerBatch * nPixelPerData * sizeof(floatType), NULL, &cl_env.status);

}

/*
 * Transfer the data from the host buffer to the device buffer
*/
void dataProvider_GPU::loadDeviceBufferFromHost(){
	
	cl_env.status = clEnqueueWriteBuffer(cl_env.queue, batchDataDeviceBuffer, CL_TRUE, 0, nBatchInBuffer * nDataPerBatch * nPixelPerData * sizeof(floatType), (void*)batchDataBuffer, 0, NULL, NULL);
	if(cl_env.status != CL_SUCCESS){
		printf("Load device buffer from host failed");
		system("pause");
		exit(-1);
	}
	return;
}

/*
 * Copy the mini-batch to the destination cl_mem object.
 * The device buffer is seen as nBatchInBuffer slices of nDataPerBatch * nPixelPerData rectangles
*/
void dataProvider_GPU::getNextDeviceBatch(cl_mem& batch)
{
	// return NULL if the end of data is reached
	if(currentBatchId >= nBatchNum){
		batch = NULL;
	}

	// the local index of the batch to be loaded in the buffer
	unsigned localBatchId = currentBatchId % nBatchInBuffer;

	// load subsequent batches into buffers when the batch to be loaded in not in the buffer
	if(localBatchId == 0)
	{
		// load the batches from file to host memory
		if(floatPoint){
			loadFloatFileToBuffer();
		}
		else{
			loadByteFileToBuffer();
		}

		// load the batches from host memory to device memory
		loadDeviceBufferFromHost();
	}

	size_t bufferOrigin[3], batchOrigin[3], region[3];

	// the position of the batch in the device buffer
	bufferOrigin[0] = 0;
	bufferOrigin[1] = 0;
	bufferOrigin[2] = localBatchId;

	// the position in the dst cl_mem object
	batchOrigin[0] = batchOrigin[1] = batchOrigin[2] = 0; 

	// the region to be copied, one slice
	region[0] = nPixelPerData * sizeof(floatType);
	region[1] = nDataPerBatch;
	region[2] = 1;

	cl_env.status = clEnqueueCopyBufferRect(
		cl_env.queue,
		batchDataDeviceBuffer,
		batch,
		bufferOrigin, 
		batchOrigin, 
		region,
		nPixelPerData * sizeof(floatType), 
		nPixelPerData * nDataPerBatch * sizeof(floatType), 
		nPixelPerData * sizeof(floatType), 
		nPixelPerData * nDataPerBatch * sizeof(floatType), 
		0, NULL, NULL);

	if(cl_env.status != CL_SUCCESS)
	{
		printf("copy buffer rect failed!");
		exit(-1);
	}

	// update the batch counter
	currentBatchId++;

	return;

}
