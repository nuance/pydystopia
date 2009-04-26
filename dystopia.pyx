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

cdef extern from "dystopia.h":
	# tokyo dystopia imports

	# Basic type
	ctypedef struct TCIDB:
		pass

	# Error message handling
	char *tcidberrmsg(int ecode)
	int tcidbecode(TCIDB *idb)

	TCIDB *tcidbnew()

	bool tcidbopen(TCIDB *idb, char *path, int omode)
	bool tcidbdel(TCIDB *idb)

	bool tcidbput(TCIDB *idb, int64_t id, char *text)
	bool tcidboptimize(TCIDB *idb)

	bool tcidbout(TCIDB *idb, int64_t id)
	char *tcidbget(TCIDB *idb, int64_t id)

	uint64_t *tcidbsearch2(TCIDB *idb, char *expr, int *np)

	int IDBOCREAT, IDBOWRITER, IDBOREADER, IDBONOLCK

cdef class Indexer:
	cdef TCIDB *index

	def __init__(self, char *index_file):
		""" Open the index located at index_file, creating it if it
		doesn't already exist
		"""
		self.index = tcidbnew()
		if tcidbopen(self.index, index_file, IDBOCREAT | IDBOWRITER) != true:
			raise Exception("Exception creating/opening index for write: %s" % tcidberrmsg(tcidbecode(self.index)))

	def add_doc(self, int64_t doc_id, char *text):
		""" Add a new document, with the associated text
		"""
		result = tcidbput(self.index, doc_id, text)

		# FIXME: do something with the result

	def delete_doc(self, int64_t doc_id):
		result = tcidbout(self.index, doc_id)

	def get_doc(self, int64_t doc_id):
		return tcidbget(self.index, doc_id)

	def optimize(self):
		result = tcidboptimize(self.index)

	def close(self):
		if self.index != NULL:
			tcidbdel(self.index)
		self.index = NULL

	def __del__(self):
		self.close()


cdef class Searcher:
	cdef TCIDB *index

	def __init__(self, char *index_file):
		""" Open the index located at index_file, creating it if it
		doesn't already exist
		"""
		self.index = tcidbnew()
		if tcidbopen(self.index, index_file, IDBOREADER | IDBONOLCK) != true:
			raise Exception("Exception opening index for read / no locking: %s" % tcidberrmsg(tcidbecode(self.index)))

	cdef char* get_doc(self, int64_t doc_id):
		return tcidbget(self.index, doc_id)

	def search(self, char *query):
		cdef uint64_t *results
		cdef int num_results
		cdef list py_results = list()

		results = tcidbsearch2(self.index, query, &num_results)

		if results == NULL:
			raise Exception("Exception searching: %s" % tcidberrmsg(tcidbecode(self.index)))

		for idx in range(num_results):
			py_results.append((int(results[idx]), self.get_doc(results[idx])))

		free(results)

		return py_results

	def close(self):
		if self.index != NULL:
			tcidbdel(self.index)
		self.index = NULL

	def __del__(self):
		self.close()
