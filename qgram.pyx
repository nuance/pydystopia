cdef extern from "stdlib.h":
	void free(void *ptr)

cdef extern from "stdbool.h":
	ctypedef int bool

	int true, false

cdef extern from "stdint.h":
	ctypedef signed char int8_t
	ctypedef unsigned char uint8_t
	ctypedef signed int int16_t
	ctypedef unsigned int uint16_t
	ctypedef signed long int int32_t
	ctypedef unsigned long int uint32_t
	ctypedef signed long long int int64_t
	ctypedef signed long long int uint64_t

cdef extern from "tcqdb.h":
	# tokyo dystopia imports

	# Basic type
	ctypedef struct TCQDB:
		pass

	# Error message handling
	char *tcqdberrmsg(int ecode)
	int tcqdbecode(TCQDB *idb)

	TCQDB *tcqdbnew()

	bool tcqdbopen(TCQDB *idb, char *path, int omode)
	bool tcqdbclose(TCQDB *idb)
	bool tcqdbdel(TCQDB *idb)

	bool tcqdbput(TCQDB *idb, int64_t id, char *text)
	bool tcqdboptimize(TCQDB *idb)

	bool tcqdbout(TCQDB *idb, int64_t id, char*text)

	uint64_t *tcqdbsearch(TCQDB *idb, char *word, int smode, int *np)

	int QDBOCREAT, QDBOWRITER, QDBOREADER, QDBONOLCK
	int QDBSSUBSTR

cdef class Indexer:
	cdef TCQDB *index

	def __init__(self, char *index_file):
		""" Open the index located at index_file, creating it if it
		doesn't already exist
		"""
		self.index = tcqdbnew()
		if tcqdbopen(self.index, index_file, QDBOCREAT | QDBOWRITER) != true:
			raise Exception("Exception creating/opening index for write: %s" % tcqdberrmsg(tcqdbecode(self.index)))

	def add_doc(self, int64_t doc_id, char *text):
		""" Add a new document, with the associated text
		"""
		result = tcqdbput(self.index, doc_id, text)

		# FIXME: do something with the result

	def delete_doc(self, int64_t doc_id, char *text):
		result = tcqdbout(self.index, doc_id, text)

	def optimize(self):
		result = tcqdboptimize(self.index)

	def close(self):
		cdef bool result
		if self.index != NULL:
			result = tcqdbclose(self.index)
			if result == false:
				raise Exception("Exception closing index opened for write: %s" % tcqdberrmsg(tcqdbecode(self.index)))
				
			tcqdbdel(self.index)
		self.index = NULL

	def __del__(self):
		self.close()


cdef class Searcher:
	cdef TCQDB *index

	def __init__(self, char *index_file):
		""" Open the index located at index_file, creating it if it
		doesn't already exist
		"""
		self.index = tcqdbnew()
		if tcqdbopen(self.index, index_file, QDBOREADER | QDBONOLCK) != true:
			raise Exception("Exception opening index for read / no locking: %s" % tcqdberrmsg(tcqdbecode(self.index)))

	def search(self, char *query):
		cdef uint64_t *results
		cdef int num_results
		cdef list py_results = list()

		results = tcqdbsearch(self.index, query, QDBSSUBSTR, &num_results)

		if results == NULL:
			raise Exception("Exception searching: %s" % tcqdberrmsg(tcqdbecode(self.index)))

		for idx in range(num_results):
			py_results.append((int(results[idx]), ''))

		free(results)

		return py_results

	def close(self):
		if self.index != NULL:
			tcqdbdel(self.index)
		self.index = NULL

	def __del__(self):
		self.close()
